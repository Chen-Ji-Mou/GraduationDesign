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
import java.io.*
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.Callable
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.TimeUnit

enum class FilterType {
    vintageTV, wave, cartoon, profound, snow, oldPhoto, lamoish, money, waterRipple, bigEye, stick,
}

class PushStreamView(context: Context, callback: (filePath: String) -> Unit) :
    RelativeLayout(context), ConnectCheckerRtmp, SurfaceHolder.Callback,
    Camera1ApiManagerProxy.PreviewCallback {
    private val mContext: Context
    private val mCallback: (filePath: String) -> Unit

    private var rtmpUrl: String? = null
    private var mSurfaceView: OpenGlView? = null
    private var mRtmpCamera: RtmpCamera1? = null
    private var currentDateAndTime: String = ""
    private var mFaceTrack: FaceTrack? = null
    private var yuvBuffer: ByteArray? = null
    private var mScheduleTask: ScheduledFuture<Unit>? = null
    private var mPreviewImagePath: String = ""
    private var previewBuffer: ByteArray? = null
    private var beautyFilterIndex: Int = -1
    private var otherFilterIndex: Int = -1
    private lateinit var curFilterType: FilterType

    private val mRecordFolder: File
        get() {
            val storageDir: File =
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
            return File(storageDir.absolutePath)
        }

    private val previewSize: Size = Size(640, 480)

    init {
        mContext = context
        mCallback = callback
        createSurfaceView()
        initRtmpCamera()
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

    override fun surfaceCreated(surfaceHolder: SurfaceHolder) {
        Log.d(TAG, "[surfaceCreated]")
    }

    override fun surfaceChanged(
        surfaceHolder: SurfaceHolder, format: Int, width: Int, height: Int
    ) {
        Log.d(TAG, "[surfaceChanged]")
        start()
    }

    override fun surfaceDestroyed(surfaceHolder: SurfaceHolder) {
        Log.d(TAG, "[surfaceDestroyed]")
        release()
    }

    private fun initRtmpCamera() {
        mRtmpCamera = RtmpCamera1(mSurfaceView, this)
        hookCameraManager()
    }

    private fun hookCameraManager() {
        val field = RtmpCamera1::class.java.superclass.getDeclaredField("cameraManager")
        field.isAccessible = true
        val proxy = Camera1ApiManagerProxy(
            mSurfaceView?.surfaceTexture, mSurfaceView?.context
        )
        proxy.addPreviewCallback(this)
        field.set(mRtmpCamera, proxy)
    }

    private fun hookCameraPreviewListen() {
        yuvBuffer = ByteArray(previewSize.width * previewSize.height * 3 / 2)

        val proxyField = RtmpCamera1::class.java.superclass.getDeclaredField("cameraManager")
        proxyField.isAccessible = true
        val proxyObj = proxyField.get(mRtmpCamera) as Camera1ApiManagerProxy

        val cameraField = Camera1ApiManagerProxy::class.java.superclass.getDeclaredField("camera")
        cameraField.isAccessible = true
        val cameraObj = cameraField.get(proxyObj) as Camera

        cameraObj.addCallbackBuffer(yuvBuffer)
        cameraObj.setPreviewCallbackWithBuffer(proxyObj)
    }

    override fun onPreviewFrame(data: ByteArray, camera: Camera) {
        Log.d(
            TAG,
            "[onPreviewFrame] previewSize.with ${camera.parameters.previewSize.width} previewSize.height ${camera.parameters.previewSize.height}"
        )
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
        mRtmpCamera?.stopStream()
        Log.e(TAG, "[onAuthErrorRtmp] Auth Error")
    }

    override fun onAuthSuccessRtmp() {
        Log.e(TAG, "[onAuthSuccessRtmp] Auth Success")
    }

    override fun onConnectionFailedRtmp(reason: String) {
        Log.e(TAG, "[onConnectionFailedRtmp] Connection failed. Reason: $reason")
        mRtmpCamera?.stopStream()
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
        mRtmpCamera?.startPreview(CameraHelper.Facing.FRONT, previewSize.width, previewSize.height)
        hookCameraPreviewListen()
        mFaceTrack = FaceTrack(
            "/sdcard/Android/data/${mContext.packageName}/cache/lbpcascade_frontalface.xml",
            "/sdcard/Android/data/${mContext.packageName}/cache/seeta_fa_v1.1.bin",
            mRtmpCamera?.cameraFacing,
            previewSize.width,
            previewSize.height
        )
        mFaceTrack?.startTrack()
    }

    fun resume() {
        if (mRtmpCamera?.isStreaming == true) {
            return
        }
        if (mRtmpCamera?.prepareAudio() == true && mRtmpCamera?.prepareVideo() == true) {
            mRtmpCamera?.startStream(rtmpUrl)
        } else {
            Log.w(TAG, "[resume] Error preparing stream, This device cant do it")
        }
        hookCameraPreviewListen()
        restoreFilters()
        Utils.normalThreadPool.execute {
            generatePreviewImage(previewBuffer)
        }
        mScheduleTask = Utils.scheduleThreadPool.schedule(Callable {
            generatePreviewImage(previewBuffer)
        }, 15, TimeUnit.MINUTES)
    }

    private fun restoreFilters() {
        if (beautyFilterIndex != -1) {
            addBeautyFilter()
        }
        if (otherFilterIndex != -1) {
            addOtherFilter(curFilterType)
        }
    }

    fun pause() {
        if (mRtmpCamera?.isStreaming != true) {
            return
        }
        mRtmpCamera?.stopStream()
        mScheduleTask?.cancel(true)
        mScheduleTask = null
    }

    fun release() {
        if (mRtmpCamera?.isRecording == true) {
            mRtmpCamera?.stopRecord()
            updateGallery("${mRecordFolder.absolutePath}/video_$currentDateAndTime.mp4")
            Log.d(
                TAG,
                "[release] file video_$currentDateAndTime.mp4 saved in ${mRecordFolder.absolutePath}"
            )
            currentDateAndTime = ""
        }
        if (mRtmpCamera?.isStreaming == true) {
            mRtmpCamera?.stopStream()
        }
        mRtmpCamera?.glInterface?.clearFilters()
        mFaceTrack?.stopTrack()
        mScheduleTask?.cancel(true)
        mRtmpCamera?.stopPreview()

        mSurfaceView = null
        mRtmpCamera = null
        mFaceTrack = null
        yuvBuffer = null
        mScheduleTask = null
        previewBuffer = null
    }

    fun switchCamera() {
        try {
            mRtmpCamera?.switchCamera()
        } catch (e: CameraOpenException) {
            Log.e(TAG, "[switchCamera] Exception: ${e.message}")
        }
    }

    fun startRecord() {
        if (mRtmpCamera?.isRecording == true) {
            return
        }
        try {
            if (!mRecordFolder.exists()) {
                mRecordFolder.mkdir()
            }
            val sdf = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault())
            currentDateAndTime = sdf.format(Date())
            if (mRtmpCamera?.isStreaming != true) {
                if (mRtmpCamera?.prepareAudio() == true && mRtmpCamera?.prepareVideo() == true) {
                    mRtmpCamera?.startRecord(
                        "${mRecordFolder.absolutePath}/video_$currentDateAndTime.mp4"
                    )
                    Log.d(TAG, "[startRecord] Recording...")
                } else {
                    Log.w(TAG, "[startRecord] Error preparing stream, This device cant do it")
                }
            } else {
                mRtmpCamera?.startRecord(
                    "${mRecordFolder.absolutePath}/video_$currentDateAndTime.mp4"
                )
                Log.d(TAG, "[startRecord] Recording...")
            }
        } catch (e: IOException) {
            mRtmpCamera?.stopRecord()
            updateGallery(
                "${mRecordFolder.absolutePath}/video_$currentDateAndTime.mp4"
            )
            Log.e(TAG, "[startRecord] Exception: ${e.message}")
        }
    }

    fun stopRecord(): String? {
        if (mRtmpCamera?.isRecording != true) {
            return null
        }
        mRtmpCamera?.stopRecord()
        updateGallery(
            "${mRecordFolder.absolutePath}/video_$currentDateAndTime.mp4"
        )
        Log.d(
            TAG,
            "[stopRecord] file video_$currentDateAndTime.mp4 saved in ${mRecordFolder.absolutePath}"
        )
        return "${mRecordFolder.absolutePath}/video_$currentDateAndTime.mp4"
    }

    fun clearOtherFilter() {
        if (otherFilterIndex != -1) {
            mRtmpCamera?.glInterface?.removeFilter(otherFilterIndex)
            if (beautyFilterIndex > otherFilterIndex) {
                beautyFilterIndex--
            }
            otherFilterIndex = -1
        }
    }

    fun addOtherFilter(type: FilterType) {
        curFilterType = type
        val curFilter = when (type) {
            FilterType.vintageTV -> AnalogTVFilterRender()
            FilterType.wave -> BasicDeformationFilterRender()
            FilterType.cartoon -> CartoonFilterRender()
            FilterType.profound -> EarlyBirdFilterRender()
            FilterType.snow -> SnowFilterRender()
            FilterType.oldPhoto -> SepiaFilterRender()
            FilterType.lamoish -> LamoishFilterRender()
            FilterType.money -> MoneyFilterRender()
            FilterType.waterRipple -> RippleFilterRender()
            FilterType.bigEye -> BigEyeFilterRender(mFaceTrack)
            FilterType.stick -> StickFilterRender(mContext, mFaceTrack)
        }
        val filterCount = mRtmpCamera?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM && otherFilterIndex == -1) {
            mRtmpCamera?.glInterface?.addFilter(curFilter)
            otherFilterIndex = filterCount
        } else if (otherFilterIndex != -1) {
            mRtmpCamera?.glInterface?.setFilter(otherFilterIndex, curFilter)
        }
    }

    fun removeBeautyFilter() {
        if (beautyFilterIndex != -1) {
            mRtmpCamera?.glInterface?.removeFilter(beautyFilterIndex)
            if (otherFilterIndex > beautyFilterIndex) {
                otherFilterIndex--
            }
            beautyFilterIndex = -1
        }
    }

    fun addBeautyFilter() {
        val filterCount = mRtmpCamera?.glInterface?.filtersCount() ?: 0
        if (filterCount < FILTER_MAX_NUM && beautyFilterIndex == -1) {
            mRtmpCamera?.glInterface?.addFilter(BeautyFilterRender())
            beautyFilterIndex = filterCount
        } else if (beautyFilterIndex != -1) {
            mRtmpCamera?.glInterface?.setFilter(beautyFilterIndex, BeautyFilterRender())
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