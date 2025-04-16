import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static Future<List<Question>> fetchQuestions() async {
    final url = Uri.parse("https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Question> questions = (data['results'] as List)
          .map((q) => Question.fromJson(q))
          .toList();
      return questions;
    } else {
      throw Exception("Failed to load questions");
    }
  }
}
  