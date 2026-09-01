import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'web_video_panel_stub.dart'
    if (dart.library.js_interop) 'web_video_panel_web.dart';

/// A looping muted background video with a still image behind it, so the
/// section still reads correctly if the file is slow or blocked.
class WebVideoPanel extends StatelessWidget {
  final String src;
  final String posterAsset;
  final Alignment alignment;

  const WebVideoPanel({
    super.key,
    required this.src,
    required this.posterAsset,
    this.alignment = Alignment.centerRight,
  });

  @override
  Widget build(BuildContext context) {
    final poster = Image.asset(posterAsset, fit: BoxFit.cover, alignment: alignment);
    if (!kIsWeb) return poster;

    return Stack(
      fit: StackFit.expand,
      children: [
        poster,
        buildLoopingVideo(src),
      ],
    );
  }
}
