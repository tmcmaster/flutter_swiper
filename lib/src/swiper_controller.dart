import 'package:flutter_swiper/src/swiper_plugin.dart';
import 'package:transformer_page_view/transformer_page_view.dart';

class SwiperController extends IndexController {
  // Autoplay is started
  static const int START_AUTOPLAY = 2;

  // Autoplay is stopped.
  static const int STOP_AUTOPLAY = 3;

  // Indicate that the user is swiping
  static const int SWIPE = 4;

  // Indicate that the `Swiper` has changed its index and is building its UI,
  // so that the `SwiperPluginConfig` is available.
  static const int BUILD = 5;

  // Available when `event` == SwiperController.BUILD
  SwiperPluginConfig? config;

  // Available when `event` == SwiperController.SWIPE
  // This value is PageViewController.pos
  double? pos;

  int index = 0;
  bool animation = false;
  bool autoplay = false;

  SwiperController();

  void startAutoplay() {
    event = START_AUTOPLAY;
    autoplay = true;
    notifyListeners();
  }

  void stopAutoplay() {
    event = STOP_AUTOPLAY;
    autoplay = false;
    notifyListeners();
  }
}
