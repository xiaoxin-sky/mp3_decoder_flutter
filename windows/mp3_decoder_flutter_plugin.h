#ifndef FLUTTER_PLUGIN_MP3_DECODER_FLUTTER_PLUGIN_H_
#define FLUTTER_PLUGIN_MP3_DECODER_FLUTTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace mp3_decoder_flutter {

class Mp3DecoderFlutterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  Mp3DecoderFlutterPlugin();

  virtual ~Mp3DecoderFlutterPlugin();

  // Disallow copy and assign.
  Mp3DecoderFlutterPlugin(const Mp3DecoderFlutterPlugin&) = delete;
  Mp3DecoderFlutterPlugin& operator=(const Mp3DecoderFlutterPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace mp3_decoder_flutter

#endif  // FLUTTER_PLUGIN_MP3_DECODER_FLUTTER_PLUGIN_H_
