import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/repositories/demo_inspection_repository.dart';
import '../../domain/models/inspection_request.dart';
import '../../domain/repositories/inspection_repository.dart';

final inspectionRepositoryProvider = Provider<InspectionRepository>(
  (ref) => const DemoInspectionRepository(),
);

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
