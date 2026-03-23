import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:transformer_page_view/transformer_page_view.dart';

part 'custom_layout.dart';

typedef void SwiperOnTap(int index);

typedef Widget SwiperDataBuilder(BuildContext context, dynamic data, int index);

/// default auto play delay
const int kDefaultAutoplayDelayMs = 3000;

///  Default auto play transition duration (in millisecond)
const int kDefaultAutoplayTransactionDuration = 300;

const int kMaxValue = 2000000000;
const int kMiddleValue = 1000000000;

enum SwiperLayout { DEFAULT, STACK, TINDER, CUSTOM }

class Swiper extends StatefulWidget {
  /// If set true, the pagination will display 'outer' of the 'content' container.
  final bool outer;

  /// Inner item height, valid if layout=STACK, TINDER or CUSTOM
  final double? itemHeight;

  /// Inner item width, valid if layout=STACK, TINDER or CUSTOM
  final double? itemWidth;

  /// Height of the inside container, valid when outer=true
  final double? containerHeight;

  /// Width of the inside container, valid when outer=true
  final double? containerWidth;

  /// Build item on index
  final IndexedWidgetBuilder itemBuilder;

  /// Support transform like Android PageView did
  /// `itemBuilder` and `transformer` must not both be null
  final PageTransformer? transformer;

  /// Count of the display items
  final int itemCount;

  final ValueChanged<int>? onIndexChanged;

  /// Auto play config
  final bool autoplay;

  /// Duration of the animation between transactions (in milliseconds)
  final int autoplayDelay;

  /// Disable auto play when interaction
  final bool autoplayDisableOnInteraction;

  /// Auto play transition duration (in milliseconds)
  final int duration;

  /// Horizontal/vertical scroll direction
  final Axis scrollDirection;

  /// Transition curve
  final Curve curve;

  /// Set to false to disable continuous loop mode.
  final bool loop;

  /// Index number of initial slide.
  /// If not set, the `Swiper` is 'uncontrolled', meaning index is managed internally.
  final int? index;

  /// Called when tap
  final SwiperOnTap? onTap;

  /// The swiper pagination plugin
  final SwiperPlugin? pagination;

  /// The swiper control button plugin
  final SwiperPlugin? control;

  /// Other plugins, you can custom your own plugin
  final List<SwiperPlugin>? plugins;

  /// Swiper controller
  final SwiperController? controller;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Viewport fraction
  final double viewportFraction;

  /// Built-in layouts
  final SwiperLayout layout;

  /// Valid when layout == SwiperLayout.CUSTOM
  final CustomLayoutOption? customLayoutOption;

  /// Valid when viewportFraction < 1.0
  final double? scale;

  /// Valid when viewportFraction < 1.0
  final double? fade;

  final PageIndicatorLayout indicatorLayout;

  const Swiper({
    Key? key,
    required this.itemBuilder,
    this.indicatorLayout = PageIndicatorLayout.NONE,
    this.transformer,
    required this.itemCount,
    this.autoplay = false,
    this.layout = SwiperLayout.DEFAULT,
    this.autoplayDelay = kDefaultAutoplayDelayMs,
    this.autoplayDisableOnInteraction = true,
    this.duration = kDefaultAutoplayTransactionDuration,
    this.onIndexChanged,
    this.index,
    this.onTap,
    this.control,
    this.loop = true,
    this.curve = Curves.ease,
    this.scrollDirection = Axis.horizontal,
    this.pagination,
    this.plugins,
    this.physics,
    this.controller,
    this.customLayoutOption,
    this.containerHeight,
    this.containerWidth,
    this.viewportFraction = 1.0,
    this.itemHeight,
    this.itemWidth,
    this.outer = false,
    this.scale,
    this.fade,
  })  : assert(itemBuilder != null || transformer != null,
            "itemBuilder and transformer must not both be null"),
        assert(
          !loop ||
              ((loop &&
                      layout == SwiperLayout.DEFAULT &&
                      (indicatorLayout == PageIndicatorLayout.SCALE ||
                          indicatorLayout == PageIndicatorLayout.COLOR ||
                          indicatorLayout == PageIndicatorLayout.NONE)) ||
                  (loop && layout != SwiperLayout.DEFAULT)),
          "Only support `PageIndicatorLayout.SCALE` and `PageIndicatorLayout.COLOR` when layout==SwiperLayout.DEFAULT in loop mode",
        ),
        super(key: key);

  factory Swiper.children({
    required List<Widget> children,
    bool autoplay = false,
    PageTransformer? transformer,
    int autoplayDelay = kDefaultAutoplayDelayMs,
    bool reverse = false,
    bool autoplayDisableOnInteraction = true,
    int duration = kDefaultAutoplayTransactionDuration,
    ValueChanged<int>? onIndexChanged,
    int? index,
    SwiperOnTap? onTap,
    bool loop = true,
    Curve curve = Curves.ease,
    Axis scrollDirection = Axis.horizontal,
    SwiperPlugin? pagination,
    SwiperPlugin? control,
    List<SwiperPlugin>? plugins,
    SwiperController? controller,
    Key? key,
    CustomLayoutOption? customLayoutOption,
    ScrollPhysics? physics,
    double? containerHeight,
    double? containerWidth,
    double viewportFraction = 1.0,
    double? itemHeight,
    double? itemWidth,
    bool outer = false,
    double scale = 1.0,
  }) {
    return Swiper(
      key: key,
      transformer: transformer,
      customLayoutOption: customLayoutOption,
      containerHeight: containerHeight,
      containerWidth: containerWidth,
      viewportFraction: viewportFraction,
      itemHeight: itemHeight,
      itemWidth: itemWidth,
      outer: outer,
      scale: scale,
      autoplay: autoplay,
      autoplayDelay: autoplayDelay,
      autoplayDisableOnInteraction: autoplayDisableOnInteraction,
      duration: duration,
      onIndexChanged: onIndexChanged,
      index: index,
      onTap: onTap,
      curve: curve,
      scrollDirection: scrollDirection,
      pagination: pagination,
      control: control,
      controller: controller,
      loop: loop,
      plugins: plugins,
      physics: physics,
      itemBuilder: (BuildContext context, int index) => children[index],
      itemCount: children.length,
    );
  }

  factory Swiper.list({
    PageTransformer? transformer,
    required List list,
    required SwiperDataBuilder<T> builder,
    bool autoplay = false,
    int autoplayDelay = kDefaultAutoplayDelayMs,
    bool reverse = false,
    bool autoplayDisableOnInteraction = true,
    int duration = kDefaultAutoplayTransactionDuration,
    ValueChanged<int>? onIndexChanged,
    int? index,
    SwiperOnTap? onTap,
    bool loop = true,
    Curve curve = Curves.ease,
    Axis scrollDirection = Axis.horizontal,
    SwiperPlugin? pagination,
    SwiperPlugin? control,
    List<SwiperPlugin>? plugins,
    SwiperController? controller,
    Key? key,
    ScrollPhysics? physics,
    double? containerHeight,
    double? containerWidth,
    double viewportFraction = 1.0,
    double? itemHeight,
    double? itemWidth,
    bool outer = false,
    double scale = 1.0,
  }) {
    return Swiper(
      key: key,
      transformer: transformer,
      customLayoutOption: null,
      containerHeight: containerHeight,
      containerWidth: containerWidth,
      viewportFraction: viewportFraction,
      itemHeight: itemHeight,
      itemWidth: itemWidth,
      outer: outer,
      scale: scale,
      autoplay: autoplay,
      autoplayDelay: autoplayDelay,
      autoplayDisableOnInteraction: autoplayDisableOnInteraction,
      duration: duration,
      onIndexChanged: onIndexChanged,
      index: index,
      onTap: onTap,
      curve: curve,
      scrollDirection: scrollDirection,
      pagination: pagination,
      control: control,
      controller: controller,
      loop: loop,
      plugins: plugins,
      physics: physics,
      itemBuilder: (BuildContext context, int index) {
        return builder(context, list[index], index);
      },
      itemCount: list.length,
    );
  }

  @override
  State<StatefulWidget> createState() => _SwiperState();
}

abstract class _SwiperTimerMixin extends State<Swiper> {
  Timer? _timer;
  SwiperController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? SwiperController();
    _controller!.addListener(_onController);

    _handleAutoplay();
  }

  void _onController() {
    switch (_controller?.event) {
      case SwiperController.START_AUTOPLAY:
        if (_timer == null) _startAutoplay();
        break;
      case SwiperController.STOP_AUTOPLAY:
        if (_timer != null) _stopAutoplay();
        break;
      default:
        break;
    }
  }

  @override
  void didUpdateWidget(covariant Swiper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onController);
      _controller = widget.controller ?? SwiperController();
      _controller!.addListener(_onController);
    }

    _handleAutoplay();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onController);
    _stopAutoplay();
    super.dispose();
  }

  bool _autoplayEnabled() {
    return _controller?.autoplay ?? widget.autoplay;
  }

  void _handleAutoplay() {
    if (_autoplayEnabled()) {
      if (_timer == null) {
        _startAutoplay();
      }
    } else {
      _stopAutoplay();
    }
  }

  void _startAutoplay() {
    assert(_timer == null, "Timer must be stopped before start!");
    _timer = Timer.periodic(
      Duration(milliseconds: widget.autoplayDelay),
      _onTimer,
    );
  }

  void _onTimer(Timer timer) {
    _controller?.next(animation: true);
  }

  void _stopAutoplay() {
    _timer?.cancel();
    _timer = null;
  }
}

class _SwiperState extends _SwiperTimerMixin {
  late int _activeIndex;
  late TransformerPageController _pageController;

  Widget _wrapTap(BuildContext context, int index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onTap?.call(index),
      child: widget.itemBuilder(context, index),
    );
  }

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.index ?? 0;

    if (_isPageViewLayout()) {
      _pageController = TransformerPageController(
        initialPage: widget.index ?? 0,
        loop: widget.loop,
        itemCount: widget.itemCount,
        reverse: _getReverse(widget),
        viewportFraction: widget.viewportFraction ?? 1.0,
      );
    }
  }

  bool _isPageViewLayout() =>
      widget.layout == null || widget.layout == SwiperLayout.DEFAULT;

  bool _getReverse(Swiper widget) => widget.transformer?.reverse ?? false;

  @override
  void didUpdateWidget(covariant Swiper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_isPageViewLayout()) {
      final shouldUpdateController = _pageController == null ||
          widget.index != oldWidget.index ||
          widget.loop != oldWidget.loop ||
          widget.itemCount != oldWidget.itemCount ||
          widget.viewportFraction != oldWidget.viewportFraction ||
          _getReverse(widget) != _getReverse(oldWidget);

      if (shouldUpdateController) {
        _pageController = TransformerPageController(
          initialPage: widget.index ?? 0,
          loop: widget.loop,
          itemCount: widget.itemCount,
          reverse: _getReverse(widget),
          viewportFraction: widget.viewportFraction ?? 1.0,
        );
      }
    } else {
      scheduleMicrotask(() {
        _pageController?.dispose();
        _pageController = null;
      });
    }

    if (widget.index != null && widget.index != _activeIndex) {
      _activeIndex = widget.index!;
    }
  }

  void _onIndexChanged(int index) {
    setState(() {
      _activeIndex = index;
    });
    widget.onIndexChanged?.call(index);
  }

  Widget _buildSwiper() {
    final itemBuilder = widget.onTap != null ? _wrapTap : widget.itemBuilder;

    if (widget.layout == SwiperLayout.STACK) {
      return _StackSwiper(
        loop: widget.loop,
        itemWidth: widget.itemWidth!,
        itemHeight: widget.itemHeight!,
        itemCount: widget.itemCount,
        itemBuilder: itemBuilder,
        index: _activeIndex,
        curve: widget.curve,
        duration: widget.duration,
        onIndexChanged: _onIndexChanged,
        controller: _controller!,
        scrollDirection: widget.scrollDirection,
      );
    }

    if (_isPageViewLayout()) {
      PageTransformer transformer = widget.transformer ??
          ScaleAndFadeTransformer(
            scale: widget.scale ?? 0.8,
            fade: widget.fade ?? 0.3,
          );

      final child = TransformerPageView(
        pageController: _pageController,
        loop: widget.loop,
        itemCount: widget.itemCount,
        itemBuilder: itemBuilder,
        transformer: transformer,
        viewportFraction: widget.viewportFraction ?? 1.0,
        index: _activeIndex,
        duration: Duration(milliseconds: widget.duration),
        scrollDirection: widget.scrollDirection,
        onPageChanged: _onIndexChanged,
        curve: widget.curve,
        physics: widget.physics,
        controller: _controller,
      );

      if ((widget.autoplayDisableOnInteraction ?? false) &&
          (widget.autoplay ?? false)) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification &&
                notification.dragDetails != null) {
              _stopAutoplay();
            } else if (notification is ScrollEndNotification &&
                _timer == null) {
              _startAutoplay();
            }
            return false;
          },
          child: child,
        );
      }

      return child;
    }

    if (widget.layout == SwiperLayout.TINDER) {
      return _TinderSwiper(
        loop: widget.loop,
        itemWidth: widget.itemWidth!,
        itemHeight: widget.itemHeight!,
        itemCount: widget.itemCount,
        itemBuilder: itemBuilder,
        index: _activeIndex,
        curve: widget.curve,
        duration: widget.duration,
        onIndexChanged: _onIndexChanged,
        controller: _controller!,
        scrollDirection: widget.scrollDirection,
      );
    }

    if (widget.layout == SwiperLayout.CUSTOM) {
      return _CustomLayoutSwiper(
        loop: widget.loop,
        option: widget.customLayoutOption!,
        itemWidth: widget.itemWidth!,
        itemHeight: widget.itemHeight!,
        itemCount: widget.itemCount,
        itemBuilder: itemBuilder,
        index: _activeIndex,
        curve: widget.curve,
        duration: widget.duration,
        onIndexChanged: _onIndexChanged,
        controller: _controller!,
        scrollDirection: widget.scrollDirection,
      );
    }

    return const SizedBox.shrink();
  }

  SwiperPluginConfig _ensureConfig(SwiperPluginConfig? config) {
    return config ??
        SwiperPluginConfig(
          outer: widget.outer,
          itemCount: widget.itemCount,
          layout: widget.layout,
          indicatorLayout: widget.indicatorLayout,
          pageController: _pageController,
          activeIndex: _activeIndex,
          scrollDirection: widget.scrollDirection,
          controller: _controller,
          loop: widget.loop,
        );
  }

  List<Widget> _ensureListForStack(
      Widget swiper, List<Widget>? listForStack, Widget widgetToAdd) {
    listForStack ??= [swiper];
    listForStack.add(widgetToAdd);
    return listForStack;
  }

  @override
  Widget build(BuildContext context) {
    final swiper = _buildSwiper();
    List<Widget>? listForStack;
    SwiperPluginConfig? config;

    if (widget.control != null) {
      config = _ensureConfig(config);
      listForStack = _ensureListForStack(
        swiper,
        listForStack,
        widget.control!.build(context, config),
      );
    }

    if (widget.plugins != null) {
      config = _ensureConfig(config);
      for (final plugin in widget.plugins!) {
        listForStack = _ensureListForStack(
          swiper,
          listForStack,
          plugin.build(context, config),
        );
      }
    }

    if (widget.pagination != null) {
      config = _ensureConfig(config);
      if (widget.outer) {
        return _buildOuterPagination(
          widget.pagination!,
          listForStack == null ? swiper : Stack(children: listForStack),
          config,
        );
      } else {
        listForStack = _ensureListForStack(
          swiper,
          listForStack,
          widget.pagination!.build(context, config),
        );
      }
    }

    return listForStack != null ? Stack(children: listForStack) : swiper;
  }

  Widget _buildOuterPagination(
    SwiperPagination pagination,
    Widget swiper,
    SwiperPluginConfig config,
  ) {
    final children = <Widget>[];

    if (widget.containerHeight != null || widget.containerWidth != null) {
      children.add(swiper);
    } else {
      children.add(Expanded(child: swiper));
    }

    children.add(Align(
      alignment: Alignment.center,
      child: pagination.build(context, config),
    ));

    return Column(
      children: children,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }
}

abstract class _SubSwiper extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final int index;
  final ValueChanged<int> onIndexChanged;
  final SwiperController controller;
  final int duration;
  final Curve curve;
  final double itemWidth;
  final double itemHeight;
  final bool loop;
  final Axis scrollDirection;

  const _SubSwiper({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.index = 0,
    required this.onIndexChanged,
    required this.controller,
    this.duration = 300,
    this.curve = Curves.linear,
    required this.itemWidth,
    required this.itemHeight,
    this.loop = false,
    this.scrollDirection = Axis.horizontal,
  });

  @override
  State<StatefulWidget> createState();

  int getCorrectIndex(int indexNeedsFix) {
    if (itemCount == 0) return 0;
    int value = indexNeedsFix % itemCount;
    if (value < 0) {
      value += itemCount;
    }
    return value;
  }
}

class _TinderSwiper extends _SubSwiper {
  const _TinderSwiper({
    super.key,
    required super.itemBuilder,
    required super.itemCount,
    required super.itemWidth,
    required super.itemHeight,
    super.curve,
    super.duration,
    super.controller,
    super.index,
    super.loop,
    super.onIndexChanged,
    super.scrollDirection,
  });

  @override
  State<StatefulWidget> createState() => _TinderState();
}

class _StackSwiper extends _SubSwiper {
  const _StackSwiper({
    super.key,
    required super.itemBuilder,
    required super.itemCount,
    required super.itemWidth,
    required super.itemHeight,
    super.curve,
    super.duration,
    super.controller,
    super.index,
    super.loop,
    super.onIndexChanged,
    super.scrollDirection,
  });

  @override
  State<StatefulWidget> createState() => _StackViewState();
}

class _TinderState extends _CustomLayoutStateBase<_TinderSwiper> {
  late List<double> scales;
  late List<double> offsetsX;
  late List<double> offsetsY;
  late List<double> opacity;
  late List<double> rotates;

  double getOffsetY(double scale) {
    return widget.itemHeight - (widget.itemHeight * scale);
  }

  @override
  void didUpdateWidget(covariant _TinderSwiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateValues();
  }

  @override
  void afterRender() {
    super.afterRender();

    _startIndex = -3;
    _animationCount = 5;

    opacity = [0.0, 0.9, 0.9, 1.0, 0.0, 0.0];
    scales = [0.80, 0.80, 0.85, 0.90, 1.0, 1.0, 1.0];
    rotates = [0.0, 0.0, 0.0, 0.0, 20.0, 25.0];

    _updateValues();
  }

  void _updateValues() {
    if (widget.scrollDirection == Axis.horizontal) {
      offsetsX = [0.0, 0.0, 0.0, 0.0, _swiperWidth, _swiperWidth];
      offsetsY = [0.0, 0.0, -5.0, -10.0, -15.0, -20.0];
    } else {
      offsetsX = [0.0, 0.0, 5.0, 10.0, 15.0, 20.0];
      offsetsY = [0.0, 0.0, 0.0, 0.0, _swiperHeight, _swiperHeight];
    }
  }

  @override
  Widget _buildItem(int i, int realIndex, double animationValue) {
    final s = _getValue(scales, animationValue, i);
    final f = _getValue(offsetsX, animationValue, i);
    final fy = _getValue(offsetsY, animationValue, i);
    final o = _getValue(opacity, animationValue, i).clamp(0.0, 1.0);
    final a = _getValue(rotates, animationValue, i);

    final alignment = widget.scrollDirection == Axis.horizontal
        ? Alignment.bottomCenter
        : Alignment.centerLeft;

    return Opacity(
      opacity: o,
      child: Transform.rotate(
        angle: a * (3.1415926 / 180.0), // degrees to radians
        child: Transform.translate(
          key: ValueKey<int>(_currentIndex + i),
          offset: Offset(f, fy),
          child: Transform.scale(
            scale: s,
            alignment: alignment,
            child: SizedBox(
              width: widget.itemWidth,
              height: widget.itemHeight,
              child: widget.itemBuilder(context, realIndex),
            ),
          ),
        ),
      ),
    );
  }
}

class _StackViewState extends _CustomLayoutStateBase<_StackSwiper> {
  late List<double> scales;
  late List<double> offsets;
  late List<double> opacity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _updateValues() {
    final double space = widget.scrollDirection == Axis.horizontal
        ? (_swiperWidth - widget.itemWidth) / 2
        : (_swiperHeight - widget.itemHeight) / 2;

    offsets = widget.scrollDirection == Axis.horizontal
        ? [-space, -space * 2 / 3, -space / 3, 0.0, _swiperWidth]
        : [-space, -space * 2 / 3, -space / 3, 0.0, _swiperHeight];
  }

  @override
  void didUpdateWidget(covariant _StackSwiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateValues();
  }

  @override
  void afterRender() {
    super.afterRender();

    _animationCount = 5;
    _startIndex = -3;

    scales = [0.7, 0.8, 0.9, 1.0, 1.0];
    opacity = [0.0, 0.5, 1.0, 1.0, 1.0];

    _updateValues();
  }

  @override
  Widget _buildItem(int i, int realIndex, double animationValue) {
    final double scaleValue = _getValue(scales, animationValue, i);
    final double offsetValue = _getValue(offsets, animationValue, i);
    final double opacityValue = _getValue(opacity, animationValue, i);

    final Offset offset = widget.scrollDirection == Axis.horizontal
        ? Offset(offsetValue, 0.0)
        : Offset(0.0, offsetValue);

    final Alignment alignment = widget.scrollDirection == Axis.horizontal
        ? Alignment.centerLeft
        : Alignment.topCenter;

    return Opacity(
      opacity: opacityValue.clamp(0.0, 1.0),
      child: Transform.translate(
        key: ValueKey<int>(_currentIndex + i),
        offset: offset,
        child: Transform.scale(
          scale: scaleValue,
          alignment: alignment,
          child: SizedBox(
            width: widget.itemWidth ?? double.infinity,
            height: widget.itemHeight ?? double.infinity,
            child: widget.itemBuilder(context, realIndex),
          ),
        ),
      ),
    );
  }
}

class ScaleAndFadeTransformer extends PageTransformer {
  final double scale;
  final double fade;

  ScaleAndFadeTransformer({
    this.fade = 0.3,
    this.scale = 0.8,
  });

  @override
  Widget transform(Widget child, TransformInfo info) {
    final double position = info.position;

    // Scale logic
    final double scaleFactor = (1 - position.abs()) * (1 - scale);
    final double effectiveScale = scale + scaleFactor;

    // Fade logic
    final double fadeFactor = (1 - position.abs()) * (1 - fade);
    final double opacity = fade + fadeFactor;

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: effectiveScale.clamp(0.0, 1.0),
        child: child,
      ),
    );
  }
}
