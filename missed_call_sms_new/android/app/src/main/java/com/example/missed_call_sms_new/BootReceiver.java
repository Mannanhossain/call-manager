package com.example.missed_call_sms_new;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction()) ||
            "android.intent.action.QUICKBOOT_POWERON".equals(intent.getAction())) {
            
            // Check if service was running before reboot
            SharedPreferences prefs = context.getSharedPreferences("ServicePrefs", Context.MODE_PRIVATE);
            boolean wasRunning = prefs.getBoolean("serviceRunning", false);
            
            if (wasRunning) {
                // Restart the service - MAKE SURE THIS LINE USES SmsService.class
                Intent serviceIntent = new Intent(context, SmsService.class); // CORRECT CLASS NAME
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent);
                } else {
                    context.startService(serviceIntent);
                }
            }
        }
    }
}