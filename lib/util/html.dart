import 'package:url_launcher/url_launcher_string.dart';

String addBaseUrl(String url) {
  String base =
      Uri.base.toString().replaceFirst(RegExp('${Uri.base.path}\$'), '');
  return '$base$url';
}

void openUrl(String url) async {
  canLaunchUrlString(url).then((valid) {
    if (valid) {
      launchUrlString(url);
    }
  });
}
