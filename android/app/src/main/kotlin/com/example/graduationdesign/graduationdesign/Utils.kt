package com.example.graduationdesign.graduationdesign

import android.content.Context
import android.os.Environment
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.Executors

object Utils {
    private const val TAG = "Utils"
    private val threadPool = Executors.newSingleThreadExecutor()

    fun sp2px(context: Context, spValue: Int): Float {
        val fontScale = context.resources.displayMetrics.scaledDensity
        return spValue * fontScale + 0.5f
    }

    fun copyAssetsToSdcard(context: Context, fileName: String) {
        threadPool.execute {
            try {
                val dir =
                    Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                val file = File("${dir.absolutePath}/$fileName")
                if (file.exists()) {
                    return@execute
                }
                val inputStream = context.assets.open(fileName)
                val outputStream = FileOutputStream(file)
                val buffer = ByteArray(1024)
                var byteCount: Int
                do {
                    byteCount = inputStream.read(buffer)
                    if (byteCount != -1) {
                        outputStream.write(buffer, 0, byteCount)
                    }
                } while (byteCount != -1)
                outputStream.flush()
                inputStream.close()
                outputStream.close()
            } catch (e: Exception) {
                Log.e(TAG, "[copyAssetsToDst] ${e.message}")
            }
        }
    }
}