import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/ai_service.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AIKnowledgeHubScreen extends StatefulWidget {
  const AIKnowledgeHubScreen({super.key});

  @override
  State<AIKnowledgeHubScreen> createState() => _AIKnowledgeHubScreenState();
}

class _AIKnowledgeHubScreenState extends State<AIKnowledgeHubScreen> {
  bool _isLoading = false;
  bool _isListening = false;
  final SpeechToText _speechToText = SpeechToText();
  final TextEditingController _questionController = TextEditingController();
  final AIService _aiService = AIService();
  List<Map<String, dynamic>> _lessons = [];
  final List<Map<String, dynamic>> _qaResponses = [];
  Map<String, dynamic> _progress = {
    'completedLessons': 0,
    'totalLessons': 0,
    'streak': 0,
    'badges': [],
  };
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _loadLessons();
    _loadProgress();
  }

  Future<void> _initializeSpeech() async {
    await _speechToText.initialize();
  }

  Future<void> _loadLessons() async {
    setState(() => _isLoading = true);
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        final lessons = await _aiService.getFinancialLessons(userId);
        setState(() {
          _lessons = lessons;
          _progress['totalLessons'] = lessons.length;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading lessons: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProgress() async {
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        final progress = await _aiService.getLearningProgress(userId);
        setState(() {
          _progress = progress;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading progress: $e')),
      );
    }
  }

  Future<void> _askQuestion(String question) async {
    if (question.isEmpty) return;

    setState(() {
      _qaResponses.add({
        'question': question,
        'answer': 'Thinking...',
        'isLoading': true,
      });
    });

    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        final answer = await _aiService.askFinancialQuestion(userId, question);
        setState(() {
          _qaResponses.last['answer'] = answer;
          _qaResponses.last['isLoading'] = false;
        });
      }
    } catch (e) {
      setState(() {
        _qaResponses.last['answer'] = 'Sorry, I encountered an error. Please try again.';
        _qaResponses.last['isLoading'] = false;
      });
    }
  }

  void _startListening() async {
    if (!_isListening) {
      final available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _questionController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  Future<void> _completeLesson(String lessonId) async {
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        await _aiService.completeLesson(userId, lessonId);
        await _loadProgress();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing lesson: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mate Academy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLessons,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressCard(),
                  const SizedBox(height: 24),
                  _buildCategoryFilter(),
                  const SizedBox(height: 16),
                  _buildLessonsList(),
                  const SizedBox(height: 24),
                  _buildQASection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressItem(
                  'Completed',
                  '${_progress['completedLessons']}/${_progress['totalLessons']}',
                  Icons.check_circle,
                ),
                _buildProgressItem(
                  'Streak',
                  '${_progress['streak']} days',
                  Icons.local_fire_department,
                ),
                _buildProgressItem(
                  'Badges',
                  '${_progress['badges'].length}',
                  Icons.emoji_events,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'Crypto', 'Stocks', 'Bonds', 'Taxes', 'NFTs'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLessonsList() {
    final filteredLessons = _selectedCategory == 'All'
        ? _lessons
        : _lessons.where((lesson) => lesson['category'] == _selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bite-sized Lessons',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredLessons.length,
          itemBuilder: (context, index) {
            final lesson = filteredLessons[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(
                  _getCategoryIcon(lesson['category'] as String? ?? ''),
                  color: _getCategoryColor(lesson['category'] as String? ?? ''),
                ),
                title: Text(
                  lesson['title'] as String? ?? '',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  lesson['description'] as String? ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: lesson['completed'] == true
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : IconButton(
                        icon: const Icon(Icons.play_circle_outline),
                        onPressed: () => _completeLesson(lesson['id'] as String),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQASection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ask Mate',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _questionController,
                decoration: const InputDecoration(
                  hintText: 'Ask a question about finance...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: _askQuestion,
              ),
            ),
            IconButton(
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
              onPressed: _startListening,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _qaResponses.length,
          itemBuilder: (context, index) {
            final response = _qaResponses[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q: ${response['question']}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (response['isLoading'] == true)
                      const CircularProgressIndicator()
                    else
                      Text(
                        'A: ${response['answer']}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[800],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'crypto':
        return Icons.currency_bitcoin;
      case 'stocks':
        return Icons.show_chart;
      case 'bonds':
        return Icons.account_balance;
      case 'taxes':
        return Icons.receipt_long;
      case 'nfts':
        return Icons.image;
      default:
        return Icons.school;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'crypto':
        return Colors.amber;
      case 'stocks':
        return Colors.green;
      case 'bonds':
        return Colors.blue;
      case 'taxes':
        return Colors.red;
      case 'nfts':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
} 