import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = '9'; // Default: General Knowledge
  String selectedDifficulty = 'easy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Settings")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const [
                DropdownMenuItem(value: '9', child: Text('General Knowledge')),
                DropdownMenuItem(value: '21', child: Text('Sports')),
                DropdownMenuItem(value: '17', child: Text('Science')),
                DropdownMenuItem(value: '23', child: Text('History')),
                DropdownMenuItem(value: '22', child: Text('Geography')),
              ],
              onChanged: (val) => setState(() => selectedCategory = val!),
            ),
            DropdownButtonFormField<String>(
              value: selectedDifficulty,
              decoration: const InputDecoration(labelText: 'Difficulty'),
              items: const [
                DropdownMenuItem(value: 'easy', child: Text('Easy')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'hard', child: Text('Hard')),
              ],
              onChanged: (val) => setState(() => selectedDifficulty = val!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Start Quiz"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      category: selectedCategory,
                      difficulty: selectedDifficulty,
                      type: 'multiple', // Hardcoded to MCQ
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
