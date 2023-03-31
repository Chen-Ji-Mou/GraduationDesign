package com.example.graduationdesign.graduationdesign.view

import android.content.Context
import android.graphics.Color
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.widget.RelativeLayout
import com.example.graduationdesign.graduationdesign.Utils
import master.flame.danmaku.controller.DrawHandler
import master.flame.danmaku.danmaku.model.BaseDanmaku
import master.flame.danmaku.danmaku.model.DanmakuTimer
import master.flame.danmaku.danmaku.model.IDanmakus
import master.flame.danmaku.danmaku.model.android.DanmakuContext
import master.flame.danmaku.danmaku.model.android.Danmakus
import master.flame.danmaku.danmaku.parser.BaseDanmakuParser
import master.flame.danmaku.ui.widget.DanmakuView
import tv.danmaku.ijk.media.player.IjkMediaPlayer
import java.util.*

class PullStreamView(context: Context) : RelativeLayout(context, null, 0), DrawHandler.Callback,
    SurfaceHolder.Callback {
    private var specHeightSize: Int = 0
    private var specWidthSize: Int = 0

    //是否全屏拉伸填满，false等比例最大，不拉伸
    private var fillXY: Boolean = false
    private var mPlayer: IjkMediaPlayer? = null

    // 视频文件地址
    private var rtmpUrl: String = ""
    private var mSurfaceView: SurfaceView? = null
    private val mContext: Context
    private var mBarrageView: DanmakuView? = null
    private var mBarrageContext: DanmakuContext? = null
    private var barrageOpen: Boolean = false

    private val mBarrageParser = object : BaseDanmakuParser() {
        override fun parse(): IDanmakus {
            return Danmakus()
        }
    }

    init {
        mContext = context
        createSurfaceView()
        createBarrageView()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        specHeightSize = MeasureSpec.getSize(heightMeasureSpec)
        specWidthSize = MeasureSpec.getSize(widthMeasureSpec)
    }

    fun setFillXY(fillXY: Boolean) {
        this.fillXY = fillXY
    }

    fun setRtmpUrl(path: String) {
        rtmpUrl = path
        if (rtmpUrl.isNotEmpty()) {
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
        mSurfaceView?.layoutParams = layoutParams
        addView(mSurfaceView)
    }

    override fun surfaceCreated(surfaceHolder: SurfaceHolder) {}

    override fun surfaceChanged(
        surfaceHolder: SurfaceHolder, format: Int, width: Int, height: Int
    ) {
    }

    override fun surfaceDestroyed(surfaceHolder: SurfaceHolder) {}

    /**
     * 新建弹幕视图
     */
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
        // IjkMediaPlayer.native_setLogLevel(IjkMediaPlayer.IJK_LOG_DEBUG)
        // 开启硬解码
        mPlayer?.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "mediacodec", 1)
        mPlayer?.setOnVideoSizeChangedListener { _, width, height, _, _ ->
            if (width != 0 && height != 0) {
                if (mSurfaceView != null) {
                    val lp = mSurfaceView?.layoutParams as LayoutParams
                    if (fillXY) {
                        lp.width = -1
                        lp.height = -1
                    } else {
                        val scanXY: Float = if (specHeightSize / specWidthSize > height / width) {
                            // 高剩余，以宽填满
                            specWidthSize / width.toFloat()
                        } else {
                            specHeightSize / height.toFloat()
                        }
                        lp.width = (width * scanXY).toInt()
                        lp.height = (height * scanXY).toInt()
                    }
                    mSurfaceView?.layoutParams = lp
                }
                requestLayout()
            }
        }
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

    fun resume() {
        mPlayer?.start()
        if (mBarrageView?.isPrepared == true && mBarrageView?.isPaused == true) {
            mBarrageView?.resume()
        }
    }

    fun pause() {
        mPlayer?.stop()
        if (mBarrageView?.isPrepared == true && mBarrageView?.isPaused == false) {
            mBarrageView?.pause()
        }
    }

    fun release() {
        mPlayer?.stop()
        mPlayer?.reset()
        mPlayer?.release()
        mPlayer = null

        mSurfaceView?.holder?.removeCallback(this)
        mSurfaceView = null

        mBarrageView?.release()
        mBarrageView?.setCallback(null)
        barrageOpen = false
        mBarrageContext = null
        mBarrageView = null
    }

    val duration: Long get() = mPlayer?.duration ?: -1

    val currentPosition: Long get() = mPlayer?.currentPosition ?: -1
}