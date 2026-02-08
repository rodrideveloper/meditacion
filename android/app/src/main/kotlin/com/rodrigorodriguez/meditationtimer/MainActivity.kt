package com.rodrigorodriguez.meditationtimer

import android.app.NotificationManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
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
    private var hasRequestedOverlayPermission = false
    private var flutterReady = false
    
    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d(TAG, "=== onCreate START ===")
        Log.d(TAG, "savedInstanceState is null: ${savedInstanceState == null}")
        Log.d(TAG, "Intent action: ${intent?.action}")
        Log.d(TAG, "Intent extras: ${intent?.extras}")
        super.onCreate(savedInstanceState)
        
        // Configurar para mostrar sobre lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            Log.d(TAG, "setShowWhenLocked + setTurnScreenOn configured")
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
            Log.d(TAG, "Legacy window flags configured")
        }
        
        alarmScheduler = AlarmScheduler(this)
        
        // Manejar intent inicial
        handleIntent(intent)
        Log.d(TAG, "=== onCreate END ===")
    }
    
    override fun onNewIntent(intent: Intent) {
        Log.d(TAG, "=== onNewIntent ===")
        Log.d(TAG, "New intent action: ${intent.action}")
        Log.d(TAG, "New intent extras: ${intent.extras}")
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }
    
    /**
     * Maneja el intent de alarma.
     *
     * Con el patrón fullScreenIntent:
     * - Pantalla apagada → fullScreenIntent lanza esta Activity directamente
     * - Pantalla encendida → usuario toca la heads-up notification → llega aquí
     *
     * En ambos casos el intent tiene ACTION_ALARM_TRIGGERED y EXTRA_SOUND_ID.
     */
    @Suppress("DEPRECATION")
    private fun handleIntent(intent: Intent?) {
        Log.d(TAG, "=== handleIntent ===")
        Log.d(TAG, "Intent action: ${intent?.action}")

        if (intent?.action == AlarmReceiver.ACTION_ALARM_TRIGGERED) {
            val soundId = intent.getStringExtra(AlarmReceiver.EXTRA_SOUND_ID) ?: "angelical"
            Log.d(TAG, ">>> ALARM INTENT DETECTED (via fullScreenIntent)! Sound ID: $soundId")

            // Limpiar la action para evitar re-procesamiento
            intent.action = null

            // 1. Cancelar la notificación de alarma (ya estamos en la Activity)
            try {
                val nm = getSystemService(NotificationManager::class.java)
                nm.cancel(AlarmReceiver.NOTIFICATION_ID)
                Log.d(TAG, "Alarm notification cancelled (Activity is now visible)")
            } catch (e: Exception) {
                Log.e(TAG, "Error cancelling notification: ${e.message}")
            }

            // 2. WakeLock para encender la pantalla (si está apagada)
            try {
                val pm = getSystemService(POWER_SERVICE) as PowerManager
                val wakeLock = pm.newWakeLock(
                    PowerManager.FULL_WAKE_LOCK or
                    PowerManager.ACQUIRE_CAUSES_WAKEUP or
                    PowerManager.ON_AFTER_RELEASE,
                    "meditation_app:alarm_wakelock"
                )
                wakeLock.acquire(30 * 1000L)
                Log.d(TAG, "WakeLock acquired")
                // Soltar inmediatamente — solo necesitamos que encienda la pantalla
                if (wakeLock.isHeld) {
                    wakeLock.release()
                    Log.d(TAG, "WakeLock released")
                }
            } catch (e: Exception) {
                Log.e(TAG, "WakeLock error: ${e.message}")
            }

            // 3. Enviar evento a Flutter
            //    En cold start, Flutter aún no ejecutó main() y el callback
            //    onAlarmTriggered es null. Guardamos como pending y Dart lo
            //    recoge con checkPendingAlarm al final de su inicialización.
            Log.d(TAG, "methodChannel is null: ${methodChannel == null}, flutterReady: $flutterReady")
            if (methodChannel != null && flutterReady) {
                Log.d(TAG, "Sending alarmTriggered to Flutter via MethodChannel")
                runOnUiThread {
                    try {
                        methodChannel?.invokeMethod("alarmTriggered", mapOf("soundId" to soundId))
                        Log.d(TAG, "alarmTriggered sent to Flutter successfully")
                    } catch (e: Exception) {
                        Log.e(TAG, "Error sending alarmTriggered to Flutter: ${e.message}", e)
                    }
                }
            } else {
                Log.d(TAG, "Flutter not ready yet, saving pendingAlarmSoundId=$soundId")
                pendingAlarmSoundId = soundId
            }
        } else {
            Log.d(TAG, "Intent is NOT an alarm trigger, ignoring")
        }
    }

    /**
     * Verifica que USE_FULL_SCREEN_INTENT está concedido.
     * En Android 14+ (API 34+), este permiso NO es auto-granted.
     * Sin él, fullScreenIntent en la notificación es ignorado silenciosamente.
     * 
     * También verifica SYSTEM_ALERT_WINDOW que Samsung necesita para
     * mostrar fullScreenIntent con pantalla encendida.
     */
    private fun ensureFullScreenIntentPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) { // API 34+
            val nm = getSystemService(NotificationManager::class.java)
            val canUse = nm.canUseFullScreenIntent()
            Log.d(TAG, "canUseFullScreenIntent() = $canUse")
            if (!canUse) {
                Log.w(TAG, "⚠️ USE_FULL_SCREEN_INTENT NOT granted! Opening settings...")
                try {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT,
                        Uri.parse("package:$packageName")
                    )
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                } catch (e: Exception) {
                    Log.e(TAG, "Error opening fullscreen intent settings: ${e.message}")
                }
            }
        }

        // Samsung necesita SYSTEM_ALERT_WINDOW para fullScreenIntent con pantalla ON
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val canDraw = Settings.canDrawOverlays(this)
            Log.d(TAG, "canDrawOverlays() = $canDraw")
            if (!canDraw) {
                Log.w(TAG, "⚠️ SYSTEM_ALERT_WINDOW NOT granted! Opening settings...")
                try {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName")
                    )
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                } catch (e: Exception) {
                    Log.e(TAG, "Error opening overlay settings: ${e.message}")
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        Log.d(TAG, "=== onResume === pendingAlarmSoundId=$pendingAlarmSoundId, methodChannel=${methodChannel != null}")
        
        // Solicitar permisos de pantalla completa y overlay DESPUÉS de que
        // Flutter esté inicializado, y solo UNA VEZ por sesión de app.
        if (!hasRequestedOverlayPermission) {
            hasRequestedOverlayPermission = true
            // Pequeño delay para que Flutter termine de inicializarse
            android.os.Handler(mainLooper).postDelayed({
                ensureFullScreenIntentPermission()
            }, 1500)
        }
    }
    
    override fun onPause() {
        super.onPause()
        Log.d(TAG, "=== onPause ===")
    }
    
    override fun onDestroy() {
        Log.d(TAG, "=== onDestroy ===")
        super.onDestroy()
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.d(TAG, "=== configureFlutterEngine START ===")
        super.configureFlutterEngine(flutterEngine)
        
        // Method Channel bidireccional: Flutter <-> Native
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        Log.d(TAG, "MethodChannel created. pendingAlarmSoundId=$pendingAlarmSoundId")
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
                        // Cancelar notificación de alarma
                        val nm = getSystemService(NotificationManager::class.java)
                        nm.cancel(AlarmReceiver.NOTIFICATION_ID)
                        result.success(true)
                    }
                    "cancelAlarmNotification" -> {
                        Log.d(TAG, "cancelAlarmNotification called from Flutter")
                        val nmService = getSystemService(NotificationManager::class.java)
                        nmService.cancel(AlarmReceiver.NOTIFICATION_ID)
                        result.success(true)
                    }
                    "canScheduleExactAlarms" -> {
                        result.success(alarmScheduler.canScheduleExactAlarms())
                    }
                    "checkPendingAlarm" -> {
                        // Flutter terminó su inicialización — marcar como ready
                        flutterReady = true
                        // Verificar si hay una alarma pendiente de procesar
                        Log.d(TAG, "checkPendingAlarm called. flutterReady=true, pendingAlarmSoundId=$pendingAlarmSoundId")
                        if (pendingAlarmSoundId != null) {
                            Log.d(TAG, ">>> Returning pending alarm: soundId=$pendingAlarmSoundId")
                            result.success(mapOf(
                                "hasPending" to true,
                                "soundId" to pendingAlarmSoundId
                            ))
                            pendingAlarmSoundId = null
                        } else {
                            Log.d(TAG, "No pending alarm")
                            result.success(mapOf("hasPending" to false))
                        }
                    }
                    else -> {
                        Log.d(TAG, "Unknown method call: ${call.method}")
                        result.notImplemented()
                    }
                }
            }
        Log.d(TAG, "=== configureFlutterEngine END ===")
    }
}
