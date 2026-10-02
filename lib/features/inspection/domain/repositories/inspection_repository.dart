import '../models/inspection_request.dart';
import '../models/inspection_result.dart';

abstract interface class InspectionRepository {
  Future<InspectionResult> runInspection(InspectionRequest request);
}
