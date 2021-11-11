import 'package:flutter/material.dart';
import 'package:terminal/screens/landing_screen.dart';

class Routes {
  static final routes = <String, dynamic>{
    /// LOADING SCREEN ///
    'landing': (settings) => _buildRoute(settings, LandingScreen()),
    // 'landing': (settings) => _buildRoute(
    //     settings, LandingScreen(emailSuggestion: settings.arguments)),
    // 'register-options': (settings) =>
    //     _buildRoute(settings, RegisterOptionsScreen()),
  };

  static Route<dynamic> getRoute(RouteSettings settings) {
    return routes[settings.name](settings);
  }

  static MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return MaterialPageRoute(
      settings: settings,
      builder: (ctx) => builder,
    );
  }
}
