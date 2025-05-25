import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mp3_decoder_flutter_platform_interface.dart';

/// An implementation of [Mp3DecoderFlutterPlatform] that uses method channels.
class MethodChannelMp3DecoderFlutter extends Mp3DecoderFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mp3_decoder_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
