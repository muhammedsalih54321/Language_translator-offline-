import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language_translator/components/Language_list.dart';
import 'package:language_translator/components/Toast_message.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class CameratranslatorScreen extends StatefulWidget {
  const CameratranslatorScreen({super.key});

  @override
  State<CameratranslatorScreen> createState() => _CameratranslatorScreenState();
}

class _CameratranslatorScreenState extends State<CameratranslatorScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _extractedText = "Extracted text will appear here";
  String _translatedText = "Translation will appear here";
  late OnDeviceTranslator _translator;
  final TextRecognizer _textRecognizer = TextRecognizer();
  late FlutterTts flutterTts;
  late stt.SpeechToText speechToText;
    bool isSpeakingExtracted = false; // 🔹 For Extracted Text
  bool isSpeakingTranslated = false; // 🔹 For Translated Text

  // Language selection
  TranslateLanguage sourceLanguage = TranslateLanguage.english;
  TranslateLanguage targetLanguage = TranslateLanguage.spanish;

  @override
  void initState() {
    super.initState();
    _initializeTranslator();
    flutterTts = FlutterTts();
    setupTTS(getLanguageCode(targetLanguage));
    speechToText = stt.SpeechToText();
  }

  void _initializeTranslator() {
    _translator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }

  // 🟢 Setup TTS with improvements
  Future<void> setupTTS(String languageCode) async {
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts
        .awaitSpeakCompletion(true); // Ensure TTS completes before continuing
  }

  // Speak Extracted Text
  void speakExtractedText() async {
    if (_extractedText.isNotEmpty) {
      setState(() => isSpeakingExtracted = true); // Show stop icon
      List<String> textChunks = _splitText(_extractedText);
      for (String chunk in textChunks) {
        if (!isSpeakingExtracted) break; // Stop speaking if user presses stop
        await flutterTts.speak(chunk);
      }
      setState(
          () => isSpeakingExtracted = false); // Revert to volume icon after speaking
    } else {
      ToastMessage().toastmessage(message: "No extracted text to speak.");
    }
  }

  // Speak Translated Text
  void speakTranslatedText() async {
    if (_translatedText.isNotEmpty) {
      setState(() => isSpeakingTranslated = true); // Show stop icon
      List<String> textChunks = _splitText(_translatedText);
      for (String chunk in textChunks) {
        if (!isSpeakingTranslated) break; // Stop speaking if user presses stop
        await flutterTts.speak(chunk);
      }
      setState(
          () => isSpeakingTranslated = false); // Revert to volume icon after speaking
    } else {
      ToastMessage().toastmessage(message: "No translated text to speak.");
    }
  }

//stop speaking

  void stopSpeakingExtracted() async {
    await flutterTts.stop();
    setState(() => isSpeakingExtracted = false);
  }

  void stopSpeakingTranslated() async {
    await flutterTts.stop();
    setState(() => isSpeakingTranslated = false);
  }

// 🔄 Utility Function for Splitting Long Text
  List<String> _splitText(String text) {
    const int maxChunkLength = 400; // TTS chunk limit for better results
    List<String> chunks = [];
    for (int i = 0; i < text.length; i += maxChunkLength) {
      chunks.add(text.substring(i,
          i + maxChunkLength > text.length ? text.length : i + maxChunkLength));
    }
    return chunks;
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _translator.close();
    super.dispose();
  }

  /// Function to pick an image from gallery or camera
  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile =
          await _picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _extractedText = "Extracting text...";
          _translatedText = "Translating...";
        });

        await _extractTextFromImage(_image!);
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  /// Swap Functionality
  void swapLanguages() {
    setState(() {
      TranslateLanguage temp = sourceLanguage;
      sourceLanguage = targetLanguage;
      targetLanguage = temp;

      _translator.close(); // Dispose of old translator
      _initializeTranslator(); // Reinitialize with new languages
    });
  }

  /// Extract text from image
  Future<void> _extractTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);
      String extractedText = recognizedText.text.isNotEmpty
          ? recognizedText.text
          : "No text found!";

      setState(() {
        _extractedText = extractedText;
      });

      if (extractedText.isNotEmpty) {
        await _translateText(extractedText);
      }
    } catch (e) {
      setState(() {
        _extractedText = "Error extracting text: $e";
      });
    }
  }

  /// Translate extracted text
  Future<void> _translateText(String text) async {
    try {
      final translatedText = await _translator.translateText(text);
      setState(() {
        _translatedText = translatedText;
      });
    } catch (e) {
      setState(() {
        _translatedText = "Error translating text: $e";
      });
    }
  }

  /// Utility Function for TTS Language Code Conversion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Camera Translator',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10.h),
              // Image display
              Container(
                height: 380.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.image,
                          size: 80.sp,
                          color: Colors.white54,
                        ),
                      ),
              ),
              SizedBox(height: 20.h),

              // Language selection UI
              Container(
                width: double.infinity,
                height: 50.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLanguageDropdown(true),
                    GestureDetector(
                      onTap: swapLanguages,
                      child: Icon(BootstrapIcons.arrow_left_right),
                    ),
                    _buildLanguageDropdown(false),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Buttons for image selection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconButton(Icons.photo_library,
                      () => _getImage(ImageSource.gallery)),
                  SizedBox(width: 50.w),
                  _buildIconButton(
                      Icons.camera_alt, () => _getImage(ImageSource.camera)),
                ],
              ),
              SizedBox(height: 20.h),

              // Extracted text
              _buildTextContainer(
                  "Extracted Text", _extractedText, speakExtractedText,isSpeakingExtracted),
              SizedBox(height: 20.h),

              // Translated text
              _buildTextContainer(
                  "Translated Text", _translatedText, speakTranslatedText,isSpeakingTranslated),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Dropdown for language selection
  Widget _buildLanguageDropdown(bool isSource) {
    return Container(
      width: 170.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.black26),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4.r, spreadRadius: 1.r)
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<TranslateLanguage>(
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200.h,
            width: 170.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.white,
            ),
            offset: const Offset(-10, 0),
            scrollbarTheme: ScrollbarThemeData(),
          ),
          value: isSource ? sourceLanguage : targetLanguage,
          isExpanded: true,
          alignment: Alignment.centerLeft,
          onChanged: (TranslateLanguage? newValue) {
            if (newValue != null) {
              setState(() {
                if (isSource) {
                  sourceLanguage = newValue;
                  setupTTS(getLanguageCode(
                      sourceLanguage)); // 🔄 Reinitialize TTS for new source language
                } else {
                  targetLanguage = newValue;
                  setupTTS(getLanguageCode(
                      targetLanguage)); // 🔄 Reinitialize TTS for new target language
                }

                _translator.close();
                _initializeTranslator();
              });
            }
          },
          items: languages.map((lang) {
            return DropdownMenuItem(
              value: lang,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(Icons.language,
                        color: Colors.blueAccent, size: 17.w), // Language icon
                    SizedBox(width: 8.w),
                    Text(
                      lang.name.toUpperCase(), // Capitalized for better look
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          menuItemStyleData: MenuItemStyleData(
            height: 40.h,
            padding: EdgeInsets.only(left: 14.w, right: 14.w),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: const Color(0xFF003366),
        ),
        height: 60.h,
        width: 60.w,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildTextContainer(String title, String text, VoidCallback onSpeak,bool isSpeaking) {
    return Container(
      width: double.infinity.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6.r, spreadRadius: 2.r)
        ],
      ),
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.h,
                ),
                Text("$title:",
                    style: GoogleFonts.poppins(
                        fontSize: 19.sp, fontWeight: FontWeight.w600)),
                SizedBox(
                  height: 25.h,
                ),
                Text("$text", style: GoogleFonts.poppins(fontSize: 16.sp))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(BootstrapIcons.copy),
                  onPressed: () {
                    FlutterClipboard.copy(text).then(
                      (value) {
                        ToastMessage().toastmessage(message: 'Copied');
                      },
                    );
                  },
                ),
                 IconButton(
                  icon: Icon(
                    isSpeaking
                        ? BootstrapIcons.stop_circle
                        : BootstrapIcons.volume_down,
                    size: 35.sp,
                  ),
                  onPressed: isSpeaking
                      ? (title == "Extracted Text"
                          ? stopSpeakingExtracted
                          : stopSpeakingTranslated)
                      : onSpeak,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
