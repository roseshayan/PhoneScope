package com.phonescope.phonescope.channels

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class ShareHandler(private val context: Context, private var activity: Activity?) : MethodChannel.MethodCallHandler {

    fun setActivity(act: Activity?) {
        this.activity = act
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "shareFile" -> {
                val filePath = call.argument<String>("filePath")
                val mimeType = call.argument<String>("mimeType") ?: "*/*"
                val title = call.argument<String>("title") ?: "اشتراک‌گذاری گزارش PhoneScope"

                if (filePath.isNullOrEmpty()) {
                    result.error("INVALID_PATH", "File path cannot be empty", null)
                    return
                }

                try {
                    val file = File(filePath)
                    if (!file.exists()) {
                        result.error("FILE_NOT_FOUND", "File does not exist: $filePath", null)
                        return
                    }

                    val uri = FileProvider.getUriForFile(
                        context,
                        "com.phonescope.phonescope.fileprovider",
                        file
                    )

                    val shareIntent = Intent(Intent.ACTION_SEND).apply {
                        type = mimeType
                        putExtra(Intent.EXTRA_STREAM, uri)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }

                    val chooser = Intent.createChooser(shareIntent, title).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }

                    val currentActivity = activity
                    if (currentActivity != null) {
                        currentActivity.startActivity(chooser)
                    } else {
                        context.startActivity(chooser)
                    }

                    result.success(true)
                } catch (e: Exception) {
                    result.error("SHARE_ERROR", e.localizedMessage, null)
                }
            }

            "shareText" -> {
                val text = call.argument<String>("text") ?: ""
                val title = call.argument<String>("title") ?: "PhoneScope"

                try {
                    val shareIntent = Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_TEXT, text)
                    }
                    val chooser = Intent.createChooser(shareIntent, title).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    val currentActivity = activity
                    if (currentActivity != null) {
                        currentActivity.startActivity(chooser)
                    } else {
                        context.startActivity(chooser)
                    }
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SHARE_ERROR", e.localizedMessage, null)
                }
            }

            else -> result.notImplemented()
        }
    }
}
