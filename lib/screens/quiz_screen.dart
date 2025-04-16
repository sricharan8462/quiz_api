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
      builder:
          (_) => AlertDialog(
            title: const Text("🎉 Quiz Completed"),
            content: Text("Your score: $score / ${_questions.length}"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("Restart"),
              ),
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
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text("🧠 Quiz"),
        centerTitle: true,
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

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_timer == null || !_timer!.isActive) {
                startTimer();
              }
            });

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: timeLeft / 10,
                    color: Colors.redAccent,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Question ${currentIndex + 1} of ${_questions.length}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.question,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color ?? Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.all(14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        color: Colors.black12,
                                      ),
                                    ),
                                  ),
                                  onPressed:
                                      () => checkAnswer(answer, question),
                                  child: Text(answer),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
