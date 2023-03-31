package com.example.graduationdesign.graduationdesign.platform

import android.content.Context
import android.view.View
import com.example.graduationdesign.graduationdesign.view.PullStreamView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class PullStreamPlatform(context: Context, messenger: BinaryMessenger) : PlatformView,
    MethodChannel.MethodCallHandler {
    private var view: PullStreamView?

    init {
        view = PullStreamView(context)
        MethodChannel(messenger, "pullStreamChannel").setMethodCallHandler(this)
    }

    override fun getView(): View? = view

    override fun dispose() {
        view?.release()
        view = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setRtmpUrl" -> setRtmpUrl(call, result)
            "setFillXY" -> setFillXY(call, result)
            "resume" -> resume(result)
            "pause" -> pause(result)
            "release" -> release(result)
            "addBarrage" -> addBarrage(call, result)
            "showBarrage" -> showBarrage(result)
            "hideBarrage" -> hideBarrage(result)
            else -> result.notImplemented()
        }
    }

    private fun setRtmpUrl(call: MethodCall, result: MethodChannel.Result) {
        view?.setRtmpUrl(call.arguments as String)
        result.success(true)
    }

    private fun setFillXY(call: MethodCall, result: MethodChannel.Result) {
        view?.setFillXY(call.arguments as Boolean)
        result.success(true)
    }

    private fun resume(result: MethodChannel.Result) {
        view?.resume()
        result.success(true)
    }

    private fun pause(result: MethodChannel.Result) {
        view?.pause()
        result.success(true)
    }

    private fun release(result: MethodChannel.Result) {
        view?.release()
        result.success(true)
    }

    private fun addBarrage(call: MethodCall, result: MethodChannel.Result) {
        val content = call.argument<String>("content")
        val withBorder = call.argument<Boolean>("withBorder")
        view?.addBarrage(content ?: "", withBorder ?: false)
        result.success(true)
    }

    private fun showBarrage(result: MethodChannel.Result) {
        view?.showBarrage()
        result.success(true)
    }

    private fun hideBarrage(result: MethodChannel.Result) {
        view?.hideBarrage()
        result.success(true)
    }
}

class PullStreamPlatformFactory(private val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView =
        PullStreamPlatform(context, messenger)
}