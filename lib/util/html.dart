import 'package:url_launcher/url_launcher.dart';

void openUrl(String url) async {
  canLaunch(url).then((valid) {
    if (valid) {
      launch(url);
    }
  });
}
