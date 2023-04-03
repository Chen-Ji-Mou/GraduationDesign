package com.example.graduationdesign.graduationdesign.view

import android.annotation.SuppressLint
import android.content.Context
import android.hardware.Camera
import android.media.CamcorderProfile
import android.media.MediaScannerConnection
import android.os.Environment
import android.util.Log
import android.util.Size
import android.view.SurfaceHolder
import android.widget.RelativeLayout
import com.example.graduationdesign.graduationdesign.Camera1ApiManagerProxy
import com.example.graduationdesign.graduationdesign.filter.BigEyeFilterRender
import com.example.graduationdesign.graduationdesign.filter.StickFilterRender
import com.example.graduationdesign.graduationdesign.track.FaceTrack
import com.pedro.encoder.input.gl.render.ManagerRender
import com.pedro.encoder.input.gl.render.filters.*
import com.pedro.encoder.input.video.CameraHelper
import com.pedro.encoder.input.video.CameraOpenException
import com.pedro.rtmp.utils.ConnectCheckerRtmp
import com.pedro.rtplibrary.rtmp.RtmpCamera1
import com.pedro.rtplibrary.view.AspectRatioMode
import com.pedro.rtplibrary.view.OpenGlView
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

class PushStreamView(context: Context) : RelativeLayout(context, null, 0), ConnectCheckerRtmp,
    SurfaceHolder.Callback, Camera1ApiManagerProxy.PreviewCallback {
    private val mContext: Context
    private var rtmpUrl: String? = null
    private var mSurfaceView: OpenGlView? = null
    private var mRtmpCamera1: RtmpCamera1? = null
    private var currentDateAndTime: String = ""
    private var mFaceTrack: FaceTrack? = null
    private var yuvBuffer: ByteArray? = null

    private val mRecordFolder: File
        get() {
            val storageDir: File =
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
            return File(storageDir.absolutePath + "/LiveRecord")
        }

    private val previewSize: Size
        get() {
            return if (CamcorderProfile.hasProfile(CamcorderProfile.QUALITY_1080P)) {
                Size(1920, 1080)
            } else if (CamcorderProfile.hasProfile(CamcorderProfile.QUALITY_720P)) {
                Size(1280, 720)
            } else {
                Size(640, 480)
            }
        }

    init {
        mContext = context
        createSurfaceView()
        initRtmpCamera1()
    }

    fun setRtmpUrl(url: String) {
        rtmpUrl = url
    }

    private fun createSurfaceView() {
        mSurfaceView = OpenGlView(mContext)
        mSurfaceView?.isKeepAspectRatio = true
        mSurfaceView?.setAspectRatioMode(AspectRatioMode.Fill)
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
        yuvBuffer = ByteArray(previewSize.width * previewSize.height * 3 / 2)

        val proxyField = RtmpCamera1::class.java.superclass.getDeclaredField("cameraManager")
        proxyField.isAccessible = true
        val proxyObj = proxyField.get(mRtmpCamera1) as Camera1ApiManagerProxy

        val cameraField = Camera1ApiManagerProxy::class.java.superclass.getDeclaredField("camera")
        cameraField.isAccessible = true
        val cameraObj = cameraField.get(proxyObj) as Camera

        cameraObj.addCallbackBuffer(yuvBuffer)
        cameraObj.setPreviewCallbackWithBuffer(proxyObj)
    }

    override fun onPreviewFrame(data: ByteArray, camera: Camera) {
        mFaceTrack?.detector(data)
        camera.addCallbackBuffer(yuvBuffer)
    }

    override fun onAuthErrorRtmp() {
        mRtmpCamera1?.stopStream()
        Log.e(TAG, "[onAuthErrorRtmp] Auth Error")
    }

    override fun onAuthSuccessRtmp() {
        Log.e(TAG, "[onAuthSuccessRtmp] Auth Success")
    }

    override fun onConnectionFailedRtmp(reason: String) {
        Log.e(TAG, "[onConnectionFailedRtmp] Connection failed. Reason: $reason")
        mRtmpCamera1?.stopStream()
    }

    override fun onConnectionStartedRtmp(rtmpUrl: String) {}

    override fun onConnectionSuccessRtmp() {
        Log.d(TAG, "[onConnectionSuccessRtmp] Connection Success $rtmpUrl")
    }

    override fun onDisconnectRtmp() {
        Log.d(TAG, "[onDisconnectRtmp] Disconnected $rtmpUrl")
    }

    override fun onNewBitrateRtmp(bitrate: Long) {}

    @SuppressLint("SdCardPath")
    private fun start() {
        mRtmpCamera1?.startPreview(CameraHelper.Facing.FRONT, previewSize.width, previewSize.height)
        hookCameraPreviewListen()
        mFaceTrack = FaceTrack(
            "/sdcard/Android/data/${mContext.packageName}/cache/lbpcascade_frontalface.xml",
            "/sdcard/Android/data/${mContext.packageName}/cache/seeta_fa_v1.1.bin",
            mRtmpCamera1?.cameraFacing,
            previewSize.width,
            previewSize.height
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
    }

    fun pause() {
        if (mRtmpCamera1?.isStreaming != true) {
            return
        }
        mRtmpCamera1?.stopStream()
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
        mSurfaceView?.holder?.removeCallback(this)
        mFaceTrack?.stopTrack()
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

    fun addStickFilter() {
        mRtmpCamera1?.glInterface?.setFilter(StickFilterRender(mContext, mFaceTrack))
    }

    private fun updateGallery(path: String) = MediaScannerConnection.scanFile(
        mContext, arrayOf(path), arrayOf("video/mp4"), null
    )

    companion object {
        const val TAG: String = "PushStreamView"
    }
}