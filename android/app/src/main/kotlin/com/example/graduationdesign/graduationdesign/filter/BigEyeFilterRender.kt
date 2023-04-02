package com.example.graduationdesign.graduationdesign.filter

import android.content.Context
import android.opengl.GLES20
import com.example.graduationdesign.graduationdesign.R
import com.example.graduationdesign.graduationdesign.Utils
import com.example.graduationdesign.graduationdesign.track.FaceTrack
import com.pedro.encoder.input.gl.render.filters.BaseFilterRender
import com.pedro.encoder.utils.gl.GlUtil
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer

class BigEyeFilterRender(private val mFaceTrack: FaceTrack?) : BaseFilterRender() {
    private var programId = -1
    private var vPosition = -1
    private var vCoord = -1
    private var vTexture = -1
    private var leftEyeHandle = -1 // 左眼坐标的属性索引
    private var rightEyeHandle = -1 // 右眼坐标的属性索引
    private val mLeftEyeBuffer: FloatBuffer =
        ByteBuffer.allocateDirect(2 * 4).order(ByteOrder.nativeOrder()).asFloatBuffer() // 左眼的buffer
    private val mRightEyeBuffer: FloatBuffer =
        ByteBuffer.allocateDirect(2 * 4).order(ByteOrder.nativeOrder()).asFloatBuffer() // 右眼的buffer
    private val mVertexBuffer: FloatBuffer // 顶点坐标数据缓冲区buffer
    private val mTextureBuffer: FloatBuffer // 纹理坐标数据缓冲区buffer

    init {
        val vertex = floatArrayOf(-1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f)
        mVertexBuffer = Utils.getFloatBuffer(vertex)
        val texture = floatArrayOf(0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f)
        mTextureBuffer = Utils.getFloatBuffer(texture)
    }

    override fun initGlFilter(context: Context?) {
        val vertexShader = GlUtil.getStringFromRaw(context, R.raw.base_vertex)
        val fragmentShader = GlUtil.getStringFromRaw(context, R.raw.bigeye_fragment)

        programId = GlUtil.createProgram(vertexShader, fragmentShader)

        vPosition = GLES20.glGetAttribLocation(programId, "vPosition")
        vCoord = GLES20.glGetAttribLocation(programId, "vCoord")
        vTexture = GLES20.glGetUniformLocation(programId, "vTexture")
        leftEyeHandle = GLES20.glGetUniformLocation(programId, "left_eye")
        rightEyeHandle = GLES20.glGetUniformLocation(programId, "right_eye")
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

        // 传眼睛坐标给着色器
        val landmarks: FloatArray = faceData.landMarks

        // opengl的渲染坐标系是以左下角为原点，右为x轴的正方向，上为y轴的正方向 (数值范围0~1)

        // 左眼： 的 x y 值，保存到 左眼buffer中
        var x: Float = landmarks[2] / faceData.screenWidth
        var y: Float = 1 - landmarks[3] / faceData.screenHeight
        mLeftEyeBuffer.clear()
        mLeftEyeBuffer.put(x)
        mLeftEyeBuffer.put(y)
        mLeftEyeBuffer.position(0)
        GLES20.glUniform2fv(leftEyeHandle, 1, mLeftEyeBuffer)

        // 右眼： 的 x y 值，保存到 右眼buffer中
        x = landmarks[4] / faceData.screenWidth
        y = 1 - landmarks[5] / faceData.screenHeight
        mRightEyeBuffer.clear()
        mRightEyeBuffer.put(x)
        mRightEyeBuffer.put(y)
        mRightEyeBuffer.position(0)
        GLES20.glUniform2fv(rightEyeHandle, 1, mRightEyeBuffer)

        // 片元 vTexture
        GLES20.glUniform1i(vTexture, 0) // 传递参数
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0) // 激活图层
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, previousTexId) // 绑定

        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4) // 通知opengl绘制

        // 解绑fbo
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0)
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0)
    }

    override fun release() {
        GLES20.glDeleteProgram(programId)
    }
}