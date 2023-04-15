package com.example.graduationdesign.graduationdesign.alipay

import android.app.Activity
import android.text.TextUtils
import android.util.Log
import com.alipay.sdk.app.PayTask
import com.example.graduationdesign.graduationdesign.R
import com.example.graduationdesign.graduationdesign.Utils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AlipayChannel(binaryMessenger: BinaryMessenger, activity: Activity) :
    MethodChannel.MethodCallHandler {

    private val mChannelName = "alipay"
    private var mChannel: MethodChannel
    private var mActivity: Activity

    init {
        mChannel = MethodChannel(binaryMessenger, mChannelName)
        mChannel.setMethodCallHandler(this)
        mActivity = activity
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "payV2" -> payV2(call, result)
            else -> result.notImplemented()
        }
    }

    /**
     * 支付宝支付业务
     */
    private fun payV2(call: MethodCall, methodResult: MethodChannel.Result) {
        /*
		 * 这里只是为了方便直接向商户展示支付宝的整个支付流程；所以Demo中加签过程直接放在客户端完成；
		 * 真实App里，privateKey等数据严禁放在客户端，加签过程务必要放在服务端完成；
		 * 防止商户私密数据泄露，造成不必要的资金损失，及面临各种安全风险；
		 *
		 * orderInfo 的获取必须来自服务端；
		 */
        val params: Map<String, String> = OrderInfoUtil2_0.buildOrderParamMap(
            mActivity.getString(R.string.APPID), true, call.arguments as Int
        )
        val orderParam: String = OrderInfoUtil2_0.buildOrderParam(params)

        val privateKey: String = mActivity.getString(R.string.RSA2_PRIVATE)
        val sign: String = OrderInfoUtil2_0.getSign(params, privateKey, true)
        val orderInfo = "$orderParam&$sign"

        // 必须异步调用
        Thread {
            val alipay = PayTask(mActivity)
            val response = alipay.payV2(orderInfo, true)
            Log.d("AlipayChannel", "[payV2] 支付返回结果 $response")
            val payResult = PayResult(response)
            val resultStatus = payResult.resultStatus
            // 判断resultStatus 为9000则代表支付成功
            if (TextUtils.equals(resultStatus, "9000")) {
                Log.d("AlipayChannel", "[payV2] 支付成功")
                methodResult.success(true)
            } else {
                Log.d("AlipayChannel", "[payV2] 支付失败")
                methodResult.success(false)
            }
        }.start()
    }
}