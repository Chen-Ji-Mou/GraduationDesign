package com.example.graduationdesign.graduationdesign

import android.content.Context
import android.opengl.GLES20
import android.util.Log
import java.io.BufferedInputStream
import java.io.BufferedOutputStream
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import java.util.concurrent.*

object Utils {
    private const val TAG = "Utils"
    val normalThreadPool: ExecutorService = Executors.newFixedThreadPool(2)
    val scheduleThreadPool: ScheduledExecutorService = Executors.newSingleThreadScheduledExecutor()

    /**
     * 拷贝Assets文件放入Sdcard
     * @param context
     * @param fileName
     */
    fun copyAssetsToSdcard(context: Context, fileName: String): Future<Boolean> {
        return normalThreadPool.submit(Callable {
            try {
                val dir = context.externalCacheDir
                val file = File("${dir?.absolutePath}/$fileName")
                if (file.exists()) {
                    return@Callable true
                }
                // 将文件写入输入流
                val inputStream = BufferedInputStream(context.assets.open(fileName))
                val buffer = ByteArray(inputStream.available())
                inputStream.read(buffer)
                inputStream.close()
                // 将文件写入输出流
                val outputStream = BufferedOutputStream(FileOutputStream(file))
                outputStream.write(buffer)
                outputStream.flush()
                outputStream.close()
                return@Callable true
            } catch (e: Exception) {
                Log.e(TAG, "[copyAssetsToSdcard] $e")
                return@Callable false
            }
        })
    }

    /**
     * 获取浮点形缓冲数据
     * @param vertexes
     */
    fun getFloatBuffer(vertexes: FloatArray): FloatBuffer {
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

    /**
     * 生成并配置纹理
     * @param textures
     */
    fun generateTextures(textures: IntArray) {
        GLES20.glGenTextures(textures.size, textures, 0)
        for (i in textures.indices) {
            //1，绑定纹理
            // 面向过程
            // 绑定后的操作就是在该纹理上进行的
            // int target, 纹理目标
            // int texture 纹理id
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textures[i])

            //2，配置纹理
            //2.1 设置过滤参数，当纹理被使用到一个比它大或小的形状上时，opengl该如何处理
            //配合使用：min与最近点，mag 与 线性采样
            //int target,   纹理目标
            //int pname,    参数名
            //int param     参数值
            //GL_TEXTURE_MAG_FILTER 放大过滤
            GLES20.glTexParameteri(
                GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR
            )
            //GL_TEXTURE_MIN_FILTER 缩小过滤
            GLES20.glTexParameteri(
                GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST
            )

            //2.2 设置纹理环绕方向，纹理坐标0-1，如果超出范围的坐标，告诉opengl根据配置的参数进行处理
            //GL_TEXTURE_WRAP_S GL_TEXTURE_WRAP_T分别为纹理的x, y 方向
            //GL_REPEAT 重复拉伸（平铺）
            //GL_CLAMP_TO_EDGE 截取拉伸（边缘拉伸）
            GLES20.glTexParameteri(
                GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE
            )
            GLES20.glTexParameteri(
                GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE
            )

            //3，解绑纹理（传0 表示与当前纹理解绑）
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0)
        }
    }

    /**
     * 将NV21图像旋转270度
     * @param data
     * @param imageWidth
     * @param imageHeight
     */
    fun rotateNV21Degree270(data: ByteArray, imageWidth: Int, imageHeight: Int): ByteArray {
        val yuv = ByteArray(imageWidth * imageHeight * 3 / 2)
        // Rotate the Y luma
        var i = 0
        for (x in imageWidth - 1 downTo 0) {
            for (y in 0 until imageHeight) {
                yuv[i] = data[y * imageWidth + x]
                i++
            }
        } // Rotate the U and V color components
        i = imageWidth * imageHeight
        var x = imageWidth - 1
        while (x > 0) {
            for (y in 0 until imageHeight / 2) {
                yuv[i] = data[imageWidth * imageHeight + y * imageWidth + (x - 1)]
                i++
                yuv[i] = data[imageWidth * imageHeight + y * imageWidth + x]
                i++
            }
            x -= 2
        }
        return yuv
    }

    /**
     * 将NV21图像水平翻转
     * @param data
     * @param imageWidth
     * @param imageHeight
     */
    fun reverseNV21(data: ByteArray, imageWidth: Int, imageHeight: Int): ByteArray {
        val dst = ByteArray(imageWidth * imageHeight * 3 / 2)
        var index = 0
        for (y in 0 until imageHeight) for (x in 0 until imageWidth) {
            val oldX = imageWidth - 1 - x
            val oldIndex = y * imageWidth + oldX
            dst[index++] = data[oldIndex]
        }
        var y = 0
        while (y < imageHeight) {
            var x = 0
            while (x < imageWidth) {
                val oldY = y
                val oldX = imageWidth - 1 - (x + 1)
                val vuY = imageHeight + oldY / 2
                val vuIndex = vuY * imageWidth + oldX
                dst[index++] = data[vuIndex]
                dst[index++] = data[vuIndex + 1]
                x += 2
            }
            y += 2
        }
        return dst
    }
}