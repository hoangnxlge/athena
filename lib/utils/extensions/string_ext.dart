extension StringExt on String {
  String toTitle() {
    if (isEmpty) return '';
    if (length == 1) return toUpperCase();
    return this[0].toUpperCase() + substring(1);
  }

  String camelToNormal() {
    RegExp regex = RegExp(r'(?<=[a-z])[A-Z]');
    String normalString =
        replaceAllMapped(regex, (match) => ' ${match.group(0)}');

    if (normalString.isEmpty) {
      return normalString;
    }

    String firstChar = normalString[0].toUpperCase();
    String restOfString = normalString.substring(1).toLowerCase();

    return '$firstChar$restOfString';
  }
}
