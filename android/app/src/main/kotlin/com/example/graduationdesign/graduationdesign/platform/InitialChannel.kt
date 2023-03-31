package com.example.graduationdesign.graduationdesign.platform

import android.content.Context
import com.example.graduationdesign.graduationdesign.Utils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class InitialChannel(binaryMessenger: BinaryMessenger, context: Context) :
    MethodChannel.MethodCallHandler {

    private val mChannelName = "initial"
    private var mChannel: MethodChannel
    private var mContext: Context

    init {
        mChannel = MethodChannel(binaryMessenger, mChannelName)
        mChannel.setMethodCallHandler(this)
        mContext = context
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initial" -> initial(result)
            else -> result.notImplemented()
        }
    }

    private fun initial(result: MethodChannel.Result) {
        Utils.copyAssetsToSdcard(mContext, "lbpcascade_frontalface.xml")
        Utils.copyAssetsToSdcard(mContext, "seeta_fa_v1.1.bin")
        result.success(true)
    }
}