import 'package:flutter/material.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class FractionPaginationBuilder extends SwiperPlugin {
  /// Color, if null, defaults to Theme.of(context).scaffoldBackgroundColor
  final Color? color;

  /// Active color, if null, defaults to Theme.of(context).primaryColor
  final Color? activeColor;

  /// Font size
  final double fontSize;

  /// Active font size
  final double activeFontSize;

  final Key? key;

  const FractionPaginationBuilder({
    this.color,
    this.fontSize = 20.0,
    this.key,
    this.activeColor,
    this.activeFontSize = 35.0,
  });

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    final themeData = Theme.of(context);
    final activeColor = this.activeColor ?? themeData.primaryColor;
    final color = this.color ?? themeData.scaffoldBackgroundColor;

    if (config.scrollDirection == Axis.vertical) {
      return Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${config.activeIndex + 1}',
            style: TextStyle(color: activeColor, fontSize: activeFontSize),
          ),
          Text(
            '/',
            style: TextStyle(color: color, fontSize: fontSize),
          ),
          Text(
            '${config.itemCount}',
            style: TextStyle(color: color, fontSize: fontSize),
          ),
        ],
      );
    } else {
      return Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${config.activeIndex + 1}',
            style: TextStyle(color: activeColor, fontSize: activeFontSize),
          ),
          Text(
            ' / ${config.itemCount}',
            style: TextStyle(color: color, fontSize: fontSize),
          ),
        ],
      );
    }
  }
}

class RectSwiperPaginationBuilder extends SwiperPlugin {
  /// Active color, if null, defaults to Theme.of(context).primaryColor
  final Color? activeColor;

  /// Color, if null, defaults to Theme.of(context).scaffoldBackgroundColor
  final Color? color;

  /// Size of the rect when active
  final Size activeSize;

  /// Size of the rect
  final Size size;

  /// Space between rects
  final double space;

  final Key? key;

  const RectSwiperPaginationBuilder({
    this.activeColor,
    this.color,
    this.key,
    this.size = const Size(10.0, 2.0),
    this.activeSize = const Size(10.0, 2.0),
    this.space = 3.0,
  });

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    final themeData = Theme.of(context);
    final activeColor = this.activeColor ?? themeData.primaryColor;
    final color = this.color ?? themeData.scaffoldBackgroundColor;

    if (config.itemCount > 20) {
      debugPrint(
        "The itemCount is too big, consider using FractionPaginationBuilder instead of RectSwiperPaginationBuilder.",
      );
    }

    final itemCount = config.itemCount;
    final activeIndex = config.activeIndex;

    final list = List<Widget>.generate(itemCount, (i) {
      final active = i == activeIndex;
      final size = active ? activeSize : this.size;
      return SizedBox(
        width: size.width,
        height: size.height,
        child: Container(
          key: Key('pagination_$i'),
          margin: EdgeInsets.all(space),
          color: active ? activeColor : color,
        ),
      );
    });

    if (config.scrollDirection == Axis.vertical) {
      return Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    } else {
      return Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    }
  }
}

class DotSwiperPaginationBuilder extends SwiperPlugin {
  /// Active color, if null, defaults to Theme.of(context).primaryColor
  final Color? activeColor;

  /// Color, if null, defaults to Theme.of(context).scaffoldBackgroundColor
  final Color? color;

  /// Size of the dot when active
  final double activeSize;

  /// Size of the dot
  final double size;

  /// Space between dots
  final double space;

  final Key? key;

  const DotSwiperPaginationBuilder({
    this.activeColor,
    this.color,
    this.key,
    this.size = 10.0,
    this.activeSize = 10.0,
    this.space = 3.0,
  });

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    if (config.itemCount > 20) {
      debugPrint(
        "The itemCount is too big, consider using FractionPaginationBuilder instead of DotSwiperPaginationBuilder.",
      );
    }

    final themeData = Theme.of(context);
    final activeColor = this.activeColor ?? themeData.primaryColor;
    final color = this.color ?? themeData.scaffoldBackgroundColor;

    if (config.indicatorLayout != PageIndicatorLayout.NONE &&
        config.layout == SwiperLayout.DEFAULT) {
      return PageIndicator(
        count: config.itemCount,
        controller: config.pageController,
        layout: config.indicatorLayout,
        size: size,
        activeColor: activeColor,
        color: color,
        space: space,
      );
    }

    final itemCount = config.itemCount;
    final activeIndex = config.activeIndex;

    final list = List<Widget>.generate(itemCount, (i) {
      final active = i == activeIndex;
      return Container(
        key: Key('pagination_$i'),
        margin: EdgeInsets.all(space),
        child: ClipOval(
          child: Container(
            width: active ? activeSize : size,
            height: active ? activeSize : size,
            color: active ? activeColor : color,
          ),
        ),
      );
    });

    if (config.scrollDirection == Axis.vertical) {
      return Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    } else {
      return Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    }
  }
}

typedef SwiperPaginationBuilder = Widget Function(
  BuildContext context,
  SwiperPluginConfig config,
);

class SwiperCustomPagination extends SwiperPlugin {
  final SwiperPaginationBuilder builder;

  SwiperCustomPagination({required this.builder});

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    return builder(context, config);
  }
}

class SwiperPagination extends SwiperPlugin {
  /// dot style pagination
  static const SwiperPlugin dots = DotSwiperPaginationBuilder();

  /// fraction style pagination
  static const SwiperPlugin fraction = FractionPaginationBuilder();

  /// rect style pagination
  static const SwiperPlugin rect = RectSwiperPaginationBuilder();

  /// Alignment.bottomCenter by default when scrollDirection == Axis.horizontal
  /// Alignment.centerRight by default when scrollDirection == Axis.vertical
  final Alignment? alignment;

  /// Distance between pagination and the container
  final EdgeInsetsGeometry margin;

  /// Build the widget
  final SwiperPlugin builder;

  final Key? key;

  const SwiperPagination({
    this.alignment,
    this.key,
    this.margin = const EdgeInsets.all(10.0),
    this.builder = SwiperPagination.dots,
  });

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    final alignment = this.alignment ??
        (config.scrollDirection == Axis.horizontal
            ? Alignment.bottomCenter
            : Alignment.centerRight);

    Widget child = Container(
      margin: margin,
      child: builder.build(context, config),
    );

    if (!config.outer) {
      child = Align(
        key: key,
        alignment: alignment,
        child: child,
      );
    }

    return child;
  }
}
