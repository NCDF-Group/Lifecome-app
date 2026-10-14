import '../../../core/network/api_client.dart';
import '../domain/models/doctor.dart';

/// The clinician directory (the backend's `/providers`). Failures surface as
/// an `ApiException`.
abstract interface class DoctorRepository {
  /// Every clinician currently taking patients.
  Future<List<Doctor>> listDoctors();

  Future<Doctor> getDoctor(String id);
}

class DioDoctorRepository implements DoctorRepository {
  DioDoctorRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Doctor>> listDoctors() async {
    final rows = await _client.getList('/providers');
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) Doctor.fromJson(row),
    ];
  }

  @override
  Future<Doctor> getDoctor(String id) async =>
      Doctor.fromJson(await _client.get('/providers/$id'));
}
