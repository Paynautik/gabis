import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

final _registered = <String>{};

/// Registers one view factory per source and returns the platform view.
Widget buildLoopingVideo(String src) {
  final viewType = 'gabis-video-$src';

  if (_registered.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
      final video = web.document.createElement('video') as web.HTMLVideoElement
        ..src = src
        ..autoplay = true
        ..muted = true
        ..loop = true
        ..playsInline = true
        ..preload = 'auto';
      // Chrome only honours autoplay when muted is present as an attribute
      // at parse time; the property alone is not enough for a detached node.
      video.setAttribute('muted', '');
      video.setAttribute('autoplay', '');
      video.setAttribute('loop', '');
      video.setAttribute('playsinline', '');
      video.setAttribute('disablepictureinpicture', 'true');
      video.defaultMuted = true;

      void tryPlay() {
        video.play().toDart.catchError((Object _) => null);
      }

      // Some browsers drop the loop flag on a detached element; restart by hand.
      video.onEnded.listen((_) {
        video.currentTime = 0;
        tryPlay();
      });

      // The clip can stall a few frames short of its duration, so 'ended'
      // never fires and the loop flag never triggers. Watch the clock instead.
      video.onTimeUpdate.listen((_) {
        final duration = video.duration;
        if (duration.isFinite && video.currentTime >= duration - 0.2) {
          video.currentTime = 0;
          tryPlay();
        }
      });
      video.onCanPlay.listen((_) => tryPlay());
      video.onLoadedData.listen((_) => tryPlay());
      tryPlay();
      video.style
        ..width = '100%'
        ..height = '100%'
        ..objectFit = 'cover'
        ..objectPosition = 'center right'
        ..border = '0';
      return video;
    });
  }

  return HtmlElementView(viewType: viewType);
}
