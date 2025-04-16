import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static Future<List<Question>> fetchQuestions(
    String category,
    String difficulty,
    String type,
  ) async {
    final url = Uri.parse(
      'https://opentdb.com/api.php?amount=10&category=$category&difficulty=$difficulty&type=$type',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['results'] as List)
          .map((q) => Question.fromJson(q))
          .toList();
    } else {
      throw Exception('Failed to fetch questions');
    }
  }
}
