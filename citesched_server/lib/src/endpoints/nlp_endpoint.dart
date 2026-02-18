import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/nlp_service.dart';

class NLPEndpoint extends Endpoint {
  final _nlpService = NLPService();

  Future<NLPResponse> query(Session session, String text) async {
    final authInfo = await session.authenticated;

    return await _nlpService.processQuery(
      session,
      text,
      authInfo?.userIdentifier,
      authInfo?.scopes.map((s) => s.toString()).toList() ?? [],
    );
  }
}
