package com.example.graduationdesign.graduationdesign.platform

import android.content.Context
import android.view.View
import com.example.graduationdesign.graduationdesign.view.PushStreamView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class PushStreamPlatform(context: Context, messenger: BinaryMessenger) : PlatformView,
    MethodChannel.MethodCallHandler {
    private var view: PushStreamView?

    init {
        view = PushStreamView(context)
        MethodChannel(messenger, "pushStreamChannel").setMethodCallHandler(this)
    }

    override fun getView(): View? = view

    override fun dispose() {
        view?.release()
        view = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setRtmpUrl" -> setRtmpUrl(call, result)
            "resume" -> resume(result)
            "pause" -> pause(result)
            "release" -> release(result)
            "switchCamera" -> switchCamera(result)
            "startRecord" -> startRecord(result)
            "stopRecord" -> stopRecord(result)
            "cancelFilter" -> cancelFilter(result)
            "addVintageTVFilter" -> addVintageTVFilter(result)
            "addWaveFilter" -> addWaveFilter(result)
            "addBeautyFilter" -> addBeautyFilter(result)
            "addCartoonFilter" -> addCartoonFilter(result)
            "addProfoundFilter" -> addProfoundFilter(result)
            "addSnowFilter" -> addSnowFilter(result)
            "addOldPhotoFilter" -> addOldPhotoFilter(result)
            "addLamoishFilter" -> addLamoishFilter(result)
            "addMoneyFilter" -> addMoneyFilter(result)
            "addWaterRippleFilter" -> addWaterRippleFilter(result)
            "addBigEyeFilter" -> addBigEyeFilter(result)
            "addStickFilter" -> addStickFilter(result)
            else -> result.notImplemented()
        }
    }

    private fun setRtmpUrl(call: MethodCall, result: MethodChannel.Result) {
        view?.setRtmpUrl(call.arguments as String)
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

    private fun switchCamera(result: MethodChannel.Result) {
        view?.switchCamera()
        result.success(true)
    }

    private fun startRecord(result: MethodChannel.Result) {
        view?.startRecord()
        result.success(true)
    }

    private fun stopRecord(result: MethodChannel.Result) {
        view?.stopRecord()
        result.success(true)
    }

    private fun cancelFilter(result: MethodChannel.Result) {
        view?.cancelFilter()
        result.success(true)
    }

    private fun addVintageTVFilter(result: MethodChannel.Result) {
        view?.addVintageTVFilter()
        result.success(true)
    }

    private fun addWaveFilter(result: MethodChannel.Result) {
        view?.addWaveFilter()
        result.success(true)
    }

    private fun addBeautyFilter(result: MethodChannel.Result) {
        view?.addBeautyFilter()
        result.success(true)
    }

    private fun addCartoonFilter(result: MethodChannel.Result) {
        view?.addCartoonFilter()
        result.success(true)
    }

    private fun addLamoishFilter(result: MethodChannel.Result) {
        view?.addLamoishFilter()
        result.success(true)
    }

    private fun addMoneyFilter(result: MethodChannel.Result) {
        view?.addMoneyFilter()
        result.success(true)
    }

    private fun addOldPhotoFilter(result: MethodChannel.Result) {
        view?.addOldPhotoFilter()
        result.success(true)
    }

    private fun addProfoundFilter(result: MethodChannel.Result) {
        view?.addProfoundFilter()
        result.success(true)
    }

    private fun addSnowFilter(result: MethodChannel.Result) {
        view?.addSnowFilter()
        result.success(true)
    }

    private fun addWaterRippleFilter(result: MethodChannel.Result) {
        view?.addWaterRippleFilter()
        result.success(true)
    }

    private fun addBigEyeFilter(result: MethodChannel.Result) {
        view?.addBigEyeFilter()
        result.success(true)
    }

    private fun addStickFilter(result: MethodChannel.Result) {
        view?.addStickFilter()
        result.success(true)
    }
}

class PushStreamPlatformFactory(private val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return PushStreamPlatform(context, messenger)
    }
}