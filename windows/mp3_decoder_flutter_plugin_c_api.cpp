#include "include/mp3_decoder_flutter/mp3_decoder_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "mp3_decoder_flutter_plugin.h"

void Mp3DecoderFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  mp3_decoder_flutter::Mp3DecoderFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
