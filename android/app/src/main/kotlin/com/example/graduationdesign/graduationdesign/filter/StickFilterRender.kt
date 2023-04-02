package com.example.graduationdesign.graduationdesign.filter

import android.content.Context
import android.graphics.BitmapFactory
import android.opengl.GLES20
import android.opengl.GLUtils
import android.util.Log
import com.example.graduationdesign.graduationdesign.R
import com.example.graduationdesign.graduationdesign.Utils
import com.example.graduationdesign.graduationdesign.track.FaceData
import com.example.graduationdesign.graduationdesign.track.FaceTrack
import com.pedro.encoder.input.gl.render.filters.BaseFilterRender
import com.pedro.encoder.utils.gl.GlUtil
import java.nio.FloatBuffer

class StickFilterRender(mContext: Context, private val mFaceTrack: FaceTrack?) :
    BaseFilterRender() {
    private val mBitmap =
        BitmapFactory.decodeResource(mContext.resources, R.drawable.ear) // 加载耳朵图片为Bitmap
    private val mStickTextureID = IntArray(1) // Bitmap转变成纹理ID
    private var programId = -1
    private var vPosition = -1
    private var vCoord = -1
    private var vTexture = -1
    private val mVertexBuffer: FloatBuffer // 顶点坐标数据缓冲区buffer
    private val mTextureBuffer: FloatBuffer // 纹理坐标数据缓冲区buffer
    private val mStickTextureBuffer: FloatBuffer

    init {
        val vertex = floatArrayOf(-1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f)
        mVertexBuffer = Utils.getFloatBuffer(vertex)
        val texture = floatArrayOf(0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f)
        mTextureBuffer = Utils.getFloatBuffer(texture)
        val stickTexture = floatArrayOf(0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f)
        mStickTextureBuffer = Utils.getFloatBuffer(stickTexture)
    }

    override fun initGlFilter(context: Context?) {
        val vertexShader = GlUtil.getStringFromRaw(context, R.raw.base_vertex)
        val fragmentShader = GlUtil.getStringFromRaw(context, R.raw.base_fragment)

        programId = GlUtil.createProgram(vertexShader, fragmentShader)

        vPosition = GLES20.glGetAttribLocation(programId, "vPosition")
        vCoord = GLES20.glGetAttribLocation(programId, "vCoord")
        vTexture = GLES20.glGetUniformLocation(programId, "vTexture")

        Utils.generateTextures(mStickTextureID) // 生成纹理ID

        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mStickTextureID[0]) // 绑定纹理ID 到 纹理2D

        // 这里特殊：不再是像之前像素数据方式，而是Bitmap的专用方式
        GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, mBitmap, 0) // 级别一般都是0， 边框一般都是0

        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0) // 解除绑定纹理
    }

    override fun drawFilter() {
        val faceData = mFaceTrack?.getFaceData() ?: return
        // 使用着色器程序
        GLES20.glUseProgram(programId)
        // 这里是因为要渲染到FBO缓存中，而不是直接显示到屏幕上
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, renderHandler.fboId[0])

        // 渲染 传值
        // 1：顶点数据
        mVertexBuffer.position(0)
        GLES20.glVertexAttribPointer(vPosition, 2, GLES20.GL_FLOAT, false, 0, mVertexBuffer) // 传值
        GLES20.glEnableVertexAttribArray(vPosition) // 传值后激活
        // 2：纹理坐标
        mTextureBuffer.position(0)
        GLES20.glVertexAttribPointer(vCoord, 2, GLES20.GL_FLOAT, false, 0, mTextureBuffer) // 传值
        GLES20.glEnableVertexAttribArray(vCoord) // 传值后激活

        // 片元 vTexture
        GLES20.glUniform1i(vTexture, 0) // 传递参数
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0) // 激活图层
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, previousTexId) // 绑定

        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4) // 通知opengl绘制

        // 解绑fbo
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0)
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0)

        drawStick(faceData)
    }

    /**
     * 画耳朵贴纸-在上一层的纹理中 需要混合融合模式，才能贴上去
     */
    private fun drawStick(faceData: FaceData) {
        GLES20.glEnable(GLES20.GL_BLEND) // 开启混合模式，让贴纸和原纹理混合（融合）

        // sfactor : src原图因子   dfactor : dst目标图因子
        // src:GL_ONE ：全部绘制(耳朵全部保留)
        // dst:GL_ONE_MINUS_SRC_ALPHA ： 1.0 - 源图颜色的alpha作为因子 https://blog.csdn.net/hudfang/article/details/46726465
        GLES20.glBlendFunc(
            GLES20.GL_ONE, GLES20.GL_ONE_MINUS_SRC_ALPHA
        ) // 有几种混合模式和因子，可以自行尝试，一般都用这个：GL_ONE_MINUS_SRC_ALPHA

        // 画贴纸耳朵
        // 获取人脸框的起始坐标（android屏幕坐标）
        val x = faceData.landMarks[0]
        val y = faceData.landMarks[1]

        // opengl的渲染坐标系是以左下角为原点，右为x轴的正方向，上为y轴的正方向

        val newX = x.toInt() // 耳朵要根据人脸框框的变换而变换
        val newY = (faceData.screenHeight - y).toInt() // 将android屏幕坐标转换成opengl渲染坐标
        val viewWidth = faceData.faceWidth
        val viewHeight = mBitmap.height / 2
        GLES20.glViewport(newX, newY, viewWidth, viewHeight)

        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, renderHandler.fboId[0])

        // 使用着色器程序
        GLES20.glUseProgram(programId)

        // 渲染 传值
        // 1：顶点数据
        mVertexBuffer.position(0)
        GLES20.glVertexAttribPointer(vPosition, 2, GLES20.GL_FLOAT, false, 0, mVertexBuffer) // 传值
        GLES20.glEnableVertexAttribArray(vPosition) // 传值后激活
        // 2：纹理坐标
        mStickTextureBuffer.position(0)
        GLES20.glVertexAttribPointer(
            vCoord, 2, GLES20.GL_FLOAT, false, 0, mStickTextureBuffer
        ) // 传值
        GLES20.glEnableVertexAttribArray(vCoord) // 传值后激活

        // 片元 vTexture
        GLES20.glUniform1i(vTexture, 1) // 传递参数
        GLES20.glActiveTexture(GLES20.GL_TEXTURE1) // 激活图层
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mStickTextureID[0]) // 绑定

        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4) // 通知opengl绘制

        // 下面是解绑FBO
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0)
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0)
        GLES20.glDisable(GLES20.GL_BLEND) // 关闭混合模式
    }

    override fun release() {
        mBitmap.recycle()
        GLES20.glDeleteProgram(programId)
    }
}