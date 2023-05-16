package com.example.graduationdesign.graduationdesign.view

import android.content.Context
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.widget.RelativeLayout
import tv.danmaku.ijk.media.player.IjkMediaPlayer

class PullStreamView(context: Context) : RelativeLayout(context), SurfaceHolder.Callback {
    private var specHeightSize: Int = 0
    private var specWidthSize: Int = 0

    //是否全屏拉伸填满，false等比例最大，不拉伸
    private var fillXY: Boolean = false
    private var mPlayer: IjkMediaPlayer? = null

    // 视频文件地址
    private var rtmpUrl: String? = null
    private var mSurfaceView: SurfaceView? = null
    private val mContext: Context

    init {
        mContext = context
        createSurfaceView()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        specHeightSize = MeasureSpec.getSize(heightMeasureSpec)
        specWidthSize = MeasureSpec.getSize(widthMeasureSpec)
    }

    fun setFillXY(fillXY: Boolean) {
        this.fillXY = fillXY
    }

    fun setRtmpUrl(url: String) {
        rtmpUrl = url
        if (rtmpUrl?.isNotEmpty() == true) {
            load()
        }
    }

    /**
     * 新建一个SurfaceView
     */
    private fun createSurfaceView() {
        mSurfaceView = SurfaceView(mContext)
        mSurfaceView?.holder?.addCallback(this)

        val layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        layoutParams.addRule(CENTER_IN_PARENT)
        mSurfaceView?.layoutParams = layoutParams
        addView(mSurfaceView)
    }

    override fun surfaceCreated(surfaceHolder: SurfaceHolder) {}

    override fun surfaceChanged(
        surfaceHolder: SurfaceHolder, format: Int, width: Int, height: Int
    ) {
        if (rtmpUrl?.isNotEmpty() == true) {
            load()
        }
    }

    override fun surfaceDestroyed(surfaceHolder: SurfaceHolder) = release()

    /**
     * 加载视频
     */
    private fun load() {
        // 每次加载都需要重新创建IjkMediaPlayer
        createIjkMediaPlayer()
        mPlayer?.dataSource = rtmpUrl
        // mPlayer?.isLooping = true
        // mPlayer?.setVolume(0f,0f)
        // 给IjkMediaPlayer设置视图
        mPlayer?.setDisplay(mSurfaceView?.holder)
        mPlayer?.prepareAsync()
    }

    /**
     * 创建一个新的IjkMediaPlayer
     */
    private fun createIjkMediaPlayer() {
        // 释放上一个IjkMediaPlayer资源
        if (mPlayer != null) {
            mPlayer?.stop()
            mPlayer?.setDisplay(null)
            mPlayer?.release()
        }
        // 创建新的IjkMediaPlayer
        mPlayer = IjkMediaPlayer()
        // 开启debug日志
        IjkMediaPlayer.native_setLogLevel(IjkMediaPlayer.IJK_LOG_DEBUG)
        // 开启硬解码
        mPlayer?.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "mediacodec", 1)
        mPlayer?.setOnVideoSizeChangedListener { _, width, height, _, _ ->
            if (width != 0 && height != 0) {
                if (mSurfaceView != null) {
                    val layoutParams = mSurfaceView?.layoutParams as LayoutParams
                    if (fillXY) {
                        layoutParams.width = -1
                        layoutParams.height = -1
                    } else {
                        val scanXY: Float = if (specHeightSize / specWidthSize > height / width) {
                            // 高剩余，以宽填满
                            specWidthSize / width.toFloat()
                        } else {
                            specHeightSize / height.toFloat()
                        }
                        layoutParams.width = (width * scanXY).toInt()
                        layoutParams.height = (height * scanXY).toInt()
                    }
                    mSurfaceView?.layoutParams = layoutParams
                }
                requestLayout()
            }
        }
    }

    fun resume() {
        mPlayer?.start()
    }

    fun pause() {
        mPlayer?.pause()
    }

    fun release() {
        mPlayer?.stop()
        mPlayer?.reset()
        mPlayer?.release()
        mSurfaceView?.holder?.removeCallback(this)

        mPlayer = null
        mSurfaceView = null
    }

    val duration: Long get() = mPlayer?.duration ?: -1

    val currentPosition: Long get() = mPlayer?.currentPosition ?: -1
}