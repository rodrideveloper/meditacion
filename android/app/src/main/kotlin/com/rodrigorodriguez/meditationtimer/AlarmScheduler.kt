package com.rodrigorodriguez.meditationtimer

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * Clase helper para programar y cancelar alarmas usando AlarmManager.
 *
 * ESTRATEGIA (Samsung One UI + Android 15):
 * Usamos PendingIntent.getBroadcast() → AlarmReceiver.
 * AlarmReceiver publica una notificación con fullScreenIntent,
 * que tiene su propia exención y NO depende de BAL.
 *
 * Esto replica el patrón de Google Clock y funciona en Samsung
 * donde el AlarmManager no concede BAL al PendingIntent sender.
 */
class AlarmScheduler(private val context: Context) {
    
    companion object {
        const val TAG = "AlarmScheduler"
        const val ALARM_REQUEST_CODE = 12345
    }
    
    private val alarmManager: AlarmManager by lazy {
        context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    }
    
    /**
     * Programa una alarma para dispararse en el tiempo especificado.
     *
     * Usa PendingIntent.getBroadcast() → AlarmReceiver, que publica
     * una notificación con fullScreenIntent (no necesita BAL).
     *
     * @param triggerAtMillis Tiempo absoluto en milisegundos desde epoch
     * @param soundId ID del sonido a reproducir
     * @return true si la alarma fue programada exitosamente
     */
    fun scheduleAlarm(triggerAtMillis: Long, soundId: String): Boolean {
        return try {
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                action = AlarmReceiver.ACTION_ALARM_TRIGGERED
                putExtra(AlarmReceiver.EXTRA_SOUND_ID, soundId)
            }

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                ALARM_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            Log.d(TAG, "Created PendingIntent.getBroadcast() → AlarmReceiver")

            // showIntent: lo que se muestra cuando el usuario toca el icono de alarma en status bar
            val showIntent = PendingIntent.getActivity(
                context, 0,
                Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                },
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val alarmClockInfo = AlarmManager.AlarmClockInfo(triggerAtMillis, showIntent)
            alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)

            Log.d(TAG, "Alarm scheduled for: $triggerAtMillis (in ${(triggerAtMillis - System.currentTimeMillis()) / 1000} seconds)")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error scheduling alarm: ${e.message}", e)
            false
        }
    }
    
    /**
     * Programa una alarma relativa al tiempo actual.
     * 
     * @param delayMillis Tiempo en milisegundos desde ahora
     * @param soundId ID del sonido a reproducir
     * @return true si la alarma fue programada exitosamente
     */
    fun scheduleAlarmFromNow(delayMillis: Long, soundId: String): Boolean {
        val triggerAtMillis = System.currentTimeMillis() + delayMillis
        return scheduleAlarm(triggerAtMillis, soundId)
    }
    
    /**
     * Cancela la alarma programada.
     */
    fun cancelAlarm() {
        try {
            // Debe coincidir con el PendingIntent.getBroadcast() usado en scheduleAlarm
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                action = AlarmReceiver.ACTION_ALARM_TRIGGERED
            }

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                ALARM_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()

            Log.d(TAG, "Alarm cancelled")
        } catch (e: Exception) {
            Log.e(TAG, "Error cancelling alarm: ${e.message}")
        }
    }
    
    /**
     * Verifica si se pueden programar alarmas exactas.
     */
    fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }
    }
}
