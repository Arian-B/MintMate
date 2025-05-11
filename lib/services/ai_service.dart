import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class AIService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _imagePicker = ImagePicker();

  Future<String> scanReceipt() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image == null) return '';

      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      return recognizedText.text;
    } catch (e) {
      print('Error scanning receipt: $e');
      return '';
    }
  }

  String categorizeExpense(String description, double amount) {
    // Simple rule-based categorization
    description = description.toLowerCase();
    
    if (description.contains('food') || 
        description.contains('restaurant') || 
        description.contains('cafe')) {
      return 'Food & Dining';
    }
    
    if (description.contains('transport') || 
        description.contains('uber') || 
        description.contains('taxi')) {
      return 'Transportation';
    }
    
    if (description.contains('rent') || 
        description.contains('mortgage') || 
        description.contains('housing')) {
      return 'Housing';
    }
    
    if (description.contains('movie') || 
        description.contains('entertainment') || 
        description.contains('game')) {
      return 'Entertainment';
    }
    
    if (description.contains('medical') || 
        description.contains('health') || 
        description.contains('pharmacy')) {
      return 'Healthcare';
    }
    
    // Default category
    return 'Other';
  }

  Map<String, dynamic> analyzeSpendingPatterns(List<Map<String, dynamic>> expenses) {
    // Calculate total spending
    double totalSpending = expenses.fold(0, (sum, expense) => sum + expense['amount']);
    
    // Calculate category-wise spending
    Map<String, double> categorySpending = {};
    for (var expense in expenses) {
      String category = expense['category'];
      categorySpending[category] = (categorySpending[category] ?? 0) + expense['amount'];
    }
    
    // Calculate percentage for each category
    Map<String, double> categoryPercentages = {};
    categorySpending.forEach((category, amount) {
      categoryPercentages[category] = (amount / totalSpending) * 100;
    });
    
    return {
      'totalSpending': totalSpending,
      'categorySpending': categorySpending,
      'categoryPercentages': categoryPercentages,
    };
  }
} 