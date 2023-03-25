package com.example.graduationdesign.graduationdesign

import android.content.Context
import android.text.TextUtils
import android.view.Gravity
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.widget.FrameLayout
import tv.danmaku.ijk.media.player.IjkMediaPlayer
import java.io.IOException

class VideoView(context: Context) : FrameLayout(context, null, 0) {
    private var specHeightSize = 0
    private var specWidthSize = 0

    //是否全屏拉伸填满，false等比例最大，不拉伸
    private var fillXY = false

    // 由ijkplayer提供，用于播放视频，需要给他传入一个surfaceView
    private var mMediaPlayer: IjkMediaPlayer? = null

    // 视频文件地址
    private var mPath = ""
    private var mSurfaceView: SurfaceView? = null

    //    private var mListener: VideoViewListener? = null
    private var mContext: Context? = null

    init {
        init(context)
    }

    private fun init(context: Context) {
        mContext = context
        //获取焦点
//        setFocusable(true)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        specHeightSize = MeasureSpec.getSize(heightMeasureSpec)
        specWidthSize = MeasureSpec.getSize(widthMeasureSpec)
    }

    fun setFillXY(fillXY: Boolean) {
        this.fillXY = fillXY
    }

    /**
     * 设置视频地址。
     * 根据是否第一次播放视频，做不同的操作。
     *
     * @param path the path of the video.
     */
    fun setVideoPath(path: String) {
        if (TextUtils.equals("", mPath)) {
            //如果是第一次播放视频，那就创建一个新的surfaceView
            mPath = path
            createSurfaceView()
        } else {
            //否则就直接load
            mPath = path
            load()
        }
    }

    /**
     * 新建一个surfaceview
     */
    private fun createSurfaceView() {
        //生成一个新的surface view
        mSurfaceView = SurfaceView(mContext)
        mSurfaceView?.holder?.addCallback(LmnSurfaceCallback())
        val layoutParams = LayoutParams(
            LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT, Gravity.CENTER
        )
        mSurfaceView?.layoutParams = layoutParams
        addView(mSurfaceView)
    }

    /**
     * surfaceView的监听器
     */
    private inner class LmnSurfaceCallback : SurfaceHolder.Callback {
        override fun surfaceCreated(holder: SurfaceHolder) {}
        override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) =
            load()

        override fun surfaceDestroyed(holder: SurfaceHolder) {}
    }

    /**
     * 加载视频
     */
    private fun load() {
        //每次都要重新创建IMediaPlayer
        createPlayer()
        try {
            mMediaPlayer?.dataSource = mPath
            mMediaPlayer?.isLooping = true
            //mMediaPlayer.setVolume(0f,0f);
        } catch (e: IOException) {
            e.printStackTrace()
        }
        //给mediaPlayer设置视图
        mMediaPlayer?.setDisplay(mSurfaceView?.holder)
        mMediaPlayer?.prepareAsync()
    }

    /**
     * 创建一个新的player
     */
    private fun createPlayer() {
        if (mMediaPlayer != null) {
            mMediaPlayer!!.stop()
            mMediaPlayer!!.setDisplay(null)
            mMediaPlayer!!.release()
        }
        val ijkMediaPlayer = IjkMediaPlayer()
        // 开启debug日志
        // IjkMediaPlayer.native_setLogLevel(IjkMediaPlayer.IJK_LOG_DEBUG)
        //开启硬解码
        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "mediacodec", 1)
        mMediaPlayer = ijkMediaPlayer
        mMediaPlayer?.setOnVideoSizeChangedListener { mp, width, height, sarNum, sarDen ->
            if (width != 0 && height != 0) {
                if (mSurfaceView != null) {
                    val lp = mSurfaceView?.layoutParams as LayoutParams
                    if (fillXY) {
                        lp.width = -1
                        lp.height = -1
                    } else {
                        val scanXY: Float
                        scanXY = if (specHeightSize / specWidthSize > height / width) {
                            //高剩余，以宽填满
                            specWidthSize / width.toFloat()
                        } else {
                            specHeightSize / height.toFloat()
                        }
                        lp.width = (width * scanXY).toInt()
                        lp.height = (height * scanXY).toInt()
                    }
                    mSurfaceView?.layoutParams = lp
                }
//                requestLayout()
            }
        }

//        if (mListener != null) {
//            mMediaPlayer?.setOnPreparedListener(mListener);
//            mMediaPlayer?.setOnInfoListener(mListener);
//            mMediaPlayer?.setOnSeekCompleteListener(mListener);
//            mMediaPlayer?.setOnBufferingUpdateListener(mListener);
//            mMediaPlayer?.setOnErrorListener(mListener);
//        }
    }

//    fun setListener(VideoViewListener listener) {
//        mListener = listener
//        mMediaPlayer?.setOnPreparedListener(listener)
//    }

    /**
     * 下面封装了控制视频的方法
     */
    fun setVolume(v1: Float, v2: Float) = mMediaPlayer?.setVolume(v1, v2)

    fun start() = mMediaPlayer?.start()

    fun release() {
        mMediaPlayer?.reset()
        mMediaPlayer?.release()
        mMediaPlayer = null
    }

    fun pause() = mMediaPlayer?.pause()

    fun stop() = mMediaPlayer?.stop()

    fun reset() = mMediaPlayer?.reset()

    val duration: Long
        get() = mMediaPlayer?.duration ?: -1

    val currentPosition: Long
        get() = mMediaPlayer?.currentPosition ?: -1

    fun seekTo(l: Long) = mMediaPlayer?.seekTo(l)

    companion object {
        private const val TAG = "VideoView"
    }
}