// lib/common/widgets/responsive_layout.dart
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // If width is more than 1100, we consider it a desktop
    if (size.width >= 1100 && desktop != null) {
      return desktop!;
    }

    // If width is more than 650, we consider it a tablet
    else if (size.width >= 650 && tablet != null) {
      return tablet!;
    }

    // Otherwise, we return the mobile layout
    else {
      return mobile;
    }
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final bool centerHorizontally;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.maxWidth = 1200.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.centerHorizontally = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool visibleOnMobile;
  final bool visibleOnTablet;
  final bool visibleOnDesktop;
  final Widget? replacement;

  const ResponsiveVisibility({
    Key? key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
    this.replacement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool isVisible = false;

    if (size.width >= 1100) {
      isVisible = visibleOnDesktop;
    } else if (size.width >= 650) {
      isVisible = visibleOnTablet;
    } else {
      isVisible = visibleOnMobile;
    }

    return isVisible ? child : (replacement ?? const SizedBox.shrink());
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileCrossAxisCount;
  final int tabletCrossAxisCount;
  final int desktopCrossAxisCount;
  final double childAspectRatio;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.mobileCrossAxisCount = 1,
    this.tabletCrossAxisCount = 2,
    this.desktopCrossAxisCount = 3,
    this.childAspectRatio = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int crossAxisCount;

    if (ResponsiveLayout.isDesktop(context)) {
      crossAxisCount = desktopCrossAxisCount;
    } else if (ResponsiveLayout.isTablet(context)) {
      crossAxisCount = tabletCrossAxisCount;
    } else {
      crossAxisCount = mobileCrossAxisCount;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
