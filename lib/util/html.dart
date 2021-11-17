// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void openUrl(String url) {
  html.window.open(url, '_blank');
}
