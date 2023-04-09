package com.example.graduationdesign.graduationdesign.platform

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PermissionChannel(
    binaryMessenger: BinaryMessenger, activity: Activity, callback: (MethodChannel.Result) -> Unit
) : MethodChannel.MethodCallHandler {
    private val mChannelName = "permission"
    private var mChannel: MethodChannel
    private var mActivity: Activity
    private var mPendingPermissionResponse: (MethodChannel.Result) -> Unit

    private val permissions = arrayOf(
        Manifest.permission.RECORD_AUDIO,
        Manifest.permission.CAMERA,
        Manifest.permission.WRITE_EXTERNAL_STORAGE,
        Manifest.permission.READ_EXTERNAL_STORAGE
    )

    @RequiresApi(api = Build.VERSION_CODES.R)
    private val permissions30 = arrayOf(
        Manifest.permission.RECORD_AUDIO,
        Manifest.permission.CAMERA,
        Manifest.permission.WRITE_EXTERNAL_STORAGE,
        Manifest.permission.READ_EXTERNAL_STORAGE,
        Manifest.permission.MANAGE_EXTERNAL_STORAGE
    )

    companion object {
        const val REQUEST_PERMISSIONS = 0
    }

    init {
        mChannel = MethodChannel(binaryMessenger, mChannelName)
        mChannel.setMethodCallHandler(this)
        mActivity = activity
        mPendingPermissionResponse = callback
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestPermission" -> {
                requestPermission(result)
                mPendingPermissionResponse(result)
            }
            else -> result.notImplemented()
        }
    }


    private fun requestPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            if (!hasPermission(mActivity)) {
                ActivityCompat.requestPermissions(
                    mActivity, permissions30, REQUEST_PERMISSIONS
                )
            } else {
                result.success(true)
            }
        } else {
            if (!hasPermission(mActivity)) {
                ActivityCompat.requestPermissions(
                    mActivity, permissions, REQUEST_PERMISSIONS
                )
            } else {
                result.success(true)
            }
        }
    }

    private fun hasPermission(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            hasPermission(context, permissions30)
        } else {
            hasPermission(context, permissions)
        }
    }

    private fun hasPermission(context: Context, permissions: Array<String>): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            for (permission in permissions) {
                if (ActivityCompat.checkSelfPermission(
                        context, permission
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    return false
                }
            }
        }
        return true
    }
}