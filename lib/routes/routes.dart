// routes/routes.dart
import 'package:flutter/material.dart';
import 'package:teste/pages/camera/camera_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/home/home_page.dart';

class Routes {
  static final List<Map<String, dynamic>> _routeDefinitions = [
    {'name': '/login', 'widget': const LoginPage()},
    {'name': '/home', 'widget': const HomePage()},
    {'name': '/camera', 'widget': const CameraPage()}
  ];

  static Map<String, Widget Function(BuildContext)> routes = {
    for (var route in _routeDefinitions)
      route['name']: (context) => route['widget'] as Widget,
  };
}
