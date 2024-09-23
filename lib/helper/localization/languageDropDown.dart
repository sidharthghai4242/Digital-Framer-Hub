class Language {
  final int id;
  final String flag;
  final String name,defaultLanguage;
  final String languageCode;

  Language(this.id, this.flag, this.defaultLanguage, this.name, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(0, "🇺🇸", "(English)","English", "en"),
      Language(1, "in", "(Hindi)","Hindi", "hi"),
      Language(2, "in", "(Punjabi)","Punjabi", "pa"),

    ];
  }
}