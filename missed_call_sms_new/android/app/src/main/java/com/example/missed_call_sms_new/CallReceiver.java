package com.example.missed_call_sms_new;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.telephony.TelephonyManager;

public class CallReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        String state = intent.getStringExtra(TelephonyManager.EXTRA_STATE);
        String incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER);

        SharedPreferences prefs = context.getSharedPreferences("CallPrefs", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();

        if (TelephonyManager.EXTRA_STATE_RINGING.equals(state)) {
            editor.putString("last_incoming_number", incomingNumber);
            editor.putBoolean("was_missed", true);
            editor.apply();

        } else if (TelephonyManager.EXTRA_STATE_OFFHOOK.equals(state)) {
            editor.putBoolean("was_missed", false);
            editor.apply();

        } else if (TelephonyManager.EXTRA_STATE_IDLE.equals(state)) {
            boolean wasMissed = prefs.getBoolean("was_missed", false);
            String lastNumber = prefs.getString("last_incoming_number", null);

            editor.clear();
            editor.apply();

            if (wasMissed && lastNumber != null && !lastNumber.isEmpty()) {
                // FIXED: Changed from PersistentSmsService.class to SmsService.class
                Intent serviceIntent = new Intent(context, SmsService.class);
                serviceIntent.putExtra("phoneNumber", lastNumber);
                
                // Check if service is already running
                SharedPreferences servicePrefs = context.getSharedPreferences("ServicePrefs", Context.MODE_PRIVATE);
                boolean serviceRunning = servicePrefs.getBoolean("serviceRunning", false);
                
                if (serviceRunning) {
                    // Service is running, just send intent
                    context.startService(serviceIntent);
                } else {
                    // Start as foreground service
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        context.startForegroundService(serviceIntent);
                    } else {
                        context.startService(serviceIntent);
                    }
                }
            }
        }
    }
}