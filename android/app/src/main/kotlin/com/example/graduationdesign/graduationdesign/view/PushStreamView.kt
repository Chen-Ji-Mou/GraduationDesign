package com.example.graduationdesign.graduationdesign.view

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.hardware.Camera
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.util.Log
import android.view.SurfaceHolder
import android.widget.RelativeLayout
import com.example.graduationdesign.graduationdesign.BigEyeFilterRender
import com.example.graduationdesign.graduationdesign.Camera1ApiManagerProxy
import com.example.graduationdesign.graduationdesign.Utils
import com.example.graduationdesign.graduationdesign.track.FaceTrack
import com.pedro.encoder.input.gl.render.ManagerRender
import com.pedro.encoder.input.gl.render.filters.*
import com.pedro.encoder.input.video.CameraOpenException
import com.pedro.rtmp.utils.ConnectCheckerRtmp
import com.pedro.rtplibrary.rtmp.RtmpCamera1
import com.pedro.rtplibrary.view.AspectRatioMode
import com.pedro.rtplibrary.view.OpenGlView
import master.flame.danmaku.controller.DrawHandler
import master.flame.danmaku.danmaku.model.BaseDanmaku
import master.flame.danmaku.danmaku.model.DanmakuTimer
import master.flame.danmaku.danmaku.model.IDanmakus
import master.flame.danmaku.danmaku.model.android.DanmakuContext
import master.flame.danmaku.danmaku.model.android.Danmakus
import master.flame.danmaku.danmaku.parser.BaseDanmakuParser
import master.flame.danmaku.ui.widget.DanmakuView
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

class PushStreamView(context: Context) : RelativeLayout(context, null, 0), ConnectCheckerRtmp,
    SurfaceHolder.Callback, DrawHandler.Callback, Camera1ApiManagerProxy.PreviewCallback {
    private val mContext: Context
    private var rtmpUrl: String? = null
    private var mSurfaceView: OpenGlView? = null
    private var mRtmpCamera1: RtmpCamera1? = null
    private var currentDateAndTime: String = ""
    private var mBarrageView: DanmakuView? = null
    private var mBarrageContext: DanmakuContext? = null
    private var barrageOpen: Boolean = false
    private var mFaceTrack: FaceTrack? = null

    private val mRecordFolder: File
        get() {
            val storageDir: File =
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
            return File(storageDir.absolutePath + "/LiveRecord")
        }

    private val mBarrageParser = object : BaseDanmakuParser() {
        override fun parse(): IDanmakus {
            return Danmakus()
        }
    }

    init {
        mContext = context
        createSurfaceView()
        initRtmpCamera1()
        createBarrageView()
    }

    fun setRtmpUrl(url: String) {
        rtmpUrl = url
    }

    private fun createSurfaceView() {
        mSurfaceView = OpenGlView(mContext)
        mSurfaceView?.isKeepAspectRatio = true
        mSurfaceView?.setAspectRatioMode(AspectRatioMode.Adjust)
        mSurfaceView?.enableAA(true)
        ManagerRender.numFilters = 1
        mSurfaceView?.holder?.addCallback(this)

        val surfaceParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        surfaceParams.addRule(CENTER_IN_PARENT)
        mSurfaceView?.layoutParams = surfaceParams
        addView(mSurfaceView)
    }

    override fun surfaceCreated(surfaceHolder: SurfaceHolder) {}

    override fun surfaceChanged(
        surfaceHolder: SurfaceHolder, format: Int, width: Int, height: Int
    ) = start()

    override fun surfaceDestroyed(surfaceHolder: SurfaceHolder) = release()

    private fun initRtmpCamera1() {
        mRtmpCamera1 = RtmpCamera1(mSurfaceView, this)
        mRtmpCamera1?.setReTries(3)
        hookCameraManager()
    }

    private fun hookCameraManager() {
        val field = RtmpCamera1::class.java.superclass.getDeclaredField("cameraManager")
        field.isAccessible = true
        val proxy = Camera1ApiManagerProxy(
            mSurfaceView?.surfaceTexture, mSurfaceView?.context
        )
        proxy.addPreviewCallback(this)
        field.set(mRtmpCamera1, proxy)
    }

    private fun hookCameraPreviewListen() {
        val proxyField = RtmpCamera1::class.java.superclass.getDeclaredField("cameraManager")
        proxyField.isAccessible = true
        val proxyObj = proxyField.get(mRtmpCamera1) as Camera1ApiManagerProxy

        val cameraField = Camera1ApiManagerProxy::class.java.superclass.getDeclaredField("camera")
        cameraField.isAccessible = true
        val cameraObj = cameraField.get(proxyObj) as Camera

        cameraObj.setPreviewCallback(proxyObj)
    }

    override fun onPreviewFrame(data: ByteArray, camera: Camera) {
        mFaceTrack?.detector(data)
    }

    override fun onAuthErrorRtmp() {
        mRtmpCamera1?.stopStream()
        Log.e(TAG, "[onAuthErrorRtmp] Auth Error")
    }

    override fun onAuthSuccessRtmp() {
        Log.e(TAG, "[onAuthSuccessRtmp] Auth Success")
    }

    override fun onConnectionFailedRtmp(reason: String) {
        if (mRtmpCamera1?.reTry(5000, reason, null) == true) {
            Log.d(TAG, "[onConnectionFailedRtmp] Retrying...")
        } else {
            Log.e(TAG, "[onConnectionFailedRtmp] Connection failed. Reason: $reason")
            mRtmpCamera1?.stopStream()
        }
    }

    override fun onConnectionStartedRtmp(rtmpUrl: String) {}

    override fun onConnectionSuccessRtmp() {
        Log.d(TAG, "[onConnectionSuccessRtmp] Connection Success $rtmpUrl")
    }

    override fun onDisconnectRtmp() {
        Log.d(TAG, "[onDisconnectRtmp] Disconnected $rtmpUrl")
    }

    override fun onNewBitrateRtmp(bitrate: Long) {}

    private fun createBarrageView() {
        mBarrageView = DanmakuView(mContext)
        mBarrageView?.enableDanmakuDrawingCache(true)
        mBarrageView?.setCallback(this)
        mBarrageContext = DanmakuContext.create()
        mBarrageView?.prepare(mBarrageParser, mBarrageContext)

        val layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        mBarrageView?.layoutParams = layoutParams
        addView(mBarrageView)
    }

    override fun prepared() {
        barrageOpen = true
        mBarrageView?.start()
        generateSomeBarrage()
    }

    override fun updateTimer(timer: DanmakuTimer?) {}

    override fun danmakuShown(danmaku: BaseDanmaku?) {}

    override fun drawingFinished() {}

    @SuppressLint("SdCardPath")
    private fun start() {
        mRtmpCamera1?.startPreview()
        hookCameraPreviewListen()
        mFaceTrack = FaceTrack(
            "/sdcard/Download/lbpcascade_frontalface.xml",
            "/sdcard/Download/seeta_fa_v1.1.bin",
            mRtmpCamera1?.cameraFacing,
            width,
            height
        )
        mFaceTrack?.startTrack()
    }

    fun resume() {
        if (mRtmpCamera1?.isStreaming == true) {
            return
        }
        if (mRtmpCamera1?.isRecording == true || mRtmpCamera1?.prepareAudio() == true && mRtmpCamera1?.prepareVideo() == true) {
            mRtmpCamera1?.startStream(rtmpUrl)
        } else {
            Log.w(TAG, "[resume] Error preparing stream, This device cant do it")
        }
        if (mBarrageView?.isPrepared == true && mBarrageView?.isPaused == true) {
            mBarrageView?.resume()
        }
    }

    fun pause() {
        if (mRtmpCamera1?.isStreaming != true) {
            return
        }
        mRtmpCamera1?.stopStream()
        if (mBarrageView?.isPrepared == true && mBarrageView?.isPaused == false) {
            mBarrageView?.pause()
        }
    }

    fun release() {
        if (mRtmpCamera1?.isRecording == true) {
            mRtmpCamera1?.stopRecord()
            updateGallery("${mRecordFolder.absolutePath}/$currentDateAndTime.mp4")
            Log.d(
                TAG, "[release] file $currentDateAndTime.mp4 saved in ${mRecordFolder.absolutePath}"
            )
            currentDateAndTime = ""
        }
        if (mRtmpCamera1?.isStreaming == true) {
            mRtmpCamera1?.stopStream()
        }
        mRtmpCamera1?.stopPreview()
        mSurfaceView = null
        mRtmpCamera1 = null

        mBarrageView?.release()
        mBarrageView?.setCallback(null)
        barrageOpen = false
        mBarrageContext = null
        mBarrageView = null

        mFaceTrack?.stopTrack()
        mFaceTrack = null
    }

    fun switchCamera() {
        try {
            mRtmpCamera1?.switchCamera()
        } catch (e: CameraOpenException) {
            Log.e(TAG, "[switchCamera] Exception: ${e.message}")
        }
    }

    fun startRecord() {
        if (mRtmpCamera1?.isRecording == true) {
            return
        }
        try {
            if (!mRecordFolder.exists()) {
                mRecordFolder.mkdir()
            }
            val sdf = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault())
            currentDateAndTime = sdf.format(Date())
            if (mRtmpCamera1?.isStreaming != true) {
                if (mRtmpCamera1?.prepareAudio() == true && mRtmpCamera1?.prepareVideo() == true) {
                    mRtmpCamera1?.startRecord(
                        "${mRecordFolder.absolutePath}/$currentDateAndTime.mp4"
                    )
                    Log.d(TAG, "[startRecord] Recording...")
                } else {
                    Log.w(TAG, "[startRecord] Error preparing stream, This device cant do it")
                }
            } else {
                mRtmpCamera1?.startRecord(
                    "${mRecordFolder.absolutePath}/$currentDateAndTime.mp4"
                )
                Log.d(TAG, "[startRecord] Recording...")
            }
        } catch (e: IOException) {
            mRtmpCamera1?.stopRecord()
            updateGallery(
                "${mRecordFolder.absolutePath}/$currentDateAndTime.mp4"
            )
            Log.e(TAG, "[startRecord] Exception: ${e.message}")
        }
    }

    fun stopRecord() {
        if (mRtmpCamera1?.isRecording != true) {
            return
        }
        mRtmpCamera1?.stopRecord()
        updateGallery(
            "${mRecordFolder.absolutePath}/$currentDateAndTime.mp4"
        )
        Log.d(
            TAG, "[stopRecord] file $currentDateAndTime.mp4 saved in ${mRecordFolder.absolutePath}"
        )
    }

    /**
     * 向弹幕View中添加一条弹幕
     * @param content
     * 弹幕的具体内容
     */
    fun addBarrage(content: String, withBorder: Boolean) {
        val barrage = mBarrageContext?.mDanmakuFactory?.createDanmaku(BaseDanmaku.TYPE_SCROLL_RL)
        barrage?.text = content
        barrage?.padding = 5
        barrage?.textSize = Utils.sp2px(mContext, 20)
        barrage?.textColor = Color.WHITE
        barrage?.time = mBarrageView?.currentTime ?: Calendar.getInstance().timeInMillis
        if (withBorder) {
            barrage?.borderColor = Color.GREEN
        }
        mBarrageView?.addDanmaku(barrage)
    }

    /**
     * 随机生成一些弹幕内容以供测试
     */
    private fun generateSomeBarrage() {
        Thread {
            while (barrageOpen) {
                val time: Int = Random().nextInt(300)
                val content = "" + time + time
                addBarrage(content, false)
                try {
                    Thread.sleep(time.toLong())
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                }
            }
        }.start()
    }

    fun showBarrage() {
        barrageOpen = true
        mBarrageView?.show()
    }

    fun hideBarrage() {
        barrageOpen = false
        mBarrageView?.hide()
    }

    fun cancelFilter() {
        mRtmpCamera1?.glInterface?.clearFilters()
    }

    fun addVintageTVFilter() {
        mRtmpCamera1?.glInterface?.setFilter(AnalogTVFilterRender())
    }

    fun addWaveFilter() {
        mRtmpCamera1?.glInterface?.setFilter(BasicDeformationFilterRender())
    }

    fun addBeautyFilter() {
        mRtmpCamera1?.glInterface?.setFilter(BeautyFilterRender())
    }

    fun addCartoonFilter() {
        mRtmpCamera1?.glInterface?.setFilter(CartoonFilterRender())
    }

    fun addProfoundFilter() {
        mRtmpCamera1?.glInterface?.setFilter(EarlyBirdFilterRender())
    }

    fun addSnowFilter() {
        mRtmpCamera1?.glInterface?.setFilter(SnowFilterRender())
    }

    fun addOldPhotoFilter() {
        mRtmpCamera1?.glInterface?.setFilter(SepiaFilterRender())
    }

    fun addLamoishFilter() {
        mRtmpCamera1?.glInterface?.setFilter(LamoishFilterRender())
    }

    fun addMoneyFilter() {
        mRtmpCamera1?.glInterface?.setFilter(MoneyFilterRender())
    }

    fun addWaterRippleFilter() {
        mRtmpCamera1?.glInterface?.setFilter(RippleFilterRender())
    }

    fun addBigEyeFilter() {
        mRtmpCamera1?.glInterface?.setFilter(BigEyeFilterRender(mFaceTrack))
    }

    private fun updateGallery(path: String) = MediaScannerConnection.scanFile(
        mContext, arrayOf(path), arrayOf("video/mp4"), null
    )

    companion object {
        const val TAG: String = "PushStreamView"
    }
}