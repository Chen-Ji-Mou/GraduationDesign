package com.example.graduationdesign.graduationdesign

import android.content.pm.PackageManager
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var mRequestPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "videoView", VideoViewPlatformFactory()
        )
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "pushStreamView", PushStreamViewPlatformFactory()
        )
        PermissionChannel(flutterEngine.dartExecutor.binaryMessenger, this) {
            mRequestPermissionResult = it
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ) {
        when (requestCode) {
            PermissionChannel.REQUEST_PUSH_STREAM_PERMISSIONS -> {
                if (grantResults.isNotEmpty()
                    && !grantResults.contains(PackageManager.PERMISSION_DENIED)
                ) {
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
