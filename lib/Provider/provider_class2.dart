import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language_translator/components/Language_list.dart';

class CameraTranslatorProvider with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  File? get image => _image;

  String _extractedText = "Extracted text will appear here";
  String get extractedText => _extractedText;

  String _translatedText = "Translation will appear here";
  String get translatedText => _translatedText;

  late OnDeviceTranslator _translator;
  late FlutterTts flutterTts;

  bool isSpeakingExtracted = false;
  bool isSpeakingTranslated = false;

  // Language selection
  TranslateLanguage sourceLanguage = TranslateLanguage.english;
  TranslateLanguage targetLanguage = TranslateLanguage.spanish;

  CameraTranslatorProvider() {
    _initializeTranslator();
    flutterTts = FlutterTts();
    setupTTS(getLanguageCode(targetLanguage));
  }

  void _initializeTranslator() {
    _translator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }

  Future<void> setupTTS(String languageCode) async {
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> getImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _extractedText = "Extracting text...";
        _translatedText = "Translating...";

        notifyListeners();
        await _extractTextFromImage(_image!);
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _extractTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final TextRecognizer textRecognizer = TextRecognizer();

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      String extractedText = recognizedText.text.isNotEmpty
          ? recognizedText.text
          : "No text found!";

      _extractedText = extractedText;

      if (extractedText.isNotEmpty) {
        await _translateText(extractedText);
      } else {
        _translatedText = "No translatable text found!";
      }
    } catch (e) {
      _extractedText = "Error extracting text: $e";
      _translatedText = "Translation failed: $e";
    } finally {
      textRecognizer.close();
      notifyListeners();
    }
  }

  Future<void> _translateText(String text) async {
    try {
      final translatedText = await _translator.translateText(text);
      _translatedText = translatedText;
    } catch (e) {
      _translatedText = "Error translating text: $e";
    }
    notifyListeners();
  }

  void swapLanguages() {
    TranslateLanguage temp = sourceLanguage;
    sourceLanguage = targetLanguage;
    targetLanguage = temp;

    _translator.close();
    _initializeTranslator();

    notifyListeners();
  }

  void speakExtractedText() async {
    if (_extractedText.isNotEmpty) {
      isSpeakingExtracted = true;
      notifyListeners();

      await flutterTts.speak(_extractedText);

      isSpeakingExtracted = false;
      notifyListeners();
    }
  }

  void speakTranslatedText() async {
    if (_translatedText.isNotEmpty) {
      isSpeakingTranslated = true;
      notifyListeners();

      await flutterTts.speak(_translatedText);

      isSpeakingTranslated = false;
      notifyListeners();
    }
  }

  void stopSpeakingExtracted() async {
    await flutterTts.stop();
    isSpeakingExtracted = false;
    notifyListeners();
  }

  void stopSpeakingTranslated() async {
    await flutterTts.stop();
    isSpeakingTranslated = false;
    notifyListeners();
  }

  void setSourceLanguage(TranslateLanguage newValue) {
    sourceLanguage = newValue;
    _initializeTranslator();  // 🔄 Reinitialize translator with updated source language
    notifyListeners();
  }

  void setTargetLanguage(TranslateLanguage newValue) {
    targetLanguage = newValue;
    _initializeTranslator();  // 🔄 Reinitialize translator with updated target language
    notifyListeners();
  }

  void clearData() {
    _image = null;  // Clear the old image
    _extractedText = "Extracted text will appear here";
    _translatedText = "Translation will appear here";

    _initializeTranslator(); // 🔄 Reset the translator as well
    notifyListeners();
  }

  @override
  void dispose() {
    _translator.close();
    flutterTts.stop();
    super.dispose();
  }
}
