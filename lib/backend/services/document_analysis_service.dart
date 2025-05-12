import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_service.dart';

class DocumentAnalysisService extends BaseService {
  final textRecognizer = TextRecognizer();
  final ImagePicker _picker = ImagePicker();

  DocumentAnalysisService() : super(FirebaseFirestore.instance, 'document_analysis');

  @override
  Map<String, dynamic> fromFirestore(DocumentSnapshot doc) {
    return doc.data() as Map<String, dynamic>;
  }

  @override
  Map<String, dynamic> toFirestore(dynamic model) {
    return model as Map<String, dynamic>;
  }

  // Receipt Scanner
  Future<Map<String, dynamic>> scanReceipt(String userId) async {
    try {
      // Pick image from camera
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) throw Exception('No image selected');

      // Process image with ML Kit
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Extract receipt data
      final receiptData = _extractReceiptData(recognizedText.text);

      // Store receipt data
      await create({
        'userId': userId,
        'type': 'receipt',
        'data': receiptData,
        'timestamp': DateTime.now(),
        'imageUrl': await _uploadReceiptImage(image.path),
      });

      return receiptData;
    } catch (e) {
      throw Exception('Error scanning receipt: $e');
    }
  }

  Future<String> _uploadReceiptImage(String imagePath) async {
    // TODO: Implement image upload to cloud storage
    return 'dummy_url';
  }

  Map<String, dynamic> _extractReceiptData(String text) {
    // Extract date
    final datePattern = RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}');
    final dateMatch = datePattern.firstMatch(text);
    final date = dateMatch?.group(0);

    // Extract total amount
    final amountPattern = RegExp(r'Total:?\s*\$?(\d+\.\d{2})');
    final amountMatch = amountPattern.firstMatch(text);
    final amount = amountMatch?.group(1);

    // Extract merchant name (first line usually)
    final merchant = text.split('\n').first;

    // Extract items (lines with prices)
    final itemPattern = RegExp(r'(.+?)\s+\$?(\d+\.\d{2})');
    final items = itemPattern.allMatches(text).map((match) => {
      'name': match.group(1)?.trim(),
      'price': double.tryParse(match.group(2) ?? '0'),
    }).toList();

    return {
      'merchant': merchant,
      'date': date,
      'total': double.tryParse(amount ?? '0'),
      'items': items,
    };
  }

  // Contract Analyzer
  Future<Map<String, dynamic>> analyzeContract(String userId, String contractText) async {
    try {
      // Call AI service for contract analysis
      final response = await http.post(
        Uri.parse('https://api.ai-service.com/analyze-contract'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'contractText': contractText,
        }),
      );

      if (response.statusCode == 200) {
        final analysis = jsonDecode(response.body);
        
        // Store contract analysis
        await create({
          'userId': userId,
          'type': 'contract',
          'data': analysis,
          'timestamp': DateTime.now(),
        });

        return analysis;
      } else {
        throw Exception('Failed to analyze contract');
      }
    } catch (e) {
      throw Exception('Error analyzing contract: $e');
    }
  }

  // Extract key terms from contract
  Map<String, dynamic> _extractKeyTerms(String contractText) {
    final terms = {
      'parties': _extractParties(contractText),
      'dates': _extractDates(contractText),
      'obligations': _extractObligations(contractText),
      'payments': _extractPayments(contractText),
      'termination': _extractTermination(contractText),
    };

    return terms;
  }

  List<String> _extractParties(String text) {
    final partyPattern = RegExp(r'(?:Party|Parties|Between|Agreement between)\s*:?\s*([^\.]+)');
    return partyPattern.allMatches(text)
        .map((match) => match.group(1)?.trim() ?? '')
        .where((party) => party.isNotEmpty)
        .toList();
  }

  List<String> _extractDates(String text) {
    final datePattern = RegExp(r'(?:Date|Effective|Commencement|Termination)\s*:?\s*(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})');
    return datePattern.allMatches(text)
        .map((match) => match.group(1)?.trim() ?? '')
        .where((date) => date.isNotEmpty)
        .toList();
  }

  List<String> _extractObligations(String text) {
    final obligationPattern = RegExp(r'(?:shall|must|will|agrees to)\s+([^\.]+)');
    return obligationPattern.allMatches(text)
        .map((match) => match.group(1)?.trim() ?? '')
        .where((obligation) => obligation.isNotEmpty)
        .toList();
  }

  List<String> _extractPayments(String text) {
    final paymentPattern = RegExp(r'(?:Payment|Amount|Price|Fee)\s*:?\s*\$?(\d+\.\d{2})');
    return paymentPattern.allMatches(text)
        .map((match) => match.group(1)?.trim() ?? '')
        .where((payment) => payment.isNotEmpty)
        .toList();
  }

  List<String> _extractTermination(String text) {
    final terminationPattern = RegExp(r'(?:Termination|Term|Duration)\s*:?\s*([^\.]+)');
    return terminationPattern.allMatches(text)
        .map((match) => match.group(1)?.trim() ?? '')
        .where((termination) => termination.isNotEmpty)
        .toList();
  }

  Future<void> initializeAnalysis() async {
    // TODO: Implement document analysis initialization
    await Future.delayed(const Duration(milliseconds: 500)); // Placeholder
  }
} 