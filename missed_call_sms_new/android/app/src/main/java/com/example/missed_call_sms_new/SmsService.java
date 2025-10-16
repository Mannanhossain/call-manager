

// package com.example.missed_call_sms_new;

// import android.app.Notification;
// import android.app.NotificationChannel;
// import android.app.NotificationManager;
// import android.app.PendingIntent;
// import android.app.Service;
// import android.content.Intent;
// import android.content.SharedPreferences;
// import android.net.Uri;
// import android.os.Build;
// import android.os.IBinder;
// import android.os.PowerManager;
// import android.preference.PreferenceManager;
// import androidx.annotation.Nullable;
// import androidx.core.app.NotificationCompat;
// import androidx.core.content.ContextCompat;
// import android.content.pm.PackageManager;
// import android.Manifest;
// import android.telephony.SmsManager;
// import android.util.Log;

// public class SmsService extends Service {
//     private static final String CHANNEL_ID = "AutoSmsServiceChannel";
//     private static final int NOTIFICATION_ID = 123;
//     private PowerManager.WakeLock wakeLock;

//     @Override
//     public void onCreate() {
//         super.onCreate();
//         createNotificationChannel();
//         acquireWakeLock();

//         SharedPreferences prefs = getSharedPreferences("ServicePrefs", MODE_PRIVATE);
//         prefs.edit().putBoolean("serviceRunning", true).apply();

//         Log.d("SmsService", "Service created and marked as running");
//     }

//     @Override
//     public int onStartCommand(Intent intent, int flags, int startId) {
//         Notification notification = createPersistentNotification("Service is running in background");
//         startForeground(NOTIFICATION_ID, notification);

//         if (intent != null && intent.hasExtra("phoneNumber")) {
//             handleSmsAndNotification(intent);
//         }

//         return START_STICKY;
//     }

//     private Notification createPersistentNotification(String text) {
//         return new NotificationCompat.Builder(this, CHANNEL_ID)
//                 .setContentTitle("Missed Call Auto SMS")
//                 .setContentText(text)
//                 .setSmallIcon(android.R.drawable.ic_dialog_email)
//                 .setPriority(NotificationCompat.PRIORITY_LOW)
//                 .setCategory(NotificationCompat.CATEGORY_SERVICE)
//                 .setOngoing(true)
//                 .setOnlyAlertOnce(true)
//                 .build();
//     }

//     private void handleSmsAndNotification(Intent intent) {
//         String phoneNumber = intent.getStringExtra("phoneNumber");
//         SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
//         String smsMessage = prefs.getString("smsMessage", "Sorry I missed your call. I'll get back to you soon!");

//         if (phoneNumber != null && !phoneNumber.isEmpty()) {
//             // ✅ Send SMS automatically
//             if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED) {
//                 try {
//                     SmsManager smsManager = SmsManager.getDefault();
//                     smsManager.sendTextMessage(phoneNumber, null, smsMessage, null, null);
//                     Log.d("SmsService", "SMS sent to: " + phoneNumber);
//                 } catch (Exception e) {
//                     Log.e("SmsService", "Failed to send SMS: " + e.getMessage());
//                 }
//             }

//             // ✅ Show WhatsApp notification instead of directly opening it
//             showWhatsAppNotification(phoneNumber, smsMessage);
//         }
//     }

//     private void showWhatsAppNotification(String phoneNumber, String smsMessage) {
//         try {
//             String waNumber = phoneNumber.replace("+", "").replace(" ", "");
//             String url = "https://wa.me/" + waNumber + "?text=" + Uri.encode(smsMessage);

//             Intent whatsappIntent = new Intent(Intent.ACTION_VIEW);
//             whatsappIntent.setData(Uri.parse(url));
//             whatsappIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);

//             PendingIntent pendingIntent = PendingIntent.getActivity(
//                     this,
//                     0,
//                     whatsappIntent,
//                     PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
//             );

//             Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
//                     .setContentTitle("Missed Call Detected")
//                     .setContentText("Tap to send WhatsApp message to " + phoneNumber)
//                     .setSmallIcon(android.R.drawable.ic_dialog_info)
//                     .setPriority(NotificationCompat.PRIORITY_HIGH)
//                     .setAutoCancel(true)
//                     .addAction(android.R.drawable.ic_menu_send, "Send WhatsApp", pendingIntent)
//                     .build();

//             NotificationManager manager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
//             if (manager != null) {
//                 manager.notify((int) System.currentTimeMillis(), notification);
//             }

//             Log.d("SmsService", "WhatsApp notification created for: " + phoneNumber);

//         } catch (Exception e) {
//             Log.e("SmsService", "Failed to show WhatsApp notification: " + e.getMessage());
//         }
//     }

//     private void acquireWakeLock() {
//         try {
//             PowerManager powerManager = (PowerManager) getSystemService(POWER_SERVICE);
//             wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "MissedCallSMS::WakeLock");
//             wakeLock.acquire(10 * 60 * 1000L);
//         } catch (Exception e) {
//             Log.e("SmsService", "Failed to acquire wake lock: " + e.getMessage());
//         }
//     }

//     private void createNotificationChannel() {
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//             NotificationChannel channel = new NotificationChannel(
//                     CHANNEL_ID,
//                     "Missed Call Auto SMS",
//                     NotificationManager.IMPORTANCE_HIGH
//             );
//             channel.setDescription("Service for sending auto SMS on missed calls");
//             NotificationManager manager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
//             if (manager != null) {
//                 manager.createNotificationChannel(channel);
//             }
//         }
//     }

//     @Override
//     public void onTaskRemoved(Intent rootIntent) {
//         Intent restartIntent = new Intent(this, SmsService.class);
//         restartIntent.setPackage(getPackageName());
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//             startForegroundService(restartIntent);
//         } else {
//             startService(restartIntent);
//         }
//         super.onTaskRemoved(rootIntent);
//     }

//     @Override
//     public void onDestroy() {
//         if (wakeLock != null && wakeLock.isHeld()) {
//             wakeLock.release();
//         }
//         SharedPreferences prefs = getSharedPreferences("ServicePrefs", MODE_PRIVATE);
//         prefs.edit().putBoolean("serviceRunning", false).apply();
//         Log.d("SmsService", "Service destroyed");
//         super.onDestroy();
//     }

//     @Nullable
//     @Override
//     public IBinder onBind(Intent intent) {
//         return null;
//     }
// }
package com.example.missed_call_sms_new;

import android.app.Service;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Build;
import android.os.IBinder;
import android.os.PowerManager;
import android.preference.PreferenceManager;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import android.Manifest;
import android.content.pm.PackageManager;
import android.telephony.SmsManager;

public class SmsService extends Service {

    private PowerManager.WakeLock wakeLock;

    @Override
    public void onCreate() {
        super.onCreate();
        acquireWakeLock();
        Log.d("SmsService", "Service created");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && intent.hasExtra("phoneNumber")) {
            String phoneNumber = intent.getStringExtra("phoneNumber");
            SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
            String smsMessage = prefs.getString("smsMessage", 
                    "Sorry I missed your call. I'll get back to you soon!");

            // ✅ Send SMS automatically
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS)
                    == PackageManager.PERMISSION_GRANTED) {
                try {
                    SmsManager smsManager = SmsManager.getDefault();
                    smsManager.sendTextMessage(phoneNumber, null, smsMessage, null, null);
                    Log.d("SmsService", "SMS sent to: " + phoneNumber);
                } catch (Exception e) {
                    Log.e("SmsService", "Failed to send SMS: " + e.getMessage());
                }
            } else {
                Log.e("SmsService", "SEND_SMS permission not granted");
            }

            // ✅ Directly open WhatsApp message screen
            openWhatsApp(phoneNumber, smsMessage);
        }

        return START_STICKY;
    }

    private void openWhatsApp(String phoneNumber, String smsMessage) {
        try {
            String waNumber = phoneNumber.replace("+", "").replace(" ", "");
            String url = "https://wa.me/" + waNumber + "?text=" + Uri.encode(smsMessage);
            Intent whatsappIntent = new Intent(Intent.ACTION_VIEW);
            whatsappIntent.setData(Uri.parse(url));
            whatsappIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(whatsappIntent);
            Log.d("SmsService", "Opened WhatsApp for number: " + phoneNumber);
        } catch (Exception e) {
            Log.e("SmsService", "Failed to open WhatsApp: " + e.getMessage());
        }
    }

    private void acquireWakeLock() {
        try {
            PowerManager powerManager = (PowerManager) getSystemService(POWER_SERVICE);
            wakeLock = powerManager.newWakeLock(
                    PowerManager.PARTIAL_WAKE_LOCK, "MissedCallSMS::WakeLock");
            wakeLock.acquire(10 * 60 * 1000L); // hold for 10 minutes
        } catch (Exception e) {
            Log.e("SmsService", "Failed to acquire wake lock: " + e.getMessage());
        }
    }

    @Override
    public void onDestroy() {
        if (wakeLock != null && wakeLock.isHeld()) {
            wakeLock.release();
        }
        Log.d("SmsService", "Service destroyed");
        super.onDestroy();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
