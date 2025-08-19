// android/app/src/main/kotlin/com/shwapno/survey2/MainActivity.kt
package com.shwapno.survey2

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val UPDATE_CHANNEL = "shwapno.app/update"
    private val MIGRATION_CHANNEL = "app.migration"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ---- Updater channel (existing) ----
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, UPDATE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "installApk" -> {
                        val apkPath = call.argument<String>("apkPath")
                        if (apkPath.isNullOrEmpty()) {
                            result.error("NO_PATH", "APK path is null/empty", null); return@setMethodCallHandler
                        }
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                                !packageManager.canRequestPackageInstalls()) {
                                result.error("NO_PERMISSION", "User must allow 'Install unknown apps'", null)
                                return@setMethodCallHandler
                            }
                            val file = File(apkPath)
                            val uri = FileProvider.getUriForFile(this, "$packageName.fileProvider", file)
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

        // ---- Migration channel (NEW) ----
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MIGRATION_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isInstalled" -> {
                        val pkg = call.argument<String>("package")
                        if (pkg.isNullOrBlank()) { result.success(false); return@setMethodCallHandler }
                        result.success(isPackageInstalled(pkg))
                    }
                    "uninstall" -> {
                        val pkg = call.argument<String>("package")
                        if (pkg.isNullOrBlank()) { result.error("NO_PKG", "Missing package", null); return@setMethodCallHandler }
                        try {
                            val intent = Intent(Intent.ACTION_DELETE).apply {
                                data = Uri.parse("package:$pkg")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(null)
                        } catch (e: ActivityNotFoundException) {
                            result.error("UNINSTALL_ERROR", "Cannot launch uninstaller: ${e.localizedMessage}", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }
}
