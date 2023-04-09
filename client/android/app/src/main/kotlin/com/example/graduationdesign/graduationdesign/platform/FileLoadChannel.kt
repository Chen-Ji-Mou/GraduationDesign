package com.example.graduationdesign.graduationdesign.platform

import android.content.Context
import android.util.Log
import com.example.graduationdesign.graduationdesign.Utils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Future

class FileLoadChannel(binaryMessenger: BinaryMessenger, context: Context) :
    MethodChannel.MethodCallHandler {

    private val mChannelName = "fileLoad"
    private var mChannel: MethodChannel
    private var mContext: Context

    init {
        mChannel = MethodChannel(binaryMessenger, mChannelName)
        mChannel.setMethodCallHandler(this)
        mContext = context
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadFile" -> loadFile(result)
            else -> result.notImplemented()
        }
    }

    private fun loadFile(methodResult: MethodChannel.Result) {
        try {
            val result1: Future<Boolean> =
                Utils.copyAssetsToSdcard(mContext, "lbpcascade_frontalface.xml")
            val result2: Future<Boolean> = Utils.copyAssetsToSdcard(mContext, "seeta_fa_v1.1.bin")
            while (!(result1.isDone && result2.isDone)) {
                Log.d("FileLoadChannel", "[loadFile] loading")
                Thread.sleep(200)
            }
            methodResult.success(result1.get() && result2.get())
        } catch (e: java.lang.Exception) {
            Log.e("FileLoadChannel", "[loadFile] $e")
            methodResult.success(false)
        }
    }
}