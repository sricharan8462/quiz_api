import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  final String difficulty;
  final String type;

  const QuizScreen({
    super.key,
    required this.category,
    required this.difficulty,
    required this.type,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questionsFuture;
  List<Question> _questions = [];
  int currentIndex = 0;
  int score = 0;
  bool answered = false;
  String? selectedAnswer;
  int timeLeft = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _questionsFuture = ApiService.fetchQuestions(
      widget.category,
      widget.difficulty,
      widget.type,
    );
  }

  void startTimer() {
    timeLeft = 10;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          goToNextQuestion();
        }
      });
    });
  }

  void checkAnswer(String answer, Question question) {
    if (!answered) {
      _timer?.cancel();
      setState(() {
        selectedAnswer = answer;
        answered = true;
        if (answer == question.correctAnswer) {
          score++;
        }
      });

      Future.delayed(const Duration(seconds: 1), () {
        goToNextQuestion();
      });
    }
  }

  void goToNextQuestion() {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex++;
        answered = false;
        selectedAnswer = null;
      });
      startTimer();
    } else {
      _timer?.cancel();
      _showFinalScore();
    }
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Completed"),
        content: Text("Your score: $score / ${_questions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("Restart"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz In Progress"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "⏱ $timeLeft s",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            _questions = snapshot.data!;
            final question = _questions[currentIndex];

            // Ensure the timer starts once per question render
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_timer == null || !_timer!.isActive) {
                startTimer();
              }
            });

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Question ${currentIndex + 1} / ${_questions.length}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.question,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 24),
                  ...question.allAnswers.map((answer) {
                    Color? color;
                    if (answered) {
                      if (answer == question.correctAnswer) {
                        color = Colors.green;
                      } else if (answer == selectedAnswer) {
                        color = Colors.red;
                      } else {
                        color = Colors.grey[300];
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => checkAnswer(answer, question),
                        child: Text(answer),
                      ),
                    );
                  }),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
