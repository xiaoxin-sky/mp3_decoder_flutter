import Flutter
import UIKit
import AVFoundation

public class Mp3DecoderFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "mp3_decoder_flutter", binaryMessenger: registrar.messenger())
    let instance = Mp3DecoderFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "decodeMp3" {
      guard let args = call.arguments as? [String: Any],
            let mp3Data = args["mp3Bytes"] as? FlutterStandardTypedData else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing mp3Bytes", details: nil))
        return
      }

      let sampleRate = args["sampleRate"] as? Int ?? 44100
      let channels = args["channels"] as? Int ?? 1
      let bitDepth = args["bitDepth"] as? Int ?? 16

      decodeMp3ToPCM(mp3Data.data, sampleRate: sampleRate, channels: channels, bitDepth: bitDepth) { pcmData in
        if let pcmData = pcmData {
          result(FlutterStandardTypedData(bytes: pcmData))
        } else {
          result(FlutterError(code: "DECODE_FAILED", message: "Failed to decode mp3", details: nil))
        }
      }
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func decodeMp3ToPCM(_ mp3Data: Data, sampleRate: Int, channels: Int, bitDepth: Int, completion: @escaping (Data?) -> Void) {
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp3")
    do {
      try mp3Data.write(to: tempURL)
    } catch {
      print("Error writing temp mp3 file: \(error)")
      completion(nil)
      return
    }

    let asset = AVURLAsset(url: tempURL)
    guard let reader = try? AVAssetReader(asset: asset),
          let track = asset.tracks(withMediaType: .audio).first else {
      completion(nil)
      return
    }

    let outputSettings: [String: Any] = [
      AVFormatIDKey: kAudioFormatLinearPCM,
      AVSampleRateKey: sampleRate,
      AVNumberOfChannelsKey: channels,
      AVLinearPCMBitDepthKey: bitDepth,
      AVLinearPCMIsBigEndianKey: false,
      AVLinearPCMIsFloatKey: false
    ]

    let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
    reader.add(readerOutput)
    reader.startReading()

    let outputData = NSMutableData()

    while reader.status == .reading {
      if let sampleBuffer = readerOutput.copyNextSampleBuffer(),
         let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
        let length = CMBlockBufferGetDataLength(blockBuffer)
        var data = Data(count: length)
        data.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
          CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: ptr.baseAddress!)
        }
        outputData.append(data)
      }
    }

    try? FileManager.default.removeItem(at: tempURL)

    if reader.status == .completed {
      completion(outputData as Data)
    } else {
      print("Decoding failed with status: \(reader.status.rawValue)")
      completion(nil)
    }
  }
}