const junkWords = "دانلود فیلم مستند انیمیشن کارتون سریال";

final multiSpaceRegex = new RegExp(r"\s\s+");
String removeMultiSpaces(String s) {
  return s.replaceAll(multiSpaceRegex, " ");
}

String cleanTitle(String title) {
  if (title.isEmpty) return "";
  for (var word in junkWords.split(" ")) {
    title = title.replaceAll(word, "");
  }
  return removeMultiSpaces(title.trim());
}
