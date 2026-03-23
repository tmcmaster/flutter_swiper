part of 'swiper.dart';

abstract class _CustomLayoutStateBase<T extends _SubSwiper> extends State<T>
    with SingleTickerProviderStateMixin {
  late double _swiperWidth;
  late double _swiperHeight;
  late final Animation<double> _animation;
  late final AnimationController _animationController;
  late int _startIndex;
  late int _animationCount;

  double _currentValue = 0.0;
  double _currentPos = 0.0;
  bool _lockScroll = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.itemWidth == null) {
      throw Exception(
        '==============\n\n'
        'widget.itemWidth must not be null when using stack layout.\n'
        '========\n',
      );
    }

    _createAnimationController();
    widget.controller.addListener(_onController);
  }

  void _createAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      value: 0.5,
    );
    final tween = Tween<double>(begin: 0.0, end: 1.0);
    _animation = tween.animate(_animationController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback(_getSize);
  }

  void _getSize(Duration _) {
    afterRender();
  }

  @mustCallSuper
  void afterRender() {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      final size = renderObject.size;
      _swiperWidth = size.width;
      _swiperHeight = size.height;
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
    }

    if (widget.loop != oldWidget.loop && !widget.loop) {
      _currentIndex = _ensureIndex(_currentIndex);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildContainer(List<Widget> list) => Stack(children: list);

  Widget _buildAnimation(BuildContext context, Widget? child) {
    final list = <Widget>[];
    final animationValue = _animation.value;

    for (int i = 0; i < _animationCount; ++i) {
      int realIndex = _currentIndex + i + _startIndex;
      realIndex %= widget.itemCount;
      if (realIndex < 0) realIndex += widget.itemCount;

      list.add(_buildItem(i, realIndex, animationValue));
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onPanStart,
      onPanEnd: _onPanEnd,
      onPanUpdate: _onPanUpdate,
      child: ClipRect(
        child: Center(child: _buildContainer(list)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_animationCount == 0) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _animationController,
      builder: _buildAnimation,
    );
  }

  int _ensureIndex(int index) {
    index %= widget.itemCount;
    return index < 0 ? index + widget.itemCount : index;
  }

  Future<void> _move(double position, {int? nextIndex}) async {
    if (_lockScroll) return;
    _lockScroll = true;
    try {
      await _animationController.animateTo(
        position,
        duration: Duration(milliseconds: widget.duration),
        curve: widget.curve,
      );
      if (nextIndex != null) {
        widget.onIndexChanged(widget.getCorrectIndex(nextIndex));
      }
    } catch (e) {
      debugPrint('Move error: $e');
    } finally {
      if (nextIndex != null) {
        try {
          _animationController.value = 0.5;
        } catch (e) {
          debugPrint('Reset controller error: $e');
        }
        _currentIndex = nextIndex;
      }
      _lockScroll = false;
    }
  }

  int _nextIndex() => (!widget.loop && _currentIndex >= widget.itemCount - 1)
      ? widget.itemCount - 1
      : _currentIndex + 1;

  int _prevIndex() =>
      (!widget.loop && _currentIndex <= 0) ? 0 : _currentIndex - 1;

  void _onController() {
    switch (widget.controller.event) {
      case IndexController.PREVIOUS:
        final prev = _prevIndex();
        if (prev != _currentIndex) _move(1.0, nextIndex: prev);
        break;
      case IndexController.NEXT:
        final next = _nextIndex();
        if (next != _currentIndex) _move(0.0, nextIndex: next);
        break;
      case IndexController.MOVE:
        throw Exception(
            "Custom layout does not support SwiperControllerEvent.MOVE_INDEX yet!");
      case SwiperController.STOP_AUTOPLAY:
      case SwiperController.START_AUTOPLAY:
        break;
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_lockScroll) return;
    _currentValue = _animationController.value;
    _currentPos = widget.scrollDirection == Axis.horizontal
        ? details.globalPosition.dx
        : details.globalPosition.dy;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_lockScroll) return;
    final delta = widget.scrollDirection == Axis.horizontal
        ? details.globalPosition.dx
        : details.globalPosition.dy;

    double value = _currentValue + ((delta - _currentPos) / _swiperWidth / 2);

    if (!widget.loop) {
      if (_currentIndex >= widget.itemCount - 1 && value < 0.5) value = 0.5;
      if (_currentIndex <= 0 && value > 0.5) value = 0.5;
    }

    _animationController.value = value.clamp(0.0, 1.0);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_lockScroll) return;
    final velocity = widget.scrollDirection == Axis.horizontal
        ? details.velocity.pixelsPerSecond.dx
        : details.velocity.pixelsPerSecond.dy;

    if (_animationController.value >= 0.75 || velocity > 500.0) {
      if (_currentIndex > 0 || widget.loop) {
        _move(1.0, nextIndex: _currentIndex - 1);
      }
    } else if (_animationController.value < 0.25 || velocity < -500.0) {
      if (_currentIndex < widget.itemCount - 1 || widget.loop) {
        _move(0.0, nextIndex: _currentIndex + 1);
      }
    } else {
      _move(0.5);
    }
  }

  Widget _buildItem(int i, int realIndex, double animationValue);
}
