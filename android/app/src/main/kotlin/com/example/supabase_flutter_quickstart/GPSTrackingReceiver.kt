package com.example.supabase_flutter_quickstart

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class GPSTrackingReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "GPSTrackingReceiver"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        Log.d(TAG, "GPS tracking broadcast received")
    }
}
