import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'poll_model.dart';

class PollService {
  static const baseUrl = 'http://127.0.0.1:8000';

  static Future<List<PollQuestion>> fetchPolls(CookieRequest request) async {
    final response = await request.get('$baseUrl/polls/json/') as List<dynamic>;
    return response.map((e) => PollQuestion.fromJson(e)).toList();
  }

  static Future<bool> vote(CookieRequest request, int optionId) async {
    final response =
    await request.get('$baseUrl/vote/$optionId/') as Map<String, dynamic>;
    return response['success'] == true;
  }
}
