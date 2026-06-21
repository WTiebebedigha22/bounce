package com.example.bounce_remake

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.content.Context
import android.provider.Settings
import android.media.AudioManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.bounce_remake/vibration"
    private val AUDIO_CHANNEL = "com.example.bounce_remake/audio"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Vibration channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "vibrate") {
                    val duration = call.argument<Int>("duration") ?: 100
                    vibrate(duration)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
            
        // Audio channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setVolume" -> {
                        val volume = call.argument<Int>("volume") ?: 50
                        setVolume(volume)
                        result.success(null)
                    }
                    "getVolume" -> {
                        val volume = getVolume()
                        result.success(volume)
                    }
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun vibrate(duration: Int) {
        val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(duration.toLong(), VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(duration.toLong())
        }
    }
    
    private fun setVolume(volume: Int) {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        val newVolume = (volume * maxVolume / 100)
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, newVolume, 0)
    }
    
    private fun getVolume(): Int {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
        return (currentVolume * 100 / maxVolume)
    }
}