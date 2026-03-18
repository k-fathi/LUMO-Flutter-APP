import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../features/session/models/session_part.dart';

abstract class SessionRemoteDataSource {
  Future<void> startSession({
    required int receiverId,
    required List<SessionPart> parts,
  });
  Future<void> endSession();
}

class SessionRemoteDataSourceImpl implements SessionRemoteDataSource {
  final DioClient _dioClient;

  SessionRemoteDataSourceImpl(this._dioClient);

  @override
  Future<void> startSession({
    required int receiverId,
    required List<SessionPart> parts,
  }) async {
    await _dioClient.post(
      ApiConstants.startSession,
      data: {
        'receiver_id': receiverId,
        'parts': parts.map((p) => p.toJson()).toList(),
      },
    );
  }

  @override
  Future<void> endSession() async {
    await _dioClient.post(ApiConstants.endSession);
  }
}
