package com.example.graduationdesign.graduationdesign

import android.content.pm.PackageManager
import android.util.Log
import com.alipay.sdk.app.EnvUtils
import com.example.graduationdesign.graduationdesign.alipay.AlipayChannel
import com.example.graduationdesign.graduationdesign.platform.FileLoadChannel
import com.example.graduationdesign.graduationdesign.platform.PermissionChannel
import com.example.graduationdesign.graduationdesign.platform.PullStreamPlatformFactory
import com.example.graduationdesign.graduationdesign.platform.PushStreamPlatformFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private var mRequestPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // 设置支付宝沙盒支付环境
        EnvUtils.setEnv(EnvUtils.EnvEnum.SANDBOX)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
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
        AlipayChannel(messenger, this)
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
                    Log.d("PermissionChannel", "[requestPermission] 权限申请成功")
                    mRequestPermissionResult?.success(true)
                } else {
                    Log.d("PermissionChannel", "[requestPermission] 权限申请失败")
                    mRequestPermissionResult?.success(false)
                }
                mRequestPermissionResult = null
            }
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onDestroy() {
        Utils.normalThreadPool.shutdown()
        Utils.scheduleThreadPool.shutdown()
        super.onDestroy()
    }
}
