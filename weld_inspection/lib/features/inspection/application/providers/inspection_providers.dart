import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/inspection_api_configuration.dart';
import '../../data/repositories/demo_inspection_repository.dart';
import '../../data/repositories/fast_api_inspection_repository.dart';
import '../../domain/models/inspection_request.dart';
import '../../domain/repositories/inspection_repository.dart';
import '../../../inspection_history/application/providers/inspection_history_providers.dart';

final inspectionApiConfigurationProvider = Provider<InspectionApiConfiguration>(
  (ref) => InspectionApiConfiguration.fromEnvironment,
);

final inspectionRepositoryProvider = Provider<InspectionRepository>((ref) {
  final configuration = ref.watch(inspectionApiConfigurationProvider);
  final historyStore = ref.read(demoInspectionHistoryStoreProvider);
  if (!configuration.useLiveInspection) {
    return DemoInspectionRepository(historyStore);
  }
  return FastApiInspectionRepository(
    dio: Dio(
      BaseOptions(
        baseUrl: configuration.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 90),
      ),
    ),
    historyStore: historyStore,
  );
});

final inspectionImagePickerProvider = Provider<InspectionImagePicker>(
  (ref) => ImagePickerInspectionImagePicker(ImagePicker()),
);

abstract interface class InspectionImagePicker {
  Future<InspectionImage?> pickImage();
}

class ImagePickerInspectionImagePicker implements InspectionImagePicker {
  ImagePickerInspectionImagePicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<InspectionImage?> pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }

    return InspectionImage(
      fileName: image.name,
      bytes: await image.readAsBytes(),
    );
  }
}
