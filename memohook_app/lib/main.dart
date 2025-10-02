import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'core/config/environment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Optional .env not found; defaults will apply.
    }
  }

  final useFirestore = _resolveBool(
    EnvKeys.useFirestore,
    fallback: EnvDefaults.useFirestore,
  );
  final useGemini = _resolveBool(
    EnvKeys.useGemini,
    fallback: EnvDefaults.useGemini,
  );
  final useSpeechToText = _resolveBool(
    EnvKeys.useSpeechToText,
    fallback: EnvDefaults.useSpeechToText,
  );

  if (useFirestore) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on UnimplementedError {
      // Configuration missing. Continue with mock repository.
    }
  }

  runApp(
    MemohookApp(
      useFirestore: useFirestore,
      useGemini: useGemini,
      useSpeechToText: useSpeechToText,
      geminiApiKey: dotenv.maybeGet(EnvKeys.geminiApiKey),
    ),
  );
}

bool _resolveBool(String key, {required bool fallback}) {
  final envValue = kIsWeb ? null : dotenv.maybeGet(key);
  if (envValue != null) {
    return parseEnvBool(envValue, fallback: fallback);
  }
  final webValue = String.fromEnvironment(key);
  if (webValue.isNotEmpty) {
    return parseEnvBool(webValue, fallback: fallback);
  }
  return fallback;
}
