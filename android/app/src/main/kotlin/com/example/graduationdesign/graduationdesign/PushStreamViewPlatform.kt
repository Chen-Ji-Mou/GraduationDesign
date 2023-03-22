package com.example.graduationdesign.graduationdesign

import android.content.Context
import android.view.View
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class PushStreamViewPlatform(context: Context, viewId: Int, creationParams: Map<String, Any>?) :
    PlatformView {
    private val view: PushStreamView

    override fun getView(): View = view

    override fun dispose() {}

    init {
        view = PushStreamView(context)
        view.setPushStreamPath(creationParams?.get(PlatformParamKeys.path).toString())
    }
}

class PushStreamViewPlatformFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String, Any>?
        return PushStreamViewPlatform(context, viewId, creationParams)
    }
}