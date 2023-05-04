package com.example.graduationdesign.graduationdesign.platform

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import com.example.graduationdesign.graduationdesign.view.FilterType
import com.example.graduationdesign.graduationdesign.view.PushStreamView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class PushStreamPlatform(context: Context, messenger: BinaryMessenger) : PlatformView,
    MethodChannel.MethodCallHandler {

    private var channel: MethodChannel?
    private var view: PushStreamView?
    private var handler: Handler? = Handler(Looper.getMainLooper())

    init {
        channel =
            MethodChannel(messenger, "pushStreamChannel").also { it.setMethodCallHandler(this) }
        view = PushStreamView(context) {
            handler?.post {
                channel?.invokeMethod("returnCameraSnapshotPath", it)
            }
        }
    }

    override fun getView(): View? = view

    override fun dispose() {
        channel = null
        view?.release()
        view = null
        handler = null
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
            "clearFilter" -> clearFilter(result)
            "addVintageTVFilter" -> addVintageTVFilter(result)
            "addWaveFilter" -> addWaveFilter(result)
            "addBeautyFilter" -> addBeautyFilter(result)
            "removeBeautyFilter" -> removeBeautyFilter(result)
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
        val fileName: String? = view?.stopRecord()
        result.success(fileName)
    }

    private fun clearFilter(result: MethodChannel.Result) {
        view?.clearOtherFilter()
        result.success(true)
    }

    private fun addVintageTVFilter(result: MethodChannel.Result) {
        view?.addOtherFilter(FilterType.vintageTV)
        result.success(true)
    }

    private fun addWaveFilter(result: MethodChannel.Result) {
        view?.addOtherFilter(FilterType.wave)
        result.success(true)
    }

    private fun addBeautyFilter(result: MethodChannel.Result) {
        view?.addBeautyFilter()
        result.success(true)
    }

    private fun removeBeautyFilter(result: MethodChannel.Result) {
        view?.removeBeautyFilter()
        result.success(true)
    }

    private fun addCartoonFilter(result: MethodChannel.Result) {
        view?.addOtherFilter(FilterType.cartoon)
        result.success(true)
    }

    private fun addLamoishFilter(result: MethodChannel.Result) {
        view?.addOtherFilter(FilterType.lamoish)
        result.success(true)
    }

    private fun addMoneyFilter(result: MethodChannel.Result) {
        view?.addOtherFilter(FilterType.money)
        result.success(true)
    }

    private fun addOldPhotoFilter(result: MethodChannel.Result) {
        view?.addOtherFilter(FilterType.oldPhoto)
        result.success(true)
    }

    private fun addProfoundFilter(result: MethodChannel.Result) {
        view?.addOtherFilter(FilterType.profound)
        result.success(true)
    }

    private fun addSnowFilter(result: MethodChannel.Result) {
        view?.addOtherFilter(FilterType.snow)
        result.success(true)
    }

    private fun addWaterRippleFilter(result: MethodChannel.Result) {
        view?.addOtherFilter(FilterType.waterRipple)
        result.success(true)
    }

    private fun addBigEyeFilter(result: MethodChannel.Result) {
        view?.addOtherFilter(FilterType.bigEye)
        result.success(true)
    }

    private fun addStickFilter(result: MethodChannel.Result) {
        view?.addOtherFilter(FilterType.stick)
        result.success(true)
    }
}

class PushStreamPlatformFactory(private val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return PushStreamPlatform(context, messenger)
    }
}