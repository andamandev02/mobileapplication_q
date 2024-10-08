import 'package:flutter/material.dart';

class TabData extends InheritedWidget {
  final Map<String, dynamic> branches;
  final Map<String, dynamic> counters;
  final List<Map<String, dynamic>> countersd;

  const TabData({
    super.key,
    required this.branches,
    required this.counters,
    required this.countersd,
    required super.child,
  });

  static TabData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabData>();
  }

  @override
  bool updateShouldNotify(TabData oldWidget) {
    return branches != oldWidget.branches ||
        counters != oldWidget.counters ||
        countersd != oldWidget.countersd;
  }
}
