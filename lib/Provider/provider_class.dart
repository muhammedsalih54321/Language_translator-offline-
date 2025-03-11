import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TranslationProvider extends ChangeNotifier {
  final TextEditingController translatorController = TextEditingController();
  String translatedText = "";
  bool isTranslating = false;
  bool isSpeaking1 = false;
  bool isSpeaking2 = false;
  bool isListening = false;

  late OnDeviceTranslator onDeviceTranslator;
  late FlutterTts flutterTts;
  late stt.SpeechToText speechToText;

  TranslateLanguage sourceLanguage = TranslateLanguage.english;
  TranslateLanguage targetLanguage = TranslateLanguage.german;

  TranslationProvider() {
    initializeTranslator();
    flutterTts = FlutterTts();
    speechToText = stt.SpeechToText();
    setupTTS();
    requestMicrophonePermission();
  }

  // Translator Initialization
  void initializeTranslator() {
    onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
    notifyListeners();
  }

  // Text-to-Speech Setup
  void setupTTS() async {
    await flutterTts.setLanguage(targetLanguage.name.toLowerCase());
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.awaitSpeakCompletion(true);
  }

  // 🎙️ Permission for Mic
  Future<void> requestMicrophonePermission() async {
    final status = await speechToText.hasPermission;
    if (!status) {
      await speechToText.initialize();
    }
  }

  // 🔄 Swap Language
  void swapLanguages() {
    TranslateLanguage temp = sourceLanguage;
    sourceLanguage = targetLanguage;
    targetLanguage = temp;
    initializeTranslator();
    notifyListeners();
  }

  // 🟢 Translate Text
  Future<void> translateText() async {
    if (translatorController.text.isEmpty) return;

    isTranslating = true;
    translatedText = "";
    notifyListeners();

    String result = await onDeviceTranslator.translateText(translatorController.text);
    translatedText = result;
    isTranslating = false;
    notifyListeners();

    saveTranslation(translatorController.text, result);
  }

  // 🔵 Save Translation to History (Hive)
  void saveTranslation(String original, String translated) async {
    var box = await Hive.openBox('translations');
    box.add({'input': original, 'output': translated});
  }

  // 🎤 Mic Functionality
  void startListening() async {
    bool available = await speechToText.initialize(
      onStatus: (status) {
        print("Speech Status: $status");
      },
      onError: (error) {
        print("Speech Error: $error");
      },
    );

    if (available) {
      isListening = true;
      notifyListeners();

      speechToText.listen(
        onResult: (result) {
          translatorController.text = result.recognizedWords;
          notifyListeners();
        },
        listenFor: const Duration(minutes: 1),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
      );
    } else {
      print("Speech recognition not available");
    }
  }

  void stopListening() async {
    await speechToText.stop();
    isListening = false;
    notifyListeners();
  }

  // 🔊 Speak Translation (TTS)
  void targetspeakTranslation() async {
    if (isSpeaking2) {
      stopSpeaking();
      return;
    }

    if (translatedText.isNotEmpty) {
      isSpeaking2 = true;
      notifyListeners();

      var result = await flutterTts.speak(translatedText);
      if (result != 1) print("❌ TTS Failed");

      isSpeaking2 = false;
      notifyListeners();
    }
  }

  void sourcespeakTranslation() async {
    if (isSpeaking1) {
      stopSpeaking();
      return;
    }

    if (translatorController.text.isNotEmpty) {
      isSpeaking1 = true;
      notifyListeners();

      var result = await flutterTts.speak(translatorController.text);
      if (result != 1) print("❌ TTS Failed");

      isSpeaking1 = false;
      notifyListeners();
    }
  }

  // Stop Speaking
  void stopSpeaking() async {
    await flutterTts.stop();
    isSpeaking1 = false;
    isSpeaking2 = false;
    notifyListeners();
  }

  // Clear Text
  void clearText() {
    translatorController.clear();
    translatedText = "";
    notifyListeners();
  }

  @override
  void dispose() {
    onDeviceTranslator.close();
    super.dispose();
  }
}
