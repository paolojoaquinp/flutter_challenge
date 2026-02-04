package com.example.flutter_challenge

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity(), NativeNotificationsApi {
    private val CHANNEL_ID = "likes_channel"
    private val NOTIFICATION_PERMISSION_REQUEST_CODE = 123
    private var pendingPermissionCallback: ((Result<Boolean>) -> Unit)? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NativeNotificationsApi.setUp(flutterEngine.dartExecutor.binaryMessenger, this)
        createNotificationChannel()
    }

    override fun showNotification(payload: NotificationPayload) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(payload.title)
            .setContentText(payload.body)
            .setPriority(NotificationCompat.PRIORITY_MAX) // Use high priority for better visibility
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setAutoCancel(true)

        notificationManager.notify(payload.id.toInt(), builder.build())
    }

    override fun requestPermissions(callback: (Result<Boolean>) -> Unit) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.POST_NOTIFICATIONS) ==
                PackageManager.PERMISSION_GRANTED
            ) {
                callback(Result.success(true))
            } else {
                pendingPermissionCallback = callback
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                    NOTIFICATION_PERMISSION_REQUEST_CODE
                )
            }
        } else {
            callback(Result.success(true))
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingPermissionCallback?.invoke(Result.success(granted))
            pendingPermissionCallback = null
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Likes"
            val descriptionText = "Notifications for liked posts"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
                enableVibration(true)
            }
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
