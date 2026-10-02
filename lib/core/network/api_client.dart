/// Contract for API implementations. This can be backed by mock data now and
/// replaced by a Dio/FastAPI implementation when the backend is ready.
abstract interface class ApiClient {
  Future<T> get<T>(String path);
  Future<T> post<T>(String path, {Object? data});
}
