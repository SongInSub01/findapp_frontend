import 'package:flutter/foundation.dart';

bool get supportsNativeKakaoMap =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);
