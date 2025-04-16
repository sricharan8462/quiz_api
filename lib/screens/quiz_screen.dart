import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questionsFuture;
  int currentIndex = 0;
  int score = 0;
  bool answered = false;
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    _questionsFuture = ApiService.fetchQuestions();
  }

  void checkAnswer(String answer, Question question) {
    if (!answered) {
      setState(() {
        selectedAnswer = answer;
        answered = true;
        if (answer == question.correctAnswer) {
          score++;
        }
      });

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          if (currentIndex < 9) {
            currentIndex++;
            answered = false;
            selectedAnswer = null;
          } else {
            _showFinalScore();
          }
        });
      });
    }
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Quiz Complete!"),
            content: Text("Your score: $score / 10"),
            actions: [
              TextButton(
                child: Text("Restart"),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    currentIndex = 0;
                    score = 0;
                    answered = false;
                    _questionsFuture = ApiService.fetchQuestions();
                  });
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quiz App")),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final question = snapshot.data![currentIndex];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Question ${currentIndex + 1}/10",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  Text(question.question, style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ...question.allAnswers.map((answer) {
                    final isCorrect = answer == question.correctAnswer;
                    final isSelected = answer == selectedAnswer;
                    final color =
                        !answered
                            ? Colors.blue
                            : isCorrect
                            ? Colors.green
                            : isSelected
                            ? Colors.red
                            : Colors.grey[300];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: color),
                        onPressed: () => checkAnswer(answer, question),
                        child: Text(answer),
                      ),
                    );
                  }),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
