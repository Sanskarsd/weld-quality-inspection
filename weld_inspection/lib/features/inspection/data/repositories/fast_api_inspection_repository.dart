import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../domain/models/inspection_request.dart';
import '../../domain/models/inspection_result.dart';
import '../../domain/repositories/inspection_repository.dart';
import '../../../inspection_history/data/repositories/demo_inspection_history_store.dart';

/// A replaceable adapter for the current FastAPI `/predict` contract.
///
/// The backend currently owns only model inputs and prediction metadata. Flutter
/// keeps the remaining inspection metadata in the returned domain result.
class FastApiInspectionRepository implements InspectionRepository {
  FastApiInspectionRepository({required this.dio, required this.historyStore});

  final Dio dio;
  final DemoInspectionHistoryStore historyStore;

  @override
  Future<InspectionResult> runInspection(InspectionRequest request) async {
    final batchNo = request.jobBatchId?.trim();
    if (batchNo == null || batchNo.isEmpty) {
      throw const LiveInspectionException(
        'A job / batch ID is required by the live inspection service.',
      );
    }

    final stopwatch = Stopwatch()..start();
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/predict',
        data: FormData.fromMap(<String, Object>{
          'file': MultipartFile.fromBytes(
            request.image.bytes,
            filename: request.image.fileName,
            contentType: _imageMediaType(request.image.fileName),
          ),
          'batch_no': batchNo,
        }),
      );
      stopwatch.stop();

      final body = response.data;
      if (body == null) {
        throw const LiveInspectionException(
          'The live inspection service returned an empty response.',
        );
      }
      final result = FastApiPredictionMapper.toInspectionResult(
        body,
        request: request,
        processingTime: stopwatch.elapsed,
      );
      historyStore.add(result);
      return result;
    } on LiveInspectionException {
      rethrow;
    } on DioException catch (error) {
      throw LiveInspectionException(_messageFor(error));
    } on FormatException catch (error) {
      throw LiveInspectionException(
        'Invalid prediction response: ${error.message}',
      );
    }
  }

  static MediaType _imageMediaType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      _ => throw const LiveInspectionException(
        'The live inspection service accepts JPG, PNG, and WEBP images only.',
      ),
    };
  }

  static String _messageFor(DioException error) {
    final payload = error.response?.data;
    if (payload is Map && payload['detail'] is String) {
      return payload['detail'] as String;
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'The live inspection service timed out. Check the backend connection.',
      DioExceptionType.connectionError => 'Unable to reach the live inspection service. Check its URL and network connection.',
      _ => 'The live inspection service could not complete the inspection.',
    };
  }
}

class FastApiPredictionMapper {
  const FastApiPredictionMapper._();

  static InspectionResult toInspectionResult(
    Map<String, dynamic> json, {
    required InspectionRequest request,
    required Duration processingTime,
  }) {
    final predictionId = _requiredString(json, 'prediction_id');
    final predictedClass = _requiredString(json, 'predicted_class');
    final message = _requiredString(json, 'message');
    final imageName = _requiredString(json, 'image_filename');
    final uploadedAt = DateTime.tryParse(_requiredString(json, 'uploaded_at'));
    final confidence = json['confidence'];
    final accepted = json['result'];
    if (uploadedAt == null || confidence is! num || accepted is! bool) {
      throw const FormatException('Missing or invalid prediction fields.');
    }

    return InspectionResult(
      inspectionId: predictionId,
      status: accepted ? InspectionStatus.passed : InspectionStatus.failed,
      confidence: confidence.toDouble(),
      defectDetected: !accepted,
      defectType: accepted ? null : predictedClass,
      processingTime: processingTime,
      completedAt: uploadedAt,
      imageName: imageName,
      image: request.image,
      componentName: request.componentName,
      jobBatchId: request.jobBatchId,
      inspectionType: request.type,
      inspectionNotes: request.notes,
      details: message,
      dataSource: InspectionDataSource.live,
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('Missing or invalid "$key".');
    }
    return value;
  }
}

class LiveInspectionException implements Exception {
  const LiveInspectionException(this.message);

  final String message;

  @override
  String toString() => message;
}
