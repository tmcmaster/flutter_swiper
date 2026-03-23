import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class SwiperControl extends SwiperPlugin {
  /// IconData for previous
  final IconData iconPrevious;

  /// IconData for next
  final IconData iconNext;

  /// Icon size
  final double size;

  /// Icon normal color, defaults to Theme.of(context).primaryColor
  final Color? color;

  /// Color used when loop = false and swiper is at the last slide,
  /// defaults to Theme.of(context).disabledColor
  final Color? disableColor;

  final EdgeInsetsGeometry padding;

  final Key? key;

  const SwiperControl({
    this.iconPrevious = Icons.arrow_back_ios,
    this.iconNext = Icons.arrow_forward_ios,
    this.color,
    this.disableColor,
    this.key,
    this.size = 30.0,
    this.padding = const EdgeInsets.all(5.0),
  });

  Widget buildButton(SwiperPluginConfig config, Color color, IconData iconData,
      int quarterTurns, bool previous) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (previous) {
          config.controller.previous(animation: true);
        } else {
          config.controller.next(animation: true);
        }
      },
      child: Padding(
        padding: padding,
        child: RotatedBox(
          quarterTurns: quarterTurns,
          child: Icon(
            iconData,
            semanticLabel: previous ? "Previous" : "Next",
            size: size,
            color: color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    final themeData = Theme.of(context);
    final Color effectiveColor = color ?? themeData.primaryColor;
    final Color effectiveDisableColor = disableColor ?? themeData.disabledColor;

    final bool canGoNext = config.activeIndex < config.itemCount - 1;
    final bool canGoPrev = config.activeIndex > 0;

    final Color prevColor =
        config.loop || canGoPrev ? effectiveColor : effectiveDisableColor;
    final Color nextColor =
        config.loop || canGoNext ? effectiveColor : effectiveDisableColor;

    Widget child;
    if (config.scrollDirection == Axis.horizontal) {
      child = Row(
        key: key,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildButton(config, prevColor, iconPrevious, 0, true),
          buildButton(config, nextColor, iconNext, 0, false),
        ],
      );
    } else {
      child = Column(
        key: key,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildButton(config, prevColor, iconPrevious, 3,
              true), // Changed -3 to 3, negative quarterTurns not valid
          buildButton(config, nextColor, iconNext, 3, false),
        ],
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: child,
    );
  }
}
