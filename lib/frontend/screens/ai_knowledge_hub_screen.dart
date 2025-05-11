import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AIKnowledgeHubScreen extends StatefulWidget {
  const AIKnowledgeHubScreen({super.key});

  @override
  State<AIKnowledgeHubScreen> createState() => _AIKnowledgeHubScreenState();
}

class _AIKnowledgeHubScreenState extends State<AIKnowledgeHubScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _lessons = [];
  List<Map<String, dynamic>> _qaResponses = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() => _isLoading = true);
    try {
      // Mock loading lessons
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _lessons = [
          {
            'title': 'Budgeting Basics',
            'content': 'Learn how to create and stick to a budget.',
          },
          {
            'title': 'Investment Strategies',
            'content': 'Explore different investment strategies for beginners.',
          },
          {
            'title': 'Saving Tips',
            'content': 'Tips on how to save money effectively.',
          },
        ];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading lessons: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _askQuestion(String question) {
    // Mock Q&A response
    setState(() {
      _qaResponses.add({
        'question': question,
        'answer': 'This is a mock answer to your question.',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Knowledge Hub'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Lessons',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = _lessons[index];
                      return ListTile(
                        title: Text(lesson['title']),
                        subtitle: Text(lesson['content']),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ask a Question',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Type your question here...',
                    ),
                    onSubmitted: _askQuestion,
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _qaResponses.length,
                    itemBuilder: (context, index) {
                      final response = _qaResponses[index];
                      return ListTile(
                        title: Text(response['question']),
                        subtitle: Text(response['answer']),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadLessons,
                    child: const Text('Refresh Lessons'),
                  ),
                ],
              ),
            ),
    );
  }
} 