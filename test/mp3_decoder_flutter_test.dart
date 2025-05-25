import 'package:flutter_test/flutter_test.dart';
import 'package:mp3_decoder_flutter/mp3_decoder_flutter.dart';
import 'package:mp3_decoder_flutter/mp3_decoder_flutter_platform_interface.dart';
import 'package:mp3_decoder_flutter/mp3_decoder_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMp3DecoderFlutterPlatform
    with MockPlatformInterfaceMixin
    implements Mp3DecoderFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final Mp3DecoderFlutterPlatform initialPlatform = Mp3DecoderFlutterPlatform.instance;

  test('$MethodChannelMp3DecoderFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMp3DecoderFlutter>());
  });

  test('getPlatformVersion', () async {
    Mp3DecoderFlutter mp3DecoderFlutterPlugin = Mp3DecoderFlutter();
    MockMp3DecoderFlutterPlatform fakePlatform = MockMp3DecoderFlutterPlatform();
    Mp3DecoderFlutterPlatform.instance = fakePlatform;

    expect(await mp3DecoderFlutterPlugin.getPlatformVersion(), '42');
  });
}
