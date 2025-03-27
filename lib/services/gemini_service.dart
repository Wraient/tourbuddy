import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String _apiKey;
  late final GenerativeModel _model;

  GeminiService(this._apiKey) {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: 'AIzaSyAvmgXbNex9MoeCruCb8mFuCmmSHqgyRLc',
    );
  }

  Future<String> getPlaceDescription(String placeName) async {
    try {
      final prompt = '''
        Act as a knowledgeable tour guide and provide a detailed, engaging description of $placeName.
        Include:
        - Brief history
        - Cultural significance
        - Main attractions
        - Best time to visit
        - Interesting facts
        Keep it concise but informative, around 3-4 sentences.
        ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        print('Empty response from Gemini');
        return 'Description not available';
      }
      
      return response.text!;
    } catch (e) {
      print('Error getting Gemini description: $e');
      return 'Description not available';
    }
  }
} 