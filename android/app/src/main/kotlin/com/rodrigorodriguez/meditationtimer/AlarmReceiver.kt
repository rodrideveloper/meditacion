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
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * BroadcastReceiver que se ejecuta cuando la alarma programada se dispara.
 * Muestra directamente una notificación con fullScreenIntent para abrir la app.
 * No necesita Foreground Service ya que setAlarmClock() garantiza la ejecución.
 */
class AlarmReceiver : BroadcastReceiver() {
    
    companion object {
        const val TAG = "AlarmReceiver"
        const val ACTION_ALARM_TRIGGERED = "com.rodrigorodriguez.meditationtimer.ALARM_TRIGGERED"
        const val EXTRA_SOUND_ID = "sound_id"
        const val CHANNEL_ID = "meditation_alarm_channel"
        const val NOTIFICATION_ID = 2001
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Alarm received!")
        
        val soundId = intent.getStringExtra(EXTRA_SOUND_ID) ?: "angelical"
        Log.d(TAG, "Sound ID: $soundId")
        
        // Adquirir WakeLock temporal para asegurar que la notificación se muestre
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "meditation_app:alarm_receiver_wakelock"
        )
        wakeLock.acquire(10 * 1000L) // 10 segundos máximo
        
        try {
            createNotificationChannel(context)
            showAlarmNotification(context, soundId)
            Log.d(TAG, "Alarm notification shown")
        } catch (e: Exception) {
            Log.e(TAG, "Error showing alarm notification: ${e.message}")
        } finally {
            if (wakeLock.isHeld) {
                wakeLock.release()
                Log.d(TAG, "Receiver WakeLock released")
            }
        }
    }
    
    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Alarma de Meditación",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notificaciones de alarma de meditación"
                setBypassDnd(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                setShowBadge(true)
                enableVibration(true)
                enableLights(true)
            }
            
            val notificationManager = context.getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun showAlarmNotification(context: Context, soundId: String) {
        // Intent para abrir la app en pantalla completa
        val fullScreenIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            action = ACTION_ALARM_TRIGGERED
            putExtra(EXTRA_SOUND_ID, soundId)
        }
        
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context,
            0,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Intent para descartar la notificación
        val dismissIntent = Intent(context, AlarmDismissReceiver::class.java)
        val dismissPendingIntent = PendingIntent.getBroadcast(
            context,
            1,
            dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("🧘 Meditación Completada")
            .setContentText("Tu sesión de meditación ha terminado")
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(true)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setContentIntent(fullScreenPendingIntent)
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "Descartar",
                dismissPendingIntent
            )
            .build()
        
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }
}

/**
 * Receiver simple para descartar la notificación de alarma.
 */
class AlarmDismissReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(AlarmReceiver.NOTIFICATION_ID)
        Log.d(AlarmReceiver.TAG, "Alarm notification dismissed")
    }
}
