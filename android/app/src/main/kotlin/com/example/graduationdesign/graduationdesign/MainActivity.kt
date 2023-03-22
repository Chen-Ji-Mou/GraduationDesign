package com.example.graduationdesign.graduationdesign

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "videoView", VideoViewPlatformFactory()
        )
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "pushStreamView",
            PushStreamViewPlatformFactory()
        )
    }
}
