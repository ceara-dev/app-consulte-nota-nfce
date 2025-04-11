import 'package:flutter/material.dart';
import '../pages/home/home_page.dart';

class Routes {
  static final List<Map<String, dynamic>> _routeDefinitions = [
    {'name': '/', 'widget': const HomePage()},
  ];

  static Map<String, Widget Function(BuildContext)> routes = {
    for (var route in _routeDefinitions)
      route['name']: (context) => route['widget'] as Widget,
  };
}
