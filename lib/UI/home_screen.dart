import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:hive/hive.dart';
import 'package:language_translator/UI/History_screen.dart';
import 'package:language_translator/UI/cameratranslator_screen.dart';
import 'package:language_translator/components/Language_list.dart';
import 'package:language_translator/components/Toast_message.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController translatorController = TextEditingController();
  String translatedText = "";
  late OnDeviceTranslator onDeviceTranslator;
  late FlutterTts flutterTts;
  late stt.SpeechToText speechToText;
  bool isListening = false;
  String pasteValue = '';
  bool isSpeaking1 = false;
  bool isSpeaking2 = false;
  bool isTranslating = false;

  // 🟢 Store selected languages
  TranslateLanguage sourceLanguage = TranslateLanguage.english;
  TranslateLanguage targetLanguage = TranslateLanguage.german;

  @override
  void initState() {
    super.initState();
    initializeTranslator();
    flutterTts = FlutterTts();
    setupTTS();
    speechToText = stt.SpeechToText();
    requestMicrophonePermission();
  }

  void initializeTranslator() {
    onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }

  // 🟠 Swap Functionality
  void swapLanguages() {
    setState(() {
      // Swap source and target language
      TranslateLanguage temp = sourceLanguage;
      sourceLanguage = targetLanguage;
      targetLanguage = temp;

      // Re-initialize translator with new languages
      initializeTranslator();
    });
  }

//permission for mic
Future<void> requestMicrophonePermission() async {
  final status = await speechToText.hasPermission;
  if (!status) {
    await speechToText.initialize();
  }
}

// Initialize TTS properly
  void setupTTS() async {
    await flutterTts.setLanguage(
        targetLanguage.name.toLowerCase()); // Dynamic language selection
    await flutterTts.setSpeechRate(0.5); // Normal speaking rate
    await flutterTts.setVolume(1.0); // Max volume
    await flutterTts.setPitch(1.0); // Default pitch
    await flutterTts.awaitSpeakCompletion(true); // Ensure completion
  }

// Target text speak
  void targetspeakTranslation() async {
    if (isSpeaking2) {
      stopSpeaking(); // Stop if already speaking
      return;
    }

    if (translatedText.isNotEmpty) {
      setState(() => isSpeaking2 = true); // Show stop icon
      var result = await flutterTts.speak(translatedText);
      if (result == 1) {
        print("✅ TTS Success");
      } else {
        print("❌ TTS Failed");
      }
      setState(() => isSpeaking2 = false); // Revert to volume icon
    } else {
      ToastMessage().toastmessage(message: "No text to speak.");
    }
  }

  // Source text speak
  void sourcespeakTranslation() async {
    if (isSpeaking1) {
      stopSpeaking(); // Stop if already speaking
      return;
    }

    if (translatorController.text.isNotEmpty) {
      setState(() => isSpeaking1 = true); // Show stop icon
      var result = await flutterTts.speak(translatorController.text);
      if (result == 1) {
        print("✅ TTS Success");
      } else {
        print("❌ TTS Failed");
      }
      setState(() => isSpeaking1 = false); // Revert to volume icon
    } else {
      ToastMessage().toastmessage(message: "No text to speak.");
    }
  }

  // Stop Speaking
  void stopSpeaking() async {
    await flutterTts.stop();
    setState(() {
      isSpeaking1 = false;
      isSpeaking2 = false;
    });
  }

  @override
  void dispose() {
    onDeviceTranslator.close();
    super.dispose();
  }

  // 🟢 Function: Translate Text
  Future<void> translateText() async {
    if (translatorController.text.isEmpty) return;
    setState(() {
      isTranslating = true; // Show "Translating..." text
      translatedText = ""; // Clear previous result
    });

    String result =
        await onDeviceTranslator.translateText(translatorController.text);
    setState(() {
      translatedText = result;
      isTranslating = false; // Hide "Translating..." text
    });

    // Save to History
    saveTranslation(translatorController.text, result);
  }

  // 🔵 Function: Save Translation to History (Hive)
  void saveTranslation(String original, String translated) async {
    var box = await Hive.openBox('translations');
    box.add({'input': original, 'output': translated});
  }

  // 🟠 Function: Speak Translation (Text-to-Speech)

  // 🔴 Function: Start Voice Input (Speech-to-Text)
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
    setState(() => isListening = true);
    speechToText.listen(
      onResult: (result) {
        setState(() {
          translatorController.text = result.recognizedWords;
        });
      },
      listenFor: Duration(minutes: 1), // ✅ Ensures long listening sessions
      pauseFor: Duration(seconds: 3), // ✅ Prevents abrupt stopping
      localeId: 'en_US', // ✅ Ensures English as the default language
    );
  } else {
    ToastMessage().toastmessage(message: "Speech recognition not available");
  }
}


void stopListening() async {
  await speechToText.stop();
  setState(() => isListening = false);
}


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
                } else {
                  targetLanguage = newValue;
                }

                onDeviceTranslator.close();
                initializeTranslator();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        title: Text(
          'Language Translator',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () async {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => HistoryScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // 🌍 Language Selection UI
              Container(
                width: double.infinity.w,
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

              // 📝 Input Box
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 2.r)
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.w),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(sourceLanguage.name,
                                style: GoogleFonts.poppins(
                                    color: Color(0xFF003366))),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  translatorController.clear();
                                  translatedText = '';
                                });
                              },
                              child: Icon(Icons.close, color: Colors.black),
                            ),
                          ],
                        ),
                        TextFormField(
                          onChanged: (value) {
                            setState(() {});
                          },
                          controller: translatorController,
                          style: const TextStyle(color: Colors.black),
                          maxLines: null, // 🌟 Enables auto-expansion
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter text here...',
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(BootstrapIcons.copy),
                              onPressed: () {
                                FlutterClipboard.copy(translatorController.text)
                                    .then(
                                  (value) {
                                    ToastMessage()
                                        .toastmessage(message: 'Copied');
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                isSpeaking1
                                    ? BootstrapIcons.stop_circle
                                    : BootstrapIcons.volume_down,
                                size: 35.sp,
                              ),
                              onPressed: sourcespeakTranslation,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // 🎤 Mic Button & Translate Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FloatingActionButton(
                      onPressed: isListening ? stopListening : startListening,
                      backgroundColor: Colors.blue,
                      child: Icon(
                          isListening ? BootstrapIcons.stop_fill : BootstrapIcons.mic_fill,
                          color: Colors.white),
                    ),
                    ElevatedButton(
                      onPressed: translateText,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      child: const Text('Translate'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

// 📌 Output Box - Expanding Translated Text Container
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 2.r)
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(targetLanguage.name,
                            style:
                                GoogleFonts.poppins(color: Color(0xFF003366))),
                        SizedBox(height: 10.h),
                        Text(
                          isTranslating
                              ? "Translating..." // 🟠 Show Loading Text
                              : translatedText,
                          style: GoogleFonts.poppins(fontSize: 16.sp),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(BootstrapIcons.copy),
                              onPressed: () {
                                FlutterClipboard.copy(translatedText).then(
                                  (value) {
                                    ToastMessage()
                                        .toastmessage(message: 'Copied');
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                isSpeaking2
                                    ? BootstrapIcons.stop_circle
                                    : BootstrapIcons.volume_down,
                                size: 35.sp,
                              ),
                              onPressed: targetspeakTranslation,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 100.h,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => CameratranslatorScreen()));
        },
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: const Color(0xFF003366),
            ),
            height: 60.h,
            width: 60.w,
            child: Icon(
              BootstrapIcons.camera,
              color: Colors.white,
            )),
      ),
    );
  }
}
