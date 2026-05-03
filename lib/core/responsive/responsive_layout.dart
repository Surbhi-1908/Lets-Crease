import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= 1200) {
      return desktop;
    } else if (screenWidth >= 768) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }
}

class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T desktop;
  
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    required this.desktop,
  });
  
  T getValue(BuildContext context) {
    if (ResponsiveLayout.isDesktop(context)) {
      return desktop;
    } else if (ResponsiveLayout.isTablet(context)) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }
}
