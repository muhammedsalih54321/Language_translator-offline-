// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:language_translator/Provider/provider_class.dart';
import 'package:language_translator/UI/History_screen.dart';
import 'package:language_translator/UI/cameratranslator_screen.dart';
import 'package:language_translator/components/Language_list.dart';
import 'package:language_translator/components/Toast_message.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
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
          value: isSource
              ? Provider.of<TranslationProvider>(context).sourceLanguage
              : Provider.of<TranslationProvider>(context).targetLanguage,
          isExpanded: true,
          alignment: Alignment.centerLeft,
          onChanged: (TranslateLanguage? newValue) {
            if (newValue != null) {
              final translationProvider =
                  Provider.of<TranslationProvider>(context, listen: false);

              if (isSource) {
                translationProvider.sourceLanguage = newValue;
              } else {
                translationProvider.targetLanguage = newValue;
              }

              translationProvider.onDeviceTranslator.close();
              translationProvider.initializeTranslator();

              // ignore: invalid_use_of_protected_member
              translationProvider.notifyListeners(); // Ensure UI updates
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
    final translationProvider = Provider.of<TranslationProvider>(context);
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
                      onTap: translationProvider.swapLanguages,
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
                            Text(translationProvider.sourceLanguage.name,
                                style: GoogleFonts.poppins(
                                    color: Color(0xFF003366))),
                            GestureDetector(
                              onTap: translationProvider.clearText,
                              child: Icon(Icons.close, color: Colors.black),
                            ),
                          ],
                        ),
                        TextFormField(
                          onChanged: (value) {
                            setState(() {});
                          },
                          controller: translationProvider.translatorController,
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
                                FlutterClipboard.copy(translationProvider
                                        .translatorController.text)
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
                                translationProvider.isSpeaking1
                                    ? BootstrapIcons.stop_circle
                                    : BootstrapIcons.volume_down,
                                size: 35.sp,
                              ),
                              onPressed:
                                  translationProvider.sourcespeakTranslation,
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
                      onPressed: translationProvider.isListening
                          ? translationProvider.stopListening
                          : translationProvider.startListening,
                      backgroundColor: translationProvider.isListening
                          ? Colors.red
                          : Colors.blue,
                      child: Icon(
                          translationProvider.isListening
                              ? BootstrapIcons.stop_fill
                              : BootstrapIcons.mic_fill,
                          color: Colors.white),
                    ),
                    ElevatedButton(
                      onPressed: translationProvider.translateText,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      child: translationProvider.isTranslating
                          ? const CircularProgressIndicator()
                          : const Text('Translate'),
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
                        Text(translationProvider.targetLanguage.name,
                            style:
                                GoogleFonts.poppins(color: Color(0xFF003366))),
                        SizedBox(height: 10.h),
                        Text(
                          translationProvider.isTranslating
                              ? "Translating..." // 🟠 Show Loading Text
                              : translationProvider.translatedText,
                          style: GoogleFonts.poppins(fontSize: 16.sp),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(BootstrapIcons.copy),
                              onPressed: () {
                                FlutterClipboard.copy(
                                        translationProvider.translatedText)
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
                                translationProvider.isSpeaking2
                                    ? BootstrapIcons.stop_circle
                                    : BootstrapIcons.volume_down,
                                size: 35.sp,
                              ),
                              onPressed:
                                  translationProvider.targetspeakTranslation,
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
