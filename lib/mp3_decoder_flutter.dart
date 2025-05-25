import 'dart:typed_data';
import 'package:flutter/services.dart';

class DecodeParams {
  final int sampleRate;
  final int channels;
  final int bitDepth;

  DecodeParams({
    this.sampleRate = 44100,
    this.channels = 1,
    this.bitDepth = 16,
  });

  Map<String, dynamic> toMap() => {
        'sampleRate': sampleRate,
        'channels': channels,
        'bitDepth': bitDepth,
      };
}

class Mp3DecoderFlutter {
  static const MethodChannel _channel = MethodChannel('mp3_decoder_flutter');

  static Future<Uint8List?> decode(Uint8List mp3Bytes,
      {int sampleRate = 44100, int channels = 1, int bitDepth = 16}) async {
    final Map<String, dynamic> args = {
      'mp3Bytes': mp3Bytes,
      'sampleRate': sampleRate,
      'channels': channels,
    };

    final result = await _channel.invokeMethod<Uint8List>('decodeMp3', args);
    return result;
  }
}
