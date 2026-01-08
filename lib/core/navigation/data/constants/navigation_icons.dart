import 'package:flutter/material.dart';

class NavigationIcons {
  NavigationIcons._();

  static const IconData home = Icons.home;
  static const IconData eraser = Icons.content_cut;
  static const IconData profile = Icons.person;
  static const IconData history = Icons.history;
  static const IconData settings = Icons.settings;
  
  static IconData getIconByRoute(String route) {
    switch (route) {
      case '/home':
        return home;
      case '/eraser':
        return eraser;
      case '/profile':
        return profile;
      case '/history':
        return history;
      case '/settings':
        return settings;
      default:
        return home;
    }
  }
}

