package com.example.graduationdesign.graduationdesign

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

    private val mPushStreamPermissions = arrayOf(
        Manifest.permission.RECORD_AUDIO,
        Manifest.permission.CAMERA,
        Manifest.permission.WRITE_EXTERNAL_STORAGE
    )

    @RequiresApi(api = Build.VERSION_CODES.TIRAMISU)
    private val mPushStreamPermissions13 = arrayOf(
        Manifest.permission.RECORD_AUDIO,
        Manifest.permission.CAMERA,
        Manifest.permission.POST_NOTIFICATIONS
    )

    companion object {
        const val REQUEST_PUSH_STREAM_PERMISSIONS = 0
    }

    init {
        mChannel = MethodChannel(binaryMessenger, mChannelName)
        mChannel.setMethodCallHandler(this)
        mActivity = activity
        mPendingPermissionResponse = callback
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestPushStreamPermission" -> {
                requestPushStreamPermission(result)
                mPendingPermissionResponse(result)
            }
            else -> result.notImplemented()
        }
    }


    private fun requestPushStreamPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (!hasPushStreamPermission(mActivity)) {
                ActivityCompat.requestPermissions(
                    mActivity, mPushStreamPermissions13, REQUEST_PUSH_STREAM_PERMISSIONS
                )
            } else {
                result.success(true)
            }
        } else {
            if (!hasPushStreamPermission(mActivity)) {
                ActivityCompat.requestPermissions(
                    mActivity, mPushStreamPermissions, REQUEST_PUSH_STREAM_PERMISSIONS
                )
            } else {
                result.success(true)
            }
        }
    }

    private fun hasPushStreamPermission(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            hasPushStreamPermission(context, mPushStreamPermissions13)
        } else {
            hasPushStreamPermission(context, mPushStreamPermissions)
        }
    }

    private fun hasPushStreamPermission(context: Context, permissions: Array<String>): Boolean {
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