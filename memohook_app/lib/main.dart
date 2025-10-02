import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'core/config/environment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Optional .env not found; defaults will apply.
  }

  final useFirestore = parseEnvBool(
    dotenv.maybeGet(EnvKeys.useFirestore),
    fallback: EnvDefaults.useFirestore,
  );
  final useGemini = parseEnvBool(
    dotenv.maybeGet(EnvKeys.useGemini),
    fallback: EnvDefaults.useGemini,
  );
  final useSpeechToText = parseEnvBool(
    dotenv.maybeGet(EnvKeys.useSpeechToText),
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
