package com.example.graduationdesign.graduationdesign

import android.content.Context
import android.media.MediaScannerConnection
import android.os.Environment
import android.view.*
import android.widget.*
import com.pedro.encoder.input.video.CameraOpenException
import com.pedro.rtmp.utils.ConnectCheckerRtmp
import com.pedro.rtplibrary.rtmp.RtmpCamera1
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

class PushStreamView(context: Context) : RelativeLayout(context, null, 0), ConnectCheckerRtmp,
    SurfaceHolder.Callback {
//    private val mMainThreadHandler: Handler = Handler(Looper.getMainLooper())
    private val mContext: Context
    private val mRecordFolder: File
    private var mPath: String? = null
    private var mSurfaceView: SurfaceView? = null
    private var mControllerView: LinearLayout? = null
    private var mRtmpCamera1: RtmpCamera1? = null
    private var mPushStreamControlButton: Button? = null
    private var mRecordButton: Button? = null
    private var currentDateAndTime = ""

    init {
        mContext = context
        mRecordFolder = getRecordPath()
    }

    fun setPushStreamPath(path: String) {
        mPath = path
        if (mSurfaceView == null) {
            mSurfaceView = createSurfaceView()
        }
        if (mControllerView == null) {
            mControllerView = createControllerView()
        }
    }

    private fun createSurfaceView(): SurfaceView {
        val surfaceView = SurfaceView(mContext)
        surfaceView.holder.addCallback(this)
        val surfaceParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        surfaceParams.addRule(CENTER_IN_PARENT)
        surfaceView.layoutParams = surfaceParams
        addView(surfaceView)

        mRtmpCamera1 = RtmpCamera1(surfaceView, this)
        mRtmpCamera1?.setReTries(5)

        return surfaceView
    }

    private fun createControllerView(): LinearLayout {
        val linearLayout = LinearLayout(mContext)
        linearLayout.orientation = LinearLayout.HORIZONTAL
        val linearLayoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
        linearLayoutParams.addRule(ALIGN_PARENT_BOTTOM)
        linearLayoutParams.addRule(CENTER_HORIZONTAL)
        linearLayout.layoutParams = linearLayoutParams

        val pushStreamControlButton = Button(mContext)
        mPushStreamControlButton = pushStreamControlButton
        pushStreamControlButton.text = mContext.getString(R.string.startPushStream)
        pushStreamControlButton.setOnClickListener { startButtonClick() }
        val startButtonParams = LinearLayout.LayoutParams(0, LayoutParams.WRAP_CONTENT, 1f)
        startButtonParams.setMargins(8, 8, 4, 8)
        pushStreamControlButton.layoutParams = startButtonParams
        linearLayout.addView(pushStreamControlButton)

        val switchCameraButton = Button(mContext)
        switchCameraButton.text = mContext.getString(R.string.switchCamera)
        switchCameraButton.setOnClickListener { switchCameraClick() }
        val switchCameraButtonParams = LinearLayout.LayoutParams(0, LayoutParams.WRAP_CONTENT, 1f)
        switchCameraButtonParams.setMargins(4, 8, 4, 8)
        switchCameraButton.layoutParams = switchCameraButtonParams
        linearLayout.addView(switchCameraButton)

        val recordButton = Button(mContext)
        mRecordButton = recordButton
        recordButton.text = mContext.getString(R.string.startRecord)
        recordButton.setOnClickListener { recordClick() }
        val recordButtonParams = LinearLayout.LayoutParams(0, LayoutParams.WRAP_CONTENT, 1f)
        recordButtonParams.setMargins(4, 8, 8, 8)
        recordButton.layoutParams = recordButtonParams
        linearLayout.addView(recordButton)

        addView(linearLayout)
        return linearLayout
    }

    private fun startButtonClick() {
        if (mRtmpCamera1?.isStreaming != true) {
            if (mRtmpCamera1?.isRecording == true || mRtmpCamera1?.prepareAudio() == true && mRtmpCamera1?.prepareVideo() == true) {
                mPushStreamControlButton?.text = mContext.getString(R.string.stopPushStream)
                mRtmpCamera1?.startStream(mPath)
            } else {
                Toast.makeText(
                    mContext, "Error preparing stream, This device cant do it", Toast.LENGTH_SHORT
                ).show()
            }
        } else {
            mPushStreamControlButton?.text = mContext.getText(R.string.startPushStream)
            mRtmpCamera1?.stopStream()
        }
    }

    private fun switchCameraClick() {
        try {
            mRtmpCamera1?.switchCamera()
        } catch (e: CameraOpenException) {
            Toast.makeText(mContext, e.message, Toast.LENGTH_SHORT).show()
        }
    }

    private fun recordClick() {
        if (mRtmpCamera1?.isRecording != true) {
            try {
                if (!mRecordFolder.exists()) {
                    mRecordFolder.mkdir()
                }
                val sdf = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault())
                currentDateAndTime = sdf.format(Date())
                if (mRtmpCamera1?.isStreaming != true) {
                    if (mRtmpCamera1?.prepareAudio() == true && mRtmpCamera1?.prepareVideo() == true) {
                        mRtmpCamera1?.startRecord(
                            mRecordFolder.absolutePath + "/" + currentDateAndTime + ".mp4"
                        )
                        mRecordButton?.text = mContext.getString(R.string.stopRecord)
                        Toast.makeText(mContext, "Recording... ", Toast.LENGTH_SHORT).show()
                    } else {
                        Toast.makeText(
                            mContext,
                            "Error preparing stream, This device cant do it",
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                } else {
                    mRtmpCamera1?.startRecord(
                        mRecordFolder.absolutePath + "/" + currentDateAndTime + ".mp4"
                    )
                    mRecordButton?.text = mContext.getString(R.string.stopRecord)
                    Toast.makeText(mContext, "Recording... ", Toast.LENGTH_SHORT).show()
                }
            } catch (e: IOException) {
                mRtmpCamera1?.stopRecord()
                updateGallery(
                    mRecordFolder.absolutePath + "/" + currentDateAndTime + ".mp4"
                )
                mRecordButton?.text = mContext.getString(R.string.startRecord)
                Toast.makeText(mContext, e.message, Toast.LENGTH_SHORT).show()
            }
        } else {
            mRtmpCamera1?.stopRecord()
            updateGallery(
                mRecordFolder.absolutePath + "/" + currentDateAndTime + ".mp4"
            )
            mRecordButton?.text = mContext.getString(R.string.startRecord)
            Toast.makeText(
                mContext,
                "file " + currentDateAndTime + ".mp4 saved in " + mRecordFolder.absolutePath,
                Toast.LENGTH_SHORT
            ).show()
        }
    }

    private fun getRecordPath(): File {
        val storageDir: File =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
        return File(storageDir.absolutePath + "/Record")
    }

    private fun updateGallery(path: String) {
        MediaScannerConnection.scanFile(
            mContext, arrayOf(path), arrayOf("video/mp4"), null
        )
    }

    override fun onAuthErrorRtmp() {
        mRtmpCamera1?.stopStream()
        mPushStreamControlButton?.text = mContext.getString(R.string.startPushStream)
    }

    override fun onAuthSuccessRtmp() {
//        mMainThreadHandler.post {
//            Toast.makeText(
//                mContext, "Auth success", Toast.LENGTH_SHORT
//            ).show()
//        }
    }

    override fun onConnectionFailedRtmp(reason: String) {
        if (mRtmpCamera1?.reTry(5000, reason, null) == true) {
            Toast.makeText(mContext, "Retry", Toast.LENGTH_SHORT).show()
        } else {
            Toast.makeText(
                mContext, "Connection failed. $reason", Toast.LENGTH_SHORT
            ).show()
            mRtmpCamera1?.stopStream()
            mPushStreamControlButton?.text = mContext.getString(R.string.startPushStream)
        }
    }

    override fun onConnectionStartedRtmp(rtmpUrl: String) {}

    override fun onConnectionSuccessRtmp() {
//        mMainThreadHandler.post {
//            Toast.makeText(
//                mContext, "Connection success", Toast.LENGTH_SHORT
//            ).show()
//        }
    }

    override fun onDisconnectRtmp() {
//        mMainThreadHandler.post {
//            Toast.makeText(
//                mContext, "Disconnected", Toast.LENGTH_SHORT
//            ).show()
//        }
    }

    override fun onNewBitrateRtmp(bitrate: Long) {}

    override fun surfaceCreated(p0: SurfaceHolder) {}

    override fun surfaceChanged(surfaceHolder: SurfaceHolder, p1: Int, p2: Int, p3: Int) {
        mRtmpCamera1?.startPreview()
    }

    override fun surfaceDestroyed(surfaceHolder: SurfaceHolder) {
        if (mRtmpCamera1?.isRecording == true) {
            mRtmpCamera1?.stopRecord()
            updateGallery(mRecordFolder.absolutePath + "/" + currentDateAndTime + ".mp4")
            mRecordButton?.text = mContext.getString(R.string.startRecord)
            Toast.makeText(
                mContext,
                "file " + currentDateAndTime + ".mp4 saved in " + mRecordFolder.absolutePath,
                Toast.LENGTH_SHORT
            ).show()
            currentDateAndTime = ""
        }
        if (mRtmpCamera1?.isStreaming == true) {
            mRtmpCamera1?.stopStream()
            mPushStreamControlButton?.text = mContext.getString(R.string.startPushStream)
        }
        mRtmpCamera1?.stopPreview()
    }
}