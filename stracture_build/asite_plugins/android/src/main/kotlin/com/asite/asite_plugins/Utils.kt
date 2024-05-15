package com.asite.asite_plugins

import android.content.Context
import android.provider.Settings
import java.util.*

/**
 * Created by Chandresh Patel on 23-05-2023.
 */
object Utils {
    fun getUniqueAnnotationId(): String? {
        return UUID.randomUUID().toString() + "-" + Calendar.getInstance().timeInMillis
    }

    fun getUniqueDeviceId(context: Context): String? {
        return Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
    }

    fun getDeviceSdkInt():Int {
        return android.os.Build.VERSION.SDK_INT
    }
}