package com.example.supabase_flutter_quickstart

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import android.app.AlarmManager
import android.app.PendingIntent
import java.util.Calendar

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "android.intent.action.BOOT_COMPLETED") {
            Log.d("ShieldCheck", "Device booted, starting GPS tracking service")
            scheduleGPSTracking(context)
        }
    }

    private fun scheduleGPSTracking(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, GPSTrackingReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val calendar = Calendar.getInstance().apply {
            timeInMillis = System.currentTimeMillis()
            add(Calendar.MINUTE, 5)
        }

        try {
            alarmManager.setRepeating(
                AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                5 * 60 * 1000, // 5 minutes
                pendingIntent
            )
            Log.d("ShieldCheck", "GPS tracking scheduled")
        } catch (e: Exception) {
            Log.e("ShieldCheck", "Error scheduling GPS tracking: ${e.message}")
        }
    }
}

class GPSTrackingReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("ShieldCheck", "GPS tracking alarm triggered")
    }
}
