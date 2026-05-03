import 'package:pdf/pdf.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AIPdfService {
  static FlutterTts? _tts;
  
  static Future<void> initializeTTS() async {
    _tts = FlutterTts();
    await _tts?.setLanguage("en-US");
    await _tts?.setSpeechRate(0.8); // Medium speaking speed
    await _tts?.setPitch(1.0); // Natural pitch
  }
  
  static Future<void> disposeTTS() async {
    await _tts?.stop();
    _tts = null;
  }
  
  static Future<List<String>> extractPdfText(String pdfPath) async {
    try {
      final file = pdf.PdfFile.openFile(pdfPath);
      final document = await file.load();
      
      List<String> extractedText = [];
      
      for (int i = 0; i < document.pagesCount; i++) {
        final page = await document.getPage(i + 1);
        final pageText = await page.extractText();
        
        if (pageText?.text?.isNotEmpty == true) {
          extractedText.add(pageText!.text!);
        }
      }
      
      return extractedText;
    } catch (e) {
      return ['Unable to extract text from PDF. Please try again.'];
    }
  }
  
  static Future<String> interpretOrigamiStep(List<String> pdfText, int currentPage) async {
    if (pdfText.isEmpty) {
      return "No text found in PDF. This PDF may contain only diagrams.";
    }
    
    // Simple AI interpretation of origami steps
    final stepPatterns = [
      'fold', 'crease', 'triangle', 'square', 'diagonal', 'wings', 'butterfly',
      'paper', 'corner', 'center', 'shape', 'form', 'open', 'close'
    ];
    
    String pageContent = currentPage <= pdfText.length ? pdfText[currentPage - 1] : '';
    
    // Look for origami-specific terms and create beginner-friendly instructions
    String instruction = _generateBeginnerInstruction(pageContent, currentPage);
    
    return instruction;
  }
  
  static String _generateBeginnerInstruction(String content, int stepNumber) {
    // Simplify and make beginner-friendly
    String simplifiedContent = content.toLowerCase();
    
    // Generate contextual instructions based on keywords found
    if (simplifiedContent.contains('square') || simplifiedContent.contains('paper')) {
      return "Step $stepNumber: Start with a square piece of paper. Make sure it's flat and the corners are sharp.";
    } else if (simplifiedContent.contains('triangle') || simplifiedContent.contains('fold')) {
      return "Step $stepNumber: Fold the paper diagonally to create a triangle. Line up the corners perfectly before making your fold.";
    } else if (simplifiedContent.contains('corner')) {
      return "Step $stepNumber: Fold the corners down to meet at the center. This creates the basic shape for your butterfly.";
    } else if (simplifiedContent.contains('wing') || simplifiedContent.contains('butterfly')) {
      return "Step $stepNumber: Now form the wings by making gentle folds. Think of them as the butterfly's delicate wings.";
    } else if (simplifiedContent.contains('center')) {
      return "Step $stepNumber: Bring all folds to meet at the center point. This is where your butterfly takes shape.";
    } else if (simplifiedContent.contains('open') || simplifiedContent.contains('close')) {
      return "Step $stepNumber: Gently open and close your paper like a book. This helps the butterfly take its final form.";
    } else {
      return "Step $stepNumber: Follow the diagram carefully. Take your time with each fold to make it precise.";
    }
  }
  
  static Future<void> speakInstruction(String instruction, {bool showTooltip = false}) async {
    if (_tts == null) return;
    
    try {
      await _tts?.speak(instruction);
      
      if (showTooltip) {
        // In a real implementation, you'd show a tooltip
        // For now, we'll use a simple notification
        print("AI Speaking: $instruction");
      }
    } catch (e) {
      print("TTS Error: $e");
    }
  }
  
  static Future<void> stopSpeaking() async {
    await _tts?.stop();
  }
  
  static Future<void> setSpeechRate(double rate) async {
    await _tts?.setSpeechRate(rate);
  }
  
  static bool get isInitialized => _tts != null;
}
