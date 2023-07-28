import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/screens/landing_screen.dart';
import 'package:terminal/util/redirect_to.dart';
import 'package:terminal/util/window_callbacks.dart';
import 'package:tuple/tuple.dart';

typedef RouteFunc = Route<dynamic> Function(RouteSettings, List<WindowData>);
typedef SubRouteFunc = Tuple2<String, List<WindowData>> Function(String);

class Routes {
  static final routes = <String, RouteFunc>{
    '/': (settings, windows) =>
        _buildRoute(settings, LandingScreen(initialWindows: windows)),
  };

  static final subroutes = <String, SubRouteFunc>{
    '/projects': (route) {
      Tuple2? project = TerminalAssets.projectFromRoute(route);
      if (project != null) {
        return Tuple2('/', [
          WindowData.html(title: project.item1, htmlFilename: project.item2)
        ]);
      } else {
        return Tuple2('/', [
          WindowData.terminal(title: 'Projects', commands: ['cat projects.txt'])
        ]);
      }
    },
    '/publications': (route) {
      if (route.trim().isNotEmpty &&
          TerminalAssets.PUBLICATION_MAP.keys.contains(route)) {
        return Tuple2('/', [
          WindowData.terminal(
              title: 'Publications', commands: ['grep $route publications.txt'])
        ]);
      } else {
        return Tuple2('/', [
          WindowData.terminal(
              title: 'Publications', commands: ['cat publications.txt'])
        ]);
      }
    },
    '/news': (route) => Tuple2('/', [
          WindowData.terminal(title: 'News', commands: ['cat news.txt'])
        ]),
    '/credits': (route) => Tuple2('/', [
          WindowData.terminal(title: 'Credits', commands: ['cat credits.txt'])
        ]),
    '/terminal': (route) => Tuple2('/', [
          WindowData.terminal(title: 'Terminal', commands: ['help'])
        ]),
    '/contact': (route) => Tuple2('/', [
          WindowData.terminal(title: 'Contact', commands: ['neofetch'])
        ]),
  };

  static Tuple2? getWindowDataFromRoute(String route) {
    Tuple2? result;
    for (var entry in subroutes.entries) {
      if (route.startsWith(entry.key)) {
        var subsubroute = route
            .replaceFirst(RegExp('^${entry.key}/?'), '')
            .replaceFirst(RegExp(r'/$'), '');
        result = entry.value(subsubroute);
        break;
      }
    }
    return result;
  }

  static Route<dynamic> getRoute(RouteSettings settings) {
    // default data
    String route = settings.name ?? '/';
    List<WindowData> windows = [
      WindowData.terminal(
          title: 'About me', commands: ['neofetch', 'head news.txt -n 5']),
      WindowData.terminal(
          title: 'Publications', commands: ['cat publications.txt']),
    ];
    // check if its a subroute
    Tuple2? result = getWindowDataFromRoute(route);
    if (result != null) {
      route = result.item1;
      windows = result.item2;
    }
    if (routes.containsKey(route)) {
      return routes[route]!(settings, windows);
    } else {
      return _buildRoute(settings, Redirect(to: '/'));
    }
  }

  /// each page has its own ScreenshotController so images can be generated
  /// using the ScreenshotImage widget. At the moment of writing this, the
  /// website only has one screen: LandingScreen, but this (hopefully)
  /// makes screenshotting future-proof
  static var screenshotControllers = <int, ScreenshotController>{};

  static MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return MaterialPageRoute(
      settings: settings,
      builder: (ctx) => Screenshot(
          controller: screenshotControllers.putIfAbsent(
              builder.hashCode, () => ScreenshotController()),
          child: builder),
    );
  }
}
