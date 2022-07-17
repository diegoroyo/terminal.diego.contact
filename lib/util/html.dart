import 'package:url_launcher/url_launcher.dart';

String addBaseUrl(String url) {
  String base =
      Uri.base.toString().replaceFirst(RegExp('${Uri.base.path}\$'), '');
  return '$base$url';
}

void openUrl(String url) async {
  canLaunch(url).then((valid) {
    if (valid) {
      launch(url);
    }
  });
}
