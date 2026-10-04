import '../../../inspection/domain/models/inspection_result.dart';

abstract interface class InspectionHistoryRepository {
  Future<List<InspectionResult>> getHistory();

  Future<InspectionResult?> getById(String inspectionId);

  Stream<List<InspectionResult>> watchHistory();
}
