package com.phonescope.phonescope.channels

import android.content.Context
import android.hardware.camera2.CameraManager
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.AudioTrack
import android.media.MediaRecorder
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread
import kotlin.math.log10
import kotlin.math.sin
import kotlin.math.sqrt

class HardwareTestHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    private val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as? CameraManager
    private var activeAudioTrack: AudioTrack? = null
    private var activeAudioRecord: AudioRecord? = null
    private var isRecording = false

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // Flashlight
            "setFlashlight" -> {
                val enable = call.argument<Boolean>("enable") ?: false
                try {
                    val cameraId = cameraManager?.cameraIdList?.firstOrNull()
                    if (cameraId != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        cameraManager.setTorchMode(cameraId, enable)
                        result.success(true)
                    } else {
                        result.error("TORCH_ERROR", "Flashlight not supported", null)
                    }
                } catch (e: Exception) {
                    result.error("TORCH_ERROR", e.localizedMessage, null)
                }
            }

            // Vibration
            "vibrate" -> {
                val type = call.argument<String>("type") ?: "short"
                val durationMs = call.argument<Long>("durationMs") ?: 300L
                try {
                    val vibrator = getVibrator()
                    if (vibrator == null || !vibrator.hasVibrator()) {
                        result.success(false)
                        return
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        when (type) {
                            "sos" -> {
                                val timings = longArrayOf(0, 150, 100, 150, 100, 150, 300, 400, 100, 400, 100, 400, 300, 150, 100, 150, 100, 150)
                                vibrator.vibrate(VibrationEffect.createWaveform(timings, -1))
                            }
                            "double" -> {
                                val timings = longArrayOf(0, 200, 100, 200)
                                vibrator.vibrate(VibrationEffect.createWaveform(timings, -1))
                            }
                            else -> {
                                vibrator.vibrate(VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE))
                            }
                        }
                    } else {
                        @Suppress("DEPRECATION")
                        vibrator.vibrate(durationMs)
                    }
                    result.success(true)
                } catch (e: Exception) {
                    result.error("VIBRATION_ERROR", e.localizedMessage, null)
                }
            }

            "cancelVibration" -> {
                try {
                    getVibrator()?.cancel()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("VIBRATION_ERROR", e.localizedMessage, null)
                }
            }

            // Speaker Pure Tone Test
            "playTestTone" -> {
                val freq = call.argument<Double>("frequency") ?: 440.0
                val durationSec = call.argument<Double>("durationSeconds") ?: 1.5
                try {
                    stopTestTone()
                    thread {
                        generateAndPlayTone(freq, durationSec)
                    }
                    result.success(true)
                } catch (e: Exception) {
                    result.error("AUDIO_ERROR", e.localizedMessage, null)
                }
            }

            "stopTestTone" -> {
                stopTestTone()
                result.success(true)
            }

            // Microphone Amplitude Check
            "getMicAmplitude" -> {
                try {
                    val amplitude = sampleMicAmplitude()
                    result.success(amplitude)
                } catch (e: Exception) {
                    result.error("MIC_ERROR", e.localizedMessage, null)
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun getVibrator(): Vibrator? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vm = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
            vm?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }
    }

    private fun generateAndPlayTone(freqHz: Double, durationSec: Double) {
        val sampleRate = 44100
        val numSamples = (durationSec * sampleRate).toInt()
        val generatedSnd = ShortArray(numSamples)

        for (i in 0 until numSamples) {
            val angle = 2.0 * Math.PI * i / (sampleRate / freqHz)
            generatedSnd[i] = (sin(angle) * Short.MAX_VALUE * 0.8).toInt().toShort()
        }

        val track = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(sampleRate)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build()
            )
            .setBufferSizeInBytes(numSamples * 2)
            .setTransferMode(AudioTrack.MODE_STATIC)
            .build()

        activeAudioTrack = track
        track.write(generatedSnd, 0, generatedSnd.size)
        track.play()
    }

    private fun stopTestTone() {
        try {
            activeAudioTrack?.stop()
            activeAudioTrack?.release()
            activeAudioTrack = null
        } catch (_: Exception) {}
    }

    private fun sampleMicAmplitude(): Double {
        val sampleRate = 44100
        val bufferSize = AudioRecord.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        if (bufferSize <= 0) return 0.0

        val record = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize
        )

        val buffer = ShortArray(bufferSize)
        try {
            record.startRecording()
            val read = record.read(buffer, 0, buffer.size)
            record.stop()
            record.release()

            if (read > 0) {
                var sum = 0.0
                for (i in 0 until read) {
                    sum += buffer[i] * buffer[i]
                }
                val rms = sqrt(sum / read)
                // Convert to approximate decibels (0 to 100 dB scale)
                val db = if (rms > 0) 20 * log10(rms / 32767.0) + 100 else 0.0
                return db.coerceIn(0.0, 100.0)
            }
        } catch (_: Exception) {
            try {
                record.release()
            } catch (_: Exception) {}
        }
        return 0.0
    }
}
