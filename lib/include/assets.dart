import 'package:flutter/services.dart' show rootBundle;

class TerminalAssets {
  static const ASSETS_ROOT = 'assets';
  static const _IMAGES_ROOT = '$ASSETS_ROOT/images';
  static const BACKGROUND_IMAGE = '$_IMAGES_ROOT/sweet-space-background.png';
  static const _PROJECT_IMAGES_ROOT = '$_IMAGES_ROOT/projects';
  static projectImage(String filename) => '$_PROJECT_IMAGES_ROOT/$filename';

  static const _ICONS_ROOT = '$ASSETS_ROOT/icons';
  static const ICON_MIMINIZE = '$_ICONS_ROOT/minimize.png';
  static const ICON_MAXIMIZE = '$_ICONS_ROOT/maximize.png';
  static const ICON_CLOSE = '$_ICONS_ROOT/close.png';

  static const ICON_PROJECTS = '$_ICONS_ROOT/projects.svg';
  static const ICON_NEWS = '$_ICONS_ROOT/news.svg';
  static const ICON_PUBLICATIONS = '$_ICONS_ROOT/publications.svg';
  static const ICON_TERMINAL = '$_ICONS_ROOT/terminal.svg';
  static const ICON_CONTACT = '$_ICONS_ROOT/contact.svg';

  static const TEXT_ROOT = '$ASSETS_ROOT/text';
  static const _PROJECT_TEXT_ROOT = '$TEXT_ROOT/projects';
  static projectText(String filename) => '$_PROJECT_TEXT_ROOT/$filename';

  static Future<String> readText(String filename) async =>
      rootBundle.loadString(filename);

  static const URL_TWITTER = 'https://www.twitter.com/disti150';
  static const URL_GITHUB = 'https://www.github.com/diegoroyo';
  static const URL_LINKEDIN = 'https://www.linkedin.com/in/diegorm';
}
