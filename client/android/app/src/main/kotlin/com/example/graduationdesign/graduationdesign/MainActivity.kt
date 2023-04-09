package com.example.graduationdesign.graduationdesign

import android.content.pm.PackageManager
import com.example.graduationdesign.graduationdesign.platform.FileLoadChannel
import com.example.graduationdesign.graduationdesign.platform.PermissionChannel
import com.example.graduationdesign.graduationdesign.platform.PullStreamPlatformFactory
import com.example.graduationdesign.graduationdesign.platform.PushStreamPlatformFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var mRequestPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "pullStream", PullStreamPlatformFactory(messenger)
        )
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "pushStream", PushStreamPlatformFactory(messenger)
        )
        PermissionChannel(messenger, this) {
            mRequestPermissionResult = it
        }
        FileLoadChannel(messenger, this)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        mRequestPermissionResult = null
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ) {
        when (requestCode) {
            PermissionChannel.REQUEST_PERMISSIONS -> {
                if (grantResults.isNotEmpty() && !grantResults.contains(PackageManager.PERMISSION_DENIED)) {
                    mRequestPermissionResult?.success(true)
                } else {
                    mRequestPermissionResult?.success(false)
                }
                mRequestPermissionResult = null
            }
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
}
