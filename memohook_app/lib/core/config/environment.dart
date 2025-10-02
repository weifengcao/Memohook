class EnvKeys {
  const EnvKeys._();

  static const useFirestore = 'USE_FIRESTORE';
  static const useGemini = 'USE_GEMINI';
  static const useSpeechToText = 'USE_SPEECH_TO_TEXT';
  static const geminiApiKey = 'GEMINI_API_KEY';
}

class EnvDefaults {
  const EnvDefaults._();

  static const useFirestore = false;
  static const useGemini = false;
  static const useSpeechToText = true;
}

bool parseEnvBool(String? value, {required bool fallback}) {
  if (value == null) {
    return fallback;
  }
  final normalized = value.trim().toLowerCase();
  return normalized == 'true' ||
      normalized == '1' ||
      normalized == 'yes' ||
      normalized == 'on';
}
