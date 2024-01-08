import 'dart:math';

extension StringExtension on String {
  String title() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }

}
  String generateRandomString(int len) {
    var r = Random();
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
  }
