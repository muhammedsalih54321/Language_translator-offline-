import 'package:clipboard/clipboard.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language_translator/Provider/provider_class2.dart';
import 'package:language_translator/components/Language_list.dart';
import 'package:language_translator/components/Toast_message.dart';
import 'package:provider/provider.dart';

class CameratranslatorScreen extends StatefulWidget {
  const CameratranslatorScreen({super.key});

  @override
  State<CameratranslatorScreen> createState() => _CameratranslatorScreenState();
}

class _CameratranslatorScreenState extends State<CameratranslatorScreen> {
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final translatorProvider =
        Provider.of<CameraTranslatorProvider>(context, listen: false);

    // Clear data when the page is reopened
    translatorProvider.clearData(); 

    // Reinitialize languages to default selections
    translatorProvider.setSourceLanguage(TranslateLanguage.english);
    translatorProvider.setTargetLanguage(TranslateLanguage.spanish);
  });
}


  @override
  Widget build(BuildContext context) {
    final translatorProvider = Provider.of<CameraTranslatorProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        leading: IconButton(
          onPressed: () { Navigator.pop(context);
          translatorProvider.clearData();
          },
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
                child: translatorProvider.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Image.file(
                          translatorProvider.image!,
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
                    _buildLanguageDropdown(true, context),
                    GestureDetector(
                      onTap:()=> translatorProvider.swapLanguages(),
                      child: Icon(BootstrapIcons.arrow_left_right),
                    ),
                    _buildLanguageDropdown(false, context),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Buttons for image selection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconButton(Icons.photo_library,
                      () => translatorProvider.getImage(ImageSource.gallery)),
                  SizedBox(width: 50.w),
                  _buildIconButton(Icons.camera_alt,
                      () => translatorProvider.getImage(ImageSource.camera)),
                ],
              ),
              SizedBox(height: 20.h),

              // Extracted text
              _buildTextContainer(
                  "Extracted Text",
                  translatorProvider.extractedText,
                  translatorProvider.speakExtractedText,
                  translatorProvider.isSpeakingExtracted,
                  translatorProvider.stopSpeakingExtracted),
              SizedBox(height: 20.h),

              // Translated text
              _buildTextContainer(
                  "Translated Text",
                  translatorProvider.translatedText,
                  translatorProvider.speakTranslatedText,
                  translatorProvider.isSpeakingTranslated,
                  translatorProvider.stopSpeakingTranslated),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Dropdown for language selection
Widget _buildLanguageDropdown(bool isSource, BuildContext context) {
  final translatorProvider = Provider.of<CameraTranslatorProvider>(context);

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
          scrollbarTheme: const ScrollbarThemeData(),
        ),
        value: isSource
            ? translatorProvider.sourceLanguage
            : translatorProvider.targetLanguage,
        isExpanded: true,
        alignment: Alignment.centerLeft,
       onChanged: (TranslateLanguage? newValue) {
  if (newValue != null) {
    final translatorProvider = Provider.of<CameraTranslatorProvider>(context, listen: false);

    if (isSource) {
      translatorProvider.setSourceLanguage(newValue);
      translatorProvider.setupTTS(getLanguageCode(translatorProvider.sourceLanguage));
    } else {
      translatorProvider.setTargetLanguage(newValue);
      translatorProvider.setupTTS(getLanguageCode(translatorProvider.targetLanguage));
    }

    // ❌ REMOVE THIS LINE: translatorProvider.swapLanguages();
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
                      color: Colors.blueAccent, size: 17.w),
                  SizedBox(width: 8.w),
                  Text(
                    lang.name.toUpperCase(),
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

  Widget _buildTextContainer(String title, String text, VoidCallback onSpeak,
      bool isSpeaking, VoidCallback stopSpeaking) {
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
                  height: 15.h,
                ),
                Text("$text", style: GoogleFonts.poppins(fontSize: 16.sp))
              ],
            ),
            Positioned(
              right: -10,
              top: -10.h,
              child: Row(
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
                      onPressed: isSpeaking ? stopSpeaking : onSpeak),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
