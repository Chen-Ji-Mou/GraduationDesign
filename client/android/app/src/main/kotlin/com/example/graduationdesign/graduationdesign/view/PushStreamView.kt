package com.example.graduationdesign.graduationdesign.view

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import android.hardware.Camera
import android.media.CamcorderProfile
import android.media.MediaScannerConnection
import android.os.Environment
import android.util.Log
import android.util.Size
import android.view.SurfaceHolder
import android.widget.RelativeLayout
import com.example.graduationdesign.graduationdesign.Camera1ApiManagerProxy
import com.example.graduationdesign.graduationdesign.Utils
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
import java.io.BufferedOutputStream
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.Callable
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.TimeUnit

class PushStreamView(context: Context, callback: (filePath: String) -> Unit) :
    RelativeLayout(context), ConnectCheckerRtmp, SurfaceHolder.Callback,
    Camera1ApiManagerProxy.PreviewCallback {
    private val mContext: Context
    private val mCallback: (filePath: String) -> Unit

    private var rtmpUrl: String? = null
    private var mSurfaceView: OpenGlView? = null
    private var mRtmpCamera1: RtmpCamera1? = null
    private var currentDateAndTime: String = ""
    private var mFaceTrack: FaceTrack? = null
    private var yuvBuffer: ByteArray? = null
    private var mScheduleTask: ScheduledFuture<Unit>? = null
    private var mPreviewImagePath: String = ""
    private var previewBuffer: ByteArray? = null
    private var beautyFilterIndex: Int = -1
    private var otherFilterIndex: Int = -1

    private val mRecordFolder: File
        get() {
            val storageDir: File =
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
            return File(storageDir.absolutePath)
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
        mCallback = callback
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
        ManagerRender.numFilters = FILTER_MAX_NUM
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
        previewBuffer = data
        camera.addCallbackBuffer(yuvBuffer)
    }

    private fun generatePreviewImage(data: ByteArray?) {
        if (data == null) {
            Log.e(TAG, "[generatePreviewImage] 相机预览数据为空")
            return
        }
        try {
            val dataAfterRotate =
                Utils.rotateNV21Degree270(data, previewSize.width, previewSize.height)
            val originalData =
                Utils.reverseNV21(dataAfterRotate, previewSize.height, previewSize.width)
            val yuvImage = YuvImage(
                originalData, ImageFormat.NV21, previewSize.height, previewSize.width, null
            )
            val imageOutputStream = ByteArrayOutputStream()
            yuvImage.compressToJpeg(
                Rect(0, 0, previewSize.height, previewSize.width), 80, imageOutputStream
            )
            val jpegData = imageOutputStream.toByteArray()
            mPreviewImagePath =
                "${mContext.externalCacheDir?.absolutePath}/camera_snapshot_${System.currentTimeMillis()}.jpg"
            val file = File(mPreviewImagePath)
            val fileOutputStream = BufferedOutputStream(FileOutputStream(file))
            fileOutputStream.write(jpegData, 0, jpegData.size)
            fileOutputStream.flush()
            fileOutputStream.close()
            Log.e(TAG, "[generatePreviewImage] 相机快照生成成功 path $mPreviewImagePath")
            mCallback(mPreviewImagePath)
        } catch (e: Exception) {
            Log.e(TAG, "[generatePreviewImage] 相机快照生成失败 $e")
        }
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
        Utils.normalThreadPool.execute {
            generatePreviewImage(previewBuffer)
        }
        mScheduleTask = Utils.scheduleThreadPool.schedule(Callable {
            generatePreviewImage(previewBuffer)
        }, 15, TimeUnit.MINUTES)
    }

    fun pause() {
        if (mRtmpCamera1?.isStreaming != true) {
            return
        }
        mRtmpCamera1?.stopStream()
        mScheduleTask?.cancel(true)
        mScheduleTask = null
    }

    fun release() {
        if (mRtmpCamera1?.isRecording == true) {
            mRtmpCamera1?.stopRecord()
            updateGallery("${mRecordFolder.absolutePath}/video_$currentDateAndTime.mp4")
            Log.d(
                TAG,
                "[release] file video_$currentDateAndTime.mp4 saved in ${mRecordFolder.absolutePath}"
            )
            currentDateAndTime = ""
        }
        if (mRtmpCamera1?.isStreaming == true) {
            mRtmpCamera1?.stopStream()
        }
        mRtmpCamera1?.glInterface?.clearFilters()
        mRtmpCamera1?.stopPreview()
        mSurfaceView?.holder?.removeCallback(this)
        mFaceTrack?.stopTrack()
        mScheduleTask?.cancel(true)

        mSurfaceView = null
        mRtmpCamera1 = null
        mFaceTrack = null
        yuvBuffer = null
        mScheduleTask = null
        previewBuffer = null
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
                        "${mRecordFolder.absolutePath}/video_$currentDateAndTime.mp4"
                    )
                    Log.d(TAG, "[startRecord] Recording...")
                } else {
                    Log.w(TAG, "[startRecord] Error preparing stream, This device cant do it")
                }
            } else {
                mRtmpCamera1?.startRecord(
                    "${mRecordFolder.absolutePath}/video_$currentDateAndTime.mp4"
                )
                Log.d(TAG, "[startRecord] Recording...")
            }
        } catch (e: IOException) {
            mRtmpCamera1?.stopRecord()
            updateGallery(
                "${mRecordFolder.absolutePath}/video_$currentDateAndTime.mp4"
            )
            Log.e(TAG, "[startRecord] Exception: ${e.message}")
        }
    }

    fun stopRecord(): String? {
        if (mRtmpCamera1?.isRecording != true) {
            return null
        }
        mRtmpCamera1?.stopRecord()
        updateGallery(
            "${mRecordFolder.absolutePath}/video_$currentDateAndTime.mp4"
        )
        Log.d(
            TAG,
            "[stopRecord] file video_$currentDateAndTime.mp4 saved in ${mRecordFolder.absolutePath}"
        )
        return "${mRecordFolder.absolutePath}/video_$currentDateAndTime.mp4"
    }

    fun clearFilter() {
        if (otherFilterIndex != -1) {
            mRtmpCamera1?.glInterface?.removeFilter(otherFilterIndex)
            otherFilterIndex = -1
        }
    }

    fun addVintageTVFilter() {
        val filterCount = mRtmpCamera1?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM) {
            mRtmpCamera1?.glInterface?.addFilter(AnalogTVFilterRender())
            otherFilterIndex = filterCount
        } else {
            mRtmpCamera1?.glInterface?.setFilter(otherFilterIndex, AnalogTVFilterRender())
        }
    }

    fun addWaveFilter() {
        val filterCount = mRtmpCamera1?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM) {
            mRtmpCamera1?.glInterface?.addFilter(BasicDeformationFilterRender())
            otherFilterIndex = filterCount
        } else {
            mRtmpCamera1?.glInterface?.setFilter(otherFilterIndex, BasicDeformationFilterRender())
        }
    }

    fun addBeautyFilter() {
        val filterCount = mRtmpCamera1?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM) {
            mRtmpCamera1?.glInterface?.addFilter(BeautyFilterRender())
            beautyFilterIndex = filterCount
        } else {
            mRtmpCamera1?.glInterface?.setFilter(beautyFilterIndex, BeautyFilterRender())
        }
    }

    fun removeBeautyFilter() {
        if (beautyFilterIndex != -1) {
            mRtmpCamera1?.glInterface?.removeFilter(beautyFilterIndex)
            beautyFilterIndex  = -1
        }
    }

    fun addCartoonFilter() {
        val filterCount = mRtmpCamera1?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM) {
            mRtmpCamera1?.glInterface?.addFilter(CartoonFilterRender())
            otherFilterIndex = filterCount
        } else {
            mRtmpCamera1?.glInterface?.setFilter(otherFilterIndex, CartoonFilterRender())
        }
    }

    fun addProfoundFilter() {
        val filterCount = mRtmpCamera1?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM) {
            mRtmpCamera1?.glInterface?.addFilter(EarlyBirdFilterRender())
            otherFilterIndex = filterCount
        } else {
            mRtmpCamera1?.glInterface?.setFilter(otherFilterIndex, EarlyBirdFilterRender())
        }
    }

    fun addSnowFilter() {
        val filterCount = mRtmpCamera1?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM) {
            mRtmpCamera1?.glInterface?.addFilter(SnowFilterRender())
            otherFilterIndex = filterCount
        } else {
            mRtmpCamera1?.glInterface?.setFilter(otherFilterIndex, SnowFilterRender())
        }
    }

    fun addOldPhotoFilter() {
        val filterCount = mRtmpCamera1?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM) {
            mRtmpCamera1?.glInterface?.addFilter(SepiaFilterRender())
            otherFilterIndex = filterCount
        } else {
            mRtmpCamera1?.glInterface?.setFilter(otherFilterIndex, SepiaFilterRender())
        }
    }

    fun addLamoishFilter() {
        val filterCount = mRtmpCamera1?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM) {
            mRtmpCamera1?.glInterface?.addFilter(LamoishFilterRender())
            otherFilterIndex = filterCount
        } else {
            mRtmpCamera1?.glInterface?.setFilter(otherFilterIndex, LamoishFilterRender())
        }
    }

    fun addMoneyFilter() {
        val filterCount = mRtmpCamera1?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM) {
            mRtmpCamera1?.glInterface?.addFilter(MoneyFilterRender())
            otherFilterIndex = filterCount
        } else {
            mRtmpCamera1?.glInterface?.setFilter(otherFilterIndex, MoneyFilterRender())
        }
    }

    fun addWaterRippleFilter() {
        val filterCount = mRtmpCamera1?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM) {
            mRtmpCamera1?.glInterface?.addFilter(RippleFilterRender())
            otherFilterIndex = filterCount
        } else {
            mRtmpCamera1?.glInterface?.setFilter(otherFilterIndex, RippleFilterRender())
        }
    }

    fun addBigEyeFilter() {
        val filterCount = mRtmpCamera1?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM) {
            mRtmpCamera1?.glInterface?.addFilter(BigEyeFilterRender(mFaceTrack))
            otherFilterIndex = filterCount
        } else {
            mRtmpCamera1?.glInterface?.setFilter(otherFilterIndex, BigEyeFilterRender(mFaceTrack))
        }
    }

    fun addStickFilter() {
        val filterCount = mRtmpCamera1?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM) {
            mRtmpCamera1?.glInterface?.addFilter(StickFilterRender(mContext, mFaceTrack))
            otherFilterIndex = filterCount
        } else {
            mRtmpCamera1?.glInterface?.setFilter(otherFilterIndex, StickFilterRender(mContext, mFaceTrack))
        }
    }

    private fun updateGallery(path: String) = MediaScannerConnection.scanFile(
        mContext, arrayOf(path), arrayOf("video/mp4"), null
    )

    companion object {
        const val TAG: String = "PushStreamView"
        const val FILTER_MAX_NUM = 2
    }
}