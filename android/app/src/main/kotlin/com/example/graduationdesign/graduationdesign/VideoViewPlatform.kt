package com.example.graduationdesign.graduationdesign

import android.content.Context
import android.view.View
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class VideoViewPlatform(context: Context, viewId: Int, creationParams: Map<String, Any>?) :
    PlatformView {
    private val view: VideoView

    override fun getView(): View = view

    override fun dispose() {
        view.stop()
        view.release()
    }

    init {
        view = VideoView(context)
        view.setVideoPath(creationParams?.get(PlatformParamKeys.path).toString())
        view.setFillXY(creationParams?.get(PlatformParamKeys.fillXY).toString().toBoolean())
        view.start()
    }
}

class VideoViewPlatformFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String, Any>?
        return VideoViewPlatform(context, viewId, creationParams)
    }
}