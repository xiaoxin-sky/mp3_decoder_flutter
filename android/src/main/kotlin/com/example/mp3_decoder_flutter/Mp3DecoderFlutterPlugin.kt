package your.package

import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer
import java.util.*

class Mp3DecoderFlutterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "mp3_decoder_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "decodeMp3") {
            val mp3Bytes = call.argument<ByteArray>("mp3Bytes")

            if (mp3Bytes == null) {
                result.error("INVALID_ARGUMENT", "mp3Bytes is null", null)
                return
            }

            Thread {
                try {
                    val decodeResult = decodeMp3ToPcm(mp3Bytes)
                    if (decodeResult != null) {
                        result.success(decodeResult)
                    } else {
                        result.error("DECODE_FAILED", "Failed to decode mp3", null)
                    }
                } catch (e: Exception) {
                    result.error("EXCEPTION", e.localizedMessage, null)
                }
            }.start()
        } else {
            result.notImplemented()
        }
    }

    data class DecodeResult(val pcm: ByteArray, val sampleRate: Int, val channels: Int)

    private fun decodeMp3ToPcm(mp3Data: ByteArray): Map<String, Any>? {
        // 写入临时文件
        val tempFile = kotlin.io.path.createTempFile(suffix = ".mp3").toFile()
        tempFile.writeBytes(mp3Data)

        val extractor = MediaExtractor()
        extractor.setDataSource(tempFile.absolutePath)

        var trackIndex = -1
        for (i in 0 until extractor.trackCount) {
            val format = extractor.getTrackFormat(i)
            val mime = format.getString(MediaFormat.KEY_MIME)
            if (mime != null && mime.startsWith("audio/")) {
                trackIndex = i
                break
            }
        }
        if (trackIndex == -1) {
            extractor.release()
            tempFile.delete()
            return null
        }
        extractor.selectTrack(trackIndex)
        val format = extractor.getTrackFormat(trackIndex)
        val mime = format.getString(MediaFormat.KEY_MIME) ?: return null

        val codec = MediaCodec.createDecoderByType(mime)
        codec.configure(format, null, null, 0)
        codec.start()

        val inputBuffers = codec.inputBuffers
        val outputBuffers = codec.outputBuffers
        val bufferInfo = MediaCodec.BufferInfo()

        val outputData = mutableListOf<Byte>()

        var isEOS = false
        while (!isEOS) {
            val inIndex = codec.dequeueInputBuffer(10000)
            if (inIndex >= 0) {
                val buffer = inputBuffers[inIndex]
                val sampleSize = extractor.readSampleData(buffer, 0)
                if (sampleSize < 0) {
                    codec.queueInputBuffer(inIndex, 0, 0, 0L, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                    isEOS = true
                } else {
                    codec.queueInputBuffer(inIndex, 0, sampleSize, extractor.sampleTime, 0)
                    extractor.advance()
                }
            }

            var outIndex = codec.dequeueOutputBuffer(bufferInfo, 10000)
            while (outIndex >= 0) {
                val outBuffer = outputBuffers[outIndex]
                val chunk = ByteArray(bufferInfo.size)
                outBuffer.get(chunk)
                outBuffer.clear()
                outputData.addAll(chunk.toList())

                codec.releaseOutputBuffer(outIndex, false)
                outIndex = codec.dequeueOutputBuffer(bufferInfo, 0)
            }
        }

        codec.stop()
        codec.release()
        extractor.release()
        tempFile.delete()

        val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)

        return mapOf(
            "pcm" to outputData.toByteArray(),
            "sampleRate" to sampleRate,
            "channels" to channels
        )
    }
}