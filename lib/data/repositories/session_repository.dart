import '../../features/session/models/session_part.dart';
import '../datasources/remote/session_remote_data_source.dart';

class SessionRepository {
  final SessionRemoteDataSource _sessionRemoteDataSource;

  SessionRepository(this._sessionRemoteDataSource);

  Future<void> startSession({
    required int receiverId,
    required List<SessionPart> parts,
  }) async {
    await _sessionRemoteDataSource.startSession(
      receiverId: receiverId,
      parts: parts,
    );
  }

  Future<void> endSession() async {
    await _sessionRemoteDataSource.endSession();
  }
}
