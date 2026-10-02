import 'dart:typed_data';

enum InspectionType { weldVisual, fabricationVisual }

extension InspectionTypeLabel on InspectionType {
  String get label => switch (this) {
    InspectionType.weldVisual => 'Weld visual inspection',
    InspectionType.fabricationVisual => 'Fabrication visual inspection',
  };
}

class InspectionImage {
  const InspectionImage({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}

class InspectionRequest {
  const InspectionRequest({
    required this.image,
    required this.type,
    this.componentName,
    this.notes,
  });

  final InspectionImage image;
  final InspectionType type;
  final String? componentName;
  final String? notes;
}
