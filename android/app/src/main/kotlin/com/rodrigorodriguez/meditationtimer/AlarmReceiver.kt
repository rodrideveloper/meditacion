package com.rodrigorodriguez.meditationtimer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * BroadcastReceiver que se dispara cuando AlarmManager ejecuta la alarma.
 *
 * Flujo simplificado:
 *   - Pantalla encendida → startActivity() directo
 *   - Pantalla apagada/bloqueada → notificación con fullScreenIntent (el sistema abre la Activity)
 *
 * El sonido se reproduce 100 % desde Flutter via MethodChannel.
 */
class AlarmReceiver : BroadcastReceiver() {

    companion object {
        const val TAG = "AlarmReceiver"
        const val ACTION_ALARM_TRIGGERED = "com.rodrigorodriguez.meditationtimer.ALARM_TRIGGERED"
        const val EXTRA_SOUND_ID = "sound_id"
        const val EXTRA_VIBRATION_ENABLED = "vibration_enabled"
        const val NOTIFICATION_ID = 2001
        const val ALARM_CHANNEL_VIBRATING_ID = "meditation_alarm_vibrating_v5"
        const val ALARM_CHANNEL_SILENT_ID = "meditation_alarm_silent_v5"
        private val VIBRATION_PATTERN = longArrayOf(0, 500, 200, 500, 200, 500)
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "=== AlarmReceiver.onReceive START ===")
        Log.d(TAG, "Action: ${intent.action}")

        if (intent.action != ACTION_ALARM_TRIGGERED) {
            Log.d(TAG, "Unknown action, ignoring")
            return
        }

        val soundId = intent.getStringExtra(EXTRA_SOUND_ID) ?: "angelical"
        val vibrationEnabled = intent.getBooleanExtra(EXTRA_VIBRATION_ENABLED, true)
        Log.d(TAG, "Sound ID: $soundId, vibration enabled: $vibrationEnabled")

        // Intent para abrir / traer la Activity
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            action = ACTION_ALARM_TRIGGERED
            putExtra(EXTRA_SOUND_ID, soundId)
            putExtra(EXTRA_VIBRATION_ENABLED, vibrationEnabled)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
        }

        val screenOn = isScreenInteractive(context)
        Log.d(TAG, "Screen interactive: $screenOn")

        if (screenOn) {
            // ── Pantalla ENCENDIDA → startActivity() directo ──
            Log.d(TAG, ">>> Screen ON → startActivity()")
            try {
                // Sin notificación en este flujo: dar feedback con el vibrador.
                if (vibrationEnabled) triggerVibration(context)
                context.startActivity(launchIntent)
                Log.d(TAG, ">>> startActivity() OK")
            } catch (e: Exception) {
                Log.e(TAG, ">>> startActivity() FAILED: ${e.message}", e)
                // Fallback: notificación con fullScreenIntent
                Log.d(TAG, ">>> Fallback → posting fullScreenIntent notification")
                postAlarmNotification(context, vibrationEnabled, launchIntent)
            }
        } else {
            // ── Pantalla APAGADA / BLOQUEADA → fullScreenIntent ──
            Log.d(TAG, ">>> Screen OFF → posting fullScreenIntent notification")
            acquireScreenWakeLock(context)
            postAlarmNotification(context, vibrationEnabled, launchIntent)
        }

        Log.d(TAG, "=== AlarmReceiver.onReceive END ===")
    }

    // ─── helpers ───────────────────────────────────────────────

    private fun isScreenInteractive(context: Context): Boolean {
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isInteractive
    }

    @Suppress("DEPRECATION")
    private fun acquireScreenWakeLock(context: Context) {
        try {
            val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            val wl = pm.newWakeLock(
                PowerManager.FULL_WAKE_LOCK or
                PowerManager.ACQUIRE_CAUSES_WAKEUP or
                PowerManager.ON_AFTER_RELEASE,
                "meditation_app:alarm_wakelock"
            )
            wl.acquire(10_000L) // 10 s máx
            Log.d(TAG, "WakeLock acquired (screen wake)")
        } catch (e: Exception) {
            Log.e(TAG, "WakeLock error: ${e.message}")
        }
    }

    private fun postAlarmNotification(
        context: Context,
        vibrationEnabled: Boolean,
        launchIntent: Intent
    ) {
        ensureNotificationChannels(context)
        val channelId = if (vibrationEnabled) ALARM_CHANNEL_VIBRATING_ID else ALARM_CHANNEL_SILENT_ID

        val fullScreenPI = PendingIntent.getActivity(
            context, NOTIFICATION_ID, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val dismissPI = PendingIntent.getBroadcast(
            context, 2,
            Intent(context, AlarmDismissReceiver::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("🧘 Meditación Completada")
            .setContentText("Tu sesión de meditación ha terminado. Toca para abrir.")
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(false)
            .setOngoing(true)
            .setFullScreenIntent(fullScreenPI, true)
            .setContentIntent(fullScreenPI)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Descartar", dismissPI)
            .setVibrate(if (vibrationEnabled) VIBRATION_PATTERN else null)
            // Sin sonido nativo — Flutter maneja el audio
            .setSilent(!vibrationEnabled)
            .build()

        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, notification)
        Log.d(TAG, "Alarm notification posted (ID=$NOTIFICATION_ID)")
    }

    private fun ensureNotificationChannels(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // Limpiar canales obsoletos
            listOf(
                "meditation_alarm_channel", "meditation_alarm_channel_v2",
                "meditation_alarm_v3", "meditation_alarm_fg_channel",
                "meditation_fg_service_channel"
            ).forEach { nm.deleteNotificationChannel(it) }

            listOf(
                ALARM_CHANNEL_VIBRATING_ID to true,
                ALARM_CHANNEL_SILENT_ID to false
            ).forEach { (channelId, shouldVibrate) ->
                val channel = NotificationChannel(
                    channelId,
                    "Alarma de Meditación",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Alarma cuando la meditación termina"
                    setBypassDnd(true)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                    enableVibration(shouldVibrate)
                    if (shouldVibrate) vibrationPattern = VIBRATION_PATTERN
                    enableLights(true)
                    setSound(null, null) // sin sonido nativo — Flutter maneja el audio
                }
                nm.createNotificationChannel(channel)
                Log.d(TAG, "Notification channel created: $channelId")
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun triggerVibration(context: Context) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vm = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vm.defaultVibrator.vibrate(
                    VibrationEffect.createWaveform(longArrayOf(0, 500, 200, 500), -1)
                )
            } else {
                val v = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    v.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 500, 200, 500), -1))
                } else {
                    v.vibrate(longArrayOf(0, 500, 200, 500), -1)
                }
            }
            Log.d(TAG, "Vibration triggered")
        } catch (e: Exception) {
            Log.e(TAG, "Vibration error: ${e.message}")
        }
    }
}

/**
 * Receiver para descartar la notificación de alarma (botón "Descartar").
 */
class AlarmDismissReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(AlarmReceiver.TAG, "Alarm dismissed by user")
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.cancel(AlarmReceiver.NOTIFICATION_ID)
    }
}
