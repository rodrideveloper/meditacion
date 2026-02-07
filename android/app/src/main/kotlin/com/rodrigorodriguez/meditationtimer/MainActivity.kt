package com.rodrigorodriguez.meditationtimer

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    
    companion object {
        const val TAG = "MainActivity"
        const val METHOD_CHANNEL = "com.rodrigorodriguez.meditationtimer/alarm"
    }
    
    private lateinit var alarmScheduler: AlarmScheduler
    private var methodChannel: MethodChannel? = null
    private var pendingAlarmSoundId: String? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Configurar para mostrar sobre lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
        
        alarmScheduler = AlarmScheduler(this)
        
        // Manejar intent inicial
        handleIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }
    
    private fun handleIntent(intent: Intent?) {
        if (intent?.action == AlarmReceiver.ACTION_ALARM_TRIGGERED) {
            val soundId = intent.getStringExtra(AlarmReceiver.EXTRA_SOUND_ID) ?: "angelical"
            Log.d(TAG, "Alarm triggered! Sound ID: $soundId")
            
            // Cancelar la notificación ya que la UI está visible
            cancelAlarmNotification()
            
            // Si Flutter ya está listo, enviar evento
            if (methodChannel != null) {
                runOnUiThread {
                    methodChannel?.invokeMethod("alarmTriggered", mapOf("soundId" to soundId))
                }
            } else {
                // Guardar para enviar cuando Flutter esté listo
                pendingAlarmSoundId = soundId
            }
        }
    }
    
    private fun cancelAlarmNotification() {
        try {
            val notificationManager = getSystemService(android.app.NotificationManager::class.java)
            notificationManager.cancel(AlarmReceiver.NOTIFICATION_ID)
            Log.d(TAG, "Alarm notification cancelled")
        } catch (e: Exception) {
            Log.e(TAG, "Error cancelling alarm notification: ${e.message}")
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Method Channel bidireccional: Flutter <-> Native
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel!!.setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAlarm" -> {
                        // Flutter envía int, convertir a Long
                        val delayMillis = (call.argument<Number>("delayMillis") ?: 0).toLong()
                        val soundId = call.argument<String>("soundId") ?: "angelical"
                        Log.d(TAG, "scheduleAlarm called: delayMillis=$delayMillis, soundId=$soundId")
                        val success = alarmScheduler.scheduleAlarmFromNow(delayMillis, soundId)
                        result.success(success)
                    }
                    "cancelAlarm" -> {
                        alarmScheduler.cancelAlarm()
                        cancelAlarmNotification()
                        result.success(true)
                    }
                    "canScheduleExactAlarms" -> {
                        result.success(alarmScheduler.canScheduleExactAlarms())
                    }
                    "checkPendingAlarm" -> {
                        // Verificar si hay una alarma pendiente de procesar
                        if (pendingAlarmSoundId != null) {
                            result.success(mapOf(
                                "hasPending" to true,
                                "soundId" to pendingAlarmSoundId
                            ))
                            pendingAlarmSoundId = null
                        } else {
                            result.success(mapOf("hasPending" to false))
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        
    }
}
