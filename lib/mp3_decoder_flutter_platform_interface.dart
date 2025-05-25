import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mp3_decoder_flutter_method_channel.dart';

abstract class Mp3DecoderFlutterPlatform extends PlatformInterface {
  /// Constructs a Mp3DecoderFlutterPlatform.
  Mp3DecoderFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static Mp3DecoderFlutterPlatform _instance = MethodChannelMp3DecoderFlutter();

  /// The default instance of [Mp3DecoderFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelMp3DecoderFlutter].
  static Mp3DecoderFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Mp3DecoderFlutterPlatform] when
  /// they register themselves.
  static set instance(Mp3DecoderFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
