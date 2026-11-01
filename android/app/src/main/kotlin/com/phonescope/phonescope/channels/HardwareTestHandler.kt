package com.phonescope.phonescope.channels

import android.content.Context
import android.hardware.camera2.CameraManager
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
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
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
    private var activeAudioTrack: AudioTrack? = null

    // Speaker cleaner state
    @Volatile
    private var isCleanerRunning = false
    private var cleanerThread: Thread? = null
    private var cleanerTrack: AudioTrack? = null

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
                            "tick" -> {
                                vibrator.vibrate(VibrationEffect.createOneShot(35, VibrationEffect.DEFAULT_AMPLITUDE))
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

            // --- SPEAKER CLEANER & WATER EJECT ENGINE ---
            "startSpeakerCleaner" -> {
                val mode = call.argument<String>("mode") ?: "auto"
                val frequency = call.argument<Double>("frequency") ?: 165.0
                val durationSeconds = call.argument<Int>("durationSeconds") ?: 30
                val isEarpiece = call.argument<Boolean>("isEarpiece") ?: false
                val enableVibration = call.argument<Boolean>("enableVibration") ?: true

                try {
                    stopSpeakerCleanerInternal()
                    isCleanerRunning = true

                    cleanerThread = thread(name = "PhoneScope-SpeakerCleaner", isDaemon = true) {
                        runSpeakerCleanerLoop(
                            mode = mode,
                            targetFreq = frequency,
                            durationSec = durationSeconds,
                            isEarpiece = isEarpiece,
                            vibrate = enableVibration
                        )
                    }
                    result.success(true)
                } catch (e: Exception) {
                    result.error("CLEANER_ERROR", e.localizedMessage, null)
                }
            }

            "stopSpeakerCleaner" -> {
                stopSpeakerCleanerInternal()
                result.success(true)
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

    private fun stopSpeakerCleanerInternal() {
        isCleanerRunning = false
        try {
            cleanerTrack?.pause()
            cleanerTrack?.flush()
            cleanerTrack?.stop()
            cleanerTrack?.release()
        } catch (_: Exception) {}
        cleanerTrack = null

        // Reset earpiece routing mode if needed
        try {
            if (audioManager?.mode != AudioManager.MODE_NORMAL) {
                audioManager?.mode = AudioManager.MODE_NORMAL
                audioManager?.isSpeakerphoneOn = true
            }
        } catch (_: Exception) {}

        cleanerThread?.interrupt()
        cleanerThread = null
    }

    private fun runSpeakerCleanerLoop(
        mode: String,
        targetFreq: Double,
        durationSec: Int,
        isEarpiece: Boolean,
        vibrate: Boolean
    ) {
        val sampleRate = 44100
        val bufferSize = AudioTrack.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        ).coerceAtLeast(4096)

        // Route to earpiece if selected
        if (isEarpiece && audioManager != null) {
            try {
                audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
                audioManager.isSpeakerphoneOn = false
            } catch (_: Exception) {}
        }

        val usage = if (isEarpiece) AudioAttributes.USAGE_VOICE_COMMUNICATION else AudioAttributes.USAGE_MEDIA
        val contentType = if (isEarpiece) AudioAttributes.CONTENT_TYPE_SPEECH else AudioAttributes.CONTENT_TYPE_MUSIC

        val track = try {
            AudioTrack.Builder()
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(usage)
                        .setContentType(contentType)
                        .build()
                )
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(sampleRate)
                        .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                        .build()
                )
                .setBufferSizeInBytes(bufferSize)
                .setTransferMode(AudioTrack.MODE_STREAM)
                .build()
        } catch (_: Exception) {
            isCleanerRunning = false
            return
        }

        cleanerTrack = track
        track.play()

        val pcmChunk = ShortArray(bufferSize / 2)
        val startTime = System.currentTimeMillis()
        val totalMs = durationSec * 1000L
        var phase = 0.0
        var lastVibrateTime = 0L

        val vibrator = if (vibrate) getVibrator() else null

        while (isCleanerRunning && (System.currentTimeMillis() - startTime) < totalMs) {
            val elapsedMs = System.currentTimeMillis() - startTime
            val progress = (elapsedMs.toDouble() / totalMs).coerceIn(0.0, 1.0)

            // Calculate instantaneous frequency based on cleaning mode
            val currentFreq: Double = when (mode) {
                "water_eject" -> {
                    // Resonance oscillation: alternates between 150 Hz and 180 Hz with pulse modulation
                    val cycle = ((elapsedMs % 1500) / 1500.0)
                    155.0 + 25.0 * sin(cycle * 2.0 * Math.PI)
                }
                "dust_cleaner" -> {
                    // Stepped high-frequency acoustic shock: 250Hz -> 440Hz -> 850Hz -> 300Hz
                    val step = ((elapsedMs / 800) % 4).toInt()
                    when (step) {
                        0 -> 260.0
                        1 -> 440.0
                        2 -> 880.0
                        else -> 320.0
                    }
                }
                "manual" -> {
                    targetFreq.coerceIn(50.0, 2000.0)
                }
                else -> { // "auto" multi-stage cleaning
                    if (progress < 0.35) {
                        // Stage 1: Water ejection high-excursion low frequency (160 Hz)
                        160.0 + 15.0 * sin((elapsedMs % 1000) / 1000.0 * 2.0 * Math.PI)
                    } else if (progress < 0.70) {
                        // Stage 2: Dust cleaning resonant pulses (280 Hz to 600 Hz)
                        280.0 + (progress - 0.35) * (600.0 - 280.0) / 0.35
                    } else {
                        // Stage 3: Full acoustic spectrum sweep (120 Hz to 1200 Hz)
                        val sweep = ((elapsedMs % 3000) / 3000.0)
                        120.0 + sweep * 1080.0
                    }
                }
            }

            // Generate PCM samples with volume modulation for mechanical air pumping
            val phaseInc = 2.0 * Math.PI * currentFreq / sampleRate
            for (i in pcmChunk.indices) {
                phase += phaseInc
                if (phase > 2.0 * Math.PI) {
                    phase -= 2.0 * Math.PI
                }

                // Volume envelope (pulsing every 250ms for maximum push-pull air displacement)
                val pulseEnvelope = when (mode) {
                    "water_eject" -> {
                        val subCycle = (elapsedMs % 300) / 300.0
                        if (subCycle < 0.8) 0.95 else 0.15
                    }
                    "dust_cleaner" -> {
                        val subCycle = (elapsedMs % 200) / 200.0
                        if (subCycle < 0.7) 0.9 else 0.05
                    }
                    else -> 0.9
                }

                val sample = (sin(phase) * Short.MAX_VALUE * pulseEnvelope).toInt()
                pcmChunk[i] = sample.coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
            }

            track.write(pcmChunk, 0, pcmChunk.size)

            // Trigger mechanical haptic pulses every 1.5 seconds if vibration is enabled
            if (vibrate && vibrator != null && (elapsedMs - lastVibrateTime) > 1500) {
                lastVibrateTime = elapsedMs
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        vibrator.vibrate(VibrationEffect.createOneShot(120, VibrationEffect.DEFAULT_AMPLITUDE))
                    } else {
                        @Suppress("DEPRECATION")
                        vibrator.vibrate(120)
                    }
                } catch (_: Exception) {}
            }
        }

        stopSpeakerCleanerInternal()
    }

    private fun sampleMicAmplitude(): Double {
        val sampleRate = 44100
        val bufferSize = AudioRecord.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        if (bufferSize <= 0) return 0.0

        val record = try {
            AudioRecord(
                MediaRecorder.AudioSource.MIC,
                sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                bufferSize
            )
        } catch (_: Exception) {
            return 0.0
        }

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
