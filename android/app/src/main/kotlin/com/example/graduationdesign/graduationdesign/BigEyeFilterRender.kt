package com.example.graduationdesign.graduationdesign

import android.content.Context
import android.opengl.GLES20
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
    private var vMatrix = -1
    private var vTexture = -1
    private var leftEyeHandle = -1 // 左眼坐标的属性索引
    private var rightEyeHandle = -1 // 右眼坐标的属性索引
    private val mLeftEyeBuffer: FloatBuffer // 左眼的buffer
    private val mRightEyeBuffer: FloatBuffer // 右眼的buffer
    private val mVertexBuffer: FloatBuffer // 顶点坐标数据缓冲区buffer
    private val mTextureBuffer: FloatBuffer // 纹理坐标数据缓冲区buffer

    init {
        mLeftEyeBuffer =
            ByteBuffer.allocateDirect(2 * 4).order(ByteOrder.nativeOrder()).asFloatBuffer()
        mRightEyeBuffer =
            ByteBuffer.allocateDirect(2 * 4).order(ByteOrder.nativeOrder()).asFloatBuffer()

        val VERTEX = floatArrayOf(
            -1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f
        )
        mVertexBuffer = getFloatBuffer(VERTEX)

        val TEXTURE = floatArrayOf(
            0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f
        )
        mTextureBuffer = getFloatBuffer(TEXTURE)
    }

    override fun initGlFilter(context: Context?) {
        val vertexShader = GlUtil.getStringFromRaw(context, R.raw.base_vertex)
        val fragmentShader = GlUtil.getStringFromRaw(context, R.raw.bigeye_fragment)

        programId = GlUtil.createProgram(vertexShader, fragmentShader)

        vPosition = GLES20.glGetAttribLocation(programId, "vPosition")
        vCoord = GLES20.glGetAttribLocation(programId, "vCoord")
        vMatrix = GLES20.glGetUniformLocation(programId, "vMatrix")
        vTexture = GLES20.glGetUniformLocation(programId, "vTexture")
        leftEyeHandle = GLES20.glGetUniformLocation(programId, "left_eye")
        rightEyeHandle = GLES20.glGetUniformLocation(programId, "right_eye")
    }

    override fun drawFilter() {
        val faceData = mFaceTrack?.getFaceData() ?: return
        // 使用着色器程序
        GLES20.glUseProgram(programId)

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

        /*
          x = landmarks[2] / mFace.imgWidth 换算到纹理坐标0~1之间范围
          landmarks 他的相对位置是，是从C++里面得到的坐标，这个坐标是正对整个屏幕的
          但是我们要用OpenGL纹理的坐标才行，因为我们是OpenGL着色器语言代码，OpenGL纹理坐标是 0~1范围
          所以需要 / 屏幕的宽度480/高度800来得到 x/y 是等于 0~1范围
        */

        // 左眼： 的 x y 值，保存到 左眼buffer中

        /*
          x = landmarks[2] / mFace.imgWidth 换算到纹理坐标0~1之间范围
          landmarks 他的相对位置是，是从C++里面得到的坐标，这个坐标是正对整个屏幕的
          但是我们要用OpenGL纹理的坐标才行，因为我们是OpenGL着色器语言代码，OpenGL纹理坐标是 0~1范围
          所以需要 / 屏幕的宽度480/高度800来得到 x/y 是等于 0~1范围
         */

        // 左眼： 的 x y 值，保存到 左眼buffer中
        var x: Float = landmarks[2] / faceData.screenWidth
        var y: Float = landmarks[3] / faceData.screenHeight
        mLeftEyeBuffer.clear()
        mLeftEyeBuffer.put(x)
        mLeftEyeBuffer.put(y)
        mLeftEyeBuffer.position(0)
        GLES20.glUniform2fv(leftEyeHandle, 1, mLeftEyeBuffer)

        // 右眼： 的 x y 值，保存到 右眼buffer中
        x = landmarks[4] / faceData.screenWidth
        y = landmarks[5] / faceData.screenHeight
        mRightEyeBuffer.clear()
        mRightEyeBuffer.put(x)
        mRightEyeBuffer.put(y)
        mRightEyeBuffer.position(0)
        GLES20.glUniform2fv(rightEyeHandle, 1, mRightEyeBuffer)

        // 片元 vTexture
        GLES20.glUniform1i(vTexture, 4) // 传递参数
        GLES20.glActiveTexture(GLES20.GL_TEXTURE4) // 激活图层
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, previousTexId) // 绑定
    }

    override fun release() {
        GLES20.glDeleteProgram(programId)
    }

    /**
     * 获取浮点形缓冲数据
     * @param vertexes
     * @return
     */
    private fun getFloatBuffer(vertexes: FloatArray): FloatBuffer {
        val fb: FloatBuffer
        //分配一块本地内存（不受 GC 管理）
        //顶点坐标个数 * 坐标数据类型（float占4字节）
        val bb = ByteBuffer.allocateDirect(vertexes.size * 4)
        //设置使用设备硬件的本地字节序（保证数据排序一致）
        bb.order(ByteOrder.nativeOrder())
        //从ByteBuffer中创建一个浮点缓冲区
        fb = bb.asFloatBuffer()
        //写入坐标数组
        fb.put(vertexes)
        //设置默认的读取位置，从第一个坐标开始
        fb.position(0)
        return fb
    }
}