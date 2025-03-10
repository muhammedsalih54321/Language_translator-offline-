// ignore: file_names
import 'package:google_mlkit_translation/google_mlkit_translation.dart';


  /// List of available languages
  final List<TranslateLanguage> languages = [
    TranslateLanguage.afrikaans,
    TranslateLanguage.albanian,
    TranslateLanguage.arabic,
    TranslateLanguage.belarusian,
    TranslateLanguage.bengali,
    TranslateLanguage.bulgarian,
    TranslateLanguage.catalan,
    TranslateLanguage.chinese,
    TranslateLanguage.croatian,
    TranslateLanguage.czech,
    TranslateLanguage.danish,
    TranslateLanguage.dutch,
    TranslateLanguage.english,
    TranslateLanguage.esperanto,
    TranslateLanguage.estonian,
    TranslateLanguage.finnish,
    TranslateLanguage.french,
    TranslateLanguage.galician,
    TranslateLanguage.georgian,
    TranslateLanguage.german,
    TranslateLanguage.greek,
    TranslateLanguage.gujarati,
    TranslateLanguage.haitian,
    TranslateLanguage.hebrew,
    TranslateLanguage.hindi,
    TranslateLanguage.hungarian,
    TranslateLanguage.icelandic,
    TranslateLanguage.indonesian,
    TranslateLanguage.irish,
    TranslateLanguage.italian,
    TranslateLanguage.japanese,
    TranslateLanguage.kannada,
    TranslateLanguage.korean,
    TranslateLanguage.latvian,
    TranslateLanguage.lithuanian,
    TranslateLanguage.macedonian,
    TranslateLanguage.malay,
    TranslateLanguage.maltese,
    TranslateLanguage.marathi,
    TranslateLanguage.norwegian,
    TranslateLanguage.persian,
    TranslateLanguage.polish,
    TranslateLanguage.portuguese,
    TranslateLanguage.romanian,
    TranslateLanguage.russian,
    TranslateLanguage.slovak,
    TranslateLanguage.slovenian,
    TranslateLanguage.spanish,
    TranslateLanguage.swahili,
    TranslateLanguage.swedish,
    TranslateLanguage.tagalog,
    TranslateLanguage.tamil,
    TranslateLanguage.telugu,
    TranslateLanguage.thai,
    TranslateLanguage.turkish,
    TranslateLanguage.ukrainian,
    TranslateLanguage.urdu,
    TranslateLanguage.vietnamese,
    TranslateLanguage.welsh
  ];



String getLanguageCode(TranslateLanguage language) {
  switch (language) {
    case TranslateLanguage.afrikaans:
      return 'af-ZA';
    case TranslateLanguage.albanian:
      return 'sq-AL';
    case TranslateLanguage.arabic:
      return 'ar-SA';
    case TranslateLanguage.belarusian:
      return 'be-BY';
    case TranslateLanguage.bengali:
      return 'bn-BD';
    case TranslateLanguage.bulgarian:
      return 'bg-BG';
    case TranslateLanguage.catalan:
      return 'ca-ES';
    case TranslateLanguage.chinese:
      return 'zh-CN';
    case TranslateLanguage.croatian:
      return 'hr-HR';
    case TranslateLanguage.czech:
      return 'cs-CZ';
    case TranslateLanguage.danish:
      return 'da-DK';
    case TranslateLanguage.dutch:
      return 'nl-NL';
    case TranslateLanguage.english:
      return 'en-US';
    case TranslateLanguage.esperanto:
      return 'eo-EO';
    case TranslateLanguage.estonian:
      return 'et-EE';
    case TranslateLanguage.finnish:
      return 'fi-FI';
    case TranslateLanguage.french:
      return 'fr-FR';
    case TranslateLanguage.galician:
      return 'gl-ES';
    case TranslateLanguage.georgian:
      return 'ka-GE';
    case TranslateLanguage.german:
      return 'de-DE';
    case TranslateLanguage.greek:
      return 'el-GR';
    case TranslateLanguage.gujarati:
      return 'gu-IN';
    case TranslateLanguage.haitian:
      return 'ht-HT';
    case TranslateLanguage.hebrew:
      return 'he-IL';
    case TranslateLanguage.hindi:
      return 'hi-IN';
    case TranslateLanguage.hungarian:
      return 'hu-HU';
    case TranslateLanguage.icelandic:
      return 'is-IS';
    case TranslateLanguage.indonesian:
      return 'id-ID';
    case TranslateLanguage.irish:
      return 'ga-IE';
    case TranslateLanguage.italian:
      return 'it-IT';
    case TranslateLanguage.japanese:
      return 'ja-JP';
    case TranslateLanguage.kannada:
      return 'kn-IN';
    case TranslateLanguage.korean:
      return 'ko-KR';
    case TranslateLanguage.latvian:
      return 'lv-LV';
    case TranslateLanguage.lithuanian:
      return 'lt-LT';
    case TranslateLanguage.macedonian:
      return 'mk-MK';
    case TranslateLanguage.malay:
      return 'ms-MY';
    case TranslateLanguage.maltese:
      return 'mt-MT';
    case TranslateLanguage.marathi:
      return 'mr-IN';
    case TranslateLanguage.norwegian:
      return 'no-NO';
    case TranslateLanguage.persian:
      return 'fa-IR';
    case TranslateLanguage.polish:
      return 'pl-PL';
    case TranslateLanguage.portuguese:
      return 'pt-PT';
    case TranslateLanguage.romanian:
      return 'ro-RO';
    case TranslateLanguage.russian:
      return 'ru-RU';
    case TranslateLanguage.slovak:
      return 'sk-SK';
    case TranslateLanguage.slovenian:
      return 'sl-SI';
    case TranslateLanguage.spanish:
      return 'es-ES';
    case TranslateLanguage.swahili:
      return 'sw-KE';
    case TranslateLanguage.swedish:
      return 'sv-SE';
    case TranslateLanguage.tagalog:
      return 'tl-PH';
    case TranslateLanguage.tamil:
      return 'ta-IN';
    case TranslateLanguage.telugu:
      return 'te-IN';
    case TranslateLanguage.thai:
      return 'th-TH';
    case TranslateLanguage.turkish:
      return 'tr-TR';
    case TranslateLanguage.ukrainian:
      return 'uk-UA';
    case TranslateLanguage.urdu:
      return 'ur-PK';
    case TranslateLanguage.vietnamese:
      return 'vi-VN';
    case TranslateLanguage.welsh:
      return 'cy-GB';
    // Default to English
  }
}
