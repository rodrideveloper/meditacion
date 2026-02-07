package com.rodrigorodriguez.meditationtimer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * BroadcastReceiver que se ejecuta cuando el dispositivo reinicia.
 * Puede usarse para reprogramar alarmas si es necesario.
 */
class BootReceiver : BroadcastReceiver() {
    
    companion object {
        const val TAG = "BootReceiver"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == Intent.ACTION_MY_PACKAGE_REPLACED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON" ||
            intent.action == "com.htc.intent.action.QUICKBOOT_POWERON") {
            
            Log.d(TAG, "Boot completed or package replaced")
            
            // Aquí podrías reprogramar alarmas guardadas en SharedPreferences
            // Por ahora solo logueamos el evento
            // Las alarmas programadas con setAlarmClock sobreviven reinicios
            // solo si fueron programadas correctamente
        }
    }
}
