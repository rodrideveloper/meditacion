package com.rodrigorodriguez.meditationtimer

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * Clase helper para programar y cancelar alarmas usando AlarmManager.
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
            
            // Usar setAlarmClock para máxima prioridad (como un despertador)
            val alarmClockInfo = AlarmManager.AlarmClockInfo(
                triggerAtMillis,
                pendingIntent // Intent para mostrar cuando el usuario toca el icono de alarma
            )
            
            alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
            
            Log.d(TAG, "Alarm scheduled for: $triggerAtMillis (in ${(triggerAtMillis - System.currentTimeMillis()) / 1000} seconds)")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error scheduling alarm: ${e.message}")
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
