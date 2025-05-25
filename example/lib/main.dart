import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:mp3_decoder_flutter/mp3_decoder_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoLoud.instance.init(channels: Channels.mono);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SoundHandle? handle;

  AudioSource audioChunk = SoLoud.instance.setBufferStream(
    maxBufferSizeBytes: 1024 * 1024 * 10, // 10MB of max buffer (not allocated)
    bufferingType: BufferingType.preserved,
    sampleRate: 16000,
    channels: Channels.mono,
    format: BufferType.s16le,
  );
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(
            onPressed: () async {
              final a =
                  (await rootBundle.load("audio/msg.mp3")).buffer.asUint8List();
              final pcmSource = await Mp3DecoderFlutter.decode(
                a,
                sampleRate: 16000,
                channels: 1,
                bitDepth: 16,
              );
              print("解码:${pcmSource?.length}");
              if (pcmSource == null) return;
              SoLoud.instance.addAudioDataStream(audioChunk, pcmSource);
            },
            child: Text("解码并加载"),
          ),
          TextButton(
            onPressed: () async {
              handle = await SoLoud.instance.play(audioChunk);
            },
            child: Text("播放"),
          ),
          TextButton(
            onPressed: () async {
              if (handle == null) return;
              SoLoud.instance.pauseSwitch(handle!);
            },
            child: Text("切换暂停"),
          ),
        ])),
      ),
    );
  }
}
