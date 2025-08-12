// android/app/src/main/kotlin/.../MainActivity.kt
package com.shwapno.survey

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "shwapno.app/update"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "installApk" -> {
                        val apkPath = call.argument<String>("apkPath")
                        if (apkPath.isNullOrEmpty()) {
                            result.error("NO_PATH", "APK path is null/empty", null)
                            return@setMethodCallHandler
                        }
                        try {
                            // Check install-permission on Android O+
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                                !packageManager.canRequestPackageInstalls()
                            ) {
                                // Tell Dart to open settings
                                result.error(
                                    "NO_PERMISSION",
                                    "User must allow 'Install unknown apps'",
                                    null
                                )
                                return@setMethodCallHandler
                            }

                            val file = File(apkPath)
                            val uri = FileProvider.getUriForFile(
                                this,
                                BuildConfig.APPLICATION_ID + ".provider",
                                file
                            )
                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                setDataAndType(uri, "application/vnd.android.package-archive")
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                            }
                            startActivity(intent)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("INSTALL_ERROR", e.localizedMessage, null)
                        }
                    }

                    // NEW: open "Install unknown apps" settings for this app
                    "openUnknownSourcesSettings" -> {
                        try {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                                Uri.parse("package:$packageName")
                            ).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
                            startActivity(intent)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("OPEN_SETTINGS_ERROR", e.localizedMessage, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
