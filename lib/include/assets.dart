import 'package:flutter/services.dart' show rootBundle;
import 'package:tuple/tuple.dart';

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

  // ignore: non_constant_identifier_names
  static final Map<String, Tuple2<String, String>> PROJECT_MAP = {
    'super-mario-kart': //
        Tuple2('Süper Mario Kart', projectText('super-mario-kart.txt')),
    'flowvid': //
        Tuple2('flowvid', projectText('flowvid.txt')),
    'path-tracing-and-photon-mapping': //
        Tuple2('Path tracing & photon mapping',
            projectText('graphics-course.txt')),
    'miora': //
        Tuple2('Miora - reserva donde quieras', projectText('miora.txt')),
    'futbuteo': //
        Tuple2('Futbuteo', projectText('futbuteo.txt')),
    'cookie-clicker-clone': //
        Tuple2('Cookie Clicker clone', projectText('cookie-clicker.txt')),
    'terminal': //
        Tuple2('terminal.diego.contact', projectText('terminal.txt')),
    'view-my-satellites': //
        Tuple2('View my satellites', projectText('view-my-satellites.txt')),
    'move-my-banana': //
        Tuple2('Move my banana', projectText('move-my-banana.txt')),
  };
  static Tuple2<String, String>? projectFromRoute(String route) =>
      PROJECT_MAP[route];

  static Future<String> readText(String filename) async =>
      rootBundle.loadString(filename);

  static const URL_TWITTER = 'https://www.twitter.com/disti150';
  static const URL_GITHUB = 'https://www.github.com/diegoroyo';
  static const URL_LINKEDIN = 'https://www.linkedin.com/in/diegorm';
}
