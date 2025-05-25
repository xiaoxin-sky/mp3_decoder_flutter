import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mp3_decoder_flutter/mp3_decoder_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelMp3DecoderFlutter platform = MethodChannelMp3DecoderFlutter();
  const MethodChannel channel = MethodChannel('mp3_decoder_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
