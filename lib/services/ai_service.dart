import '../models/ai_response.dart';

class AIService {
  Future<AIResponse> sendMessage(String input) async {
    await Future.delayed(const Duration(seconds: 1));

    final text = input.toLowerCase();

    if (_containsAny(text, ['sad', 'empty', 'lonely', 'hopeless'])) {
      return AIResponse(
        emotion: 'Sadness',
        response:
            "It sounds like you're feeling low and disconnected. These moments can feel heavy. Try taking a small step — maybe step outside or talk to someone you trust.",
      );
    }

    if (_containsAny(text, ['stressed', 'tired', 'overwhelmed', 'burnout'])) {
      return AIResponse(
        emotion: 'Stress',
        response:
            "It seems like you're mentally exhausted. You don't need to solve everything right now. Try focusing on one small task or take a short break.",
      );
    }

    if (_containsAny(text, ['angry', 'frustrated', 'irritated'])) {
      return AIResponse(
        emotion: 'Anger',
        response:
            "It looks like you're feeling frustrated. Taking a pause and slowing your breathing can help you regain clarity before reacting.",
      );
    }

    if (_containsAny(text, ['confused', 'lost', 'uncertain'])) {
      return AIResponse(
        emotion: 'Confusion',
        response:
            "Feeling unsure is completely normal. You don't need all the answers right now — just take the next small step.",
      );
    }

    return AIResponse(
      emotion: 'Neutral',
      response:
          "Thank you for sharing this. I'm here to listen. Would you like to tell me more about what you're experiencing?",
    );
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((word) => text.contains(word));
  }
}
