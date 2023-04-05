package com.example.graduationdesign.graduationdesign

import android.content.Context
import android.graphics.SurfaceTexture
import android.hardware.Camera
import android.view.SurfaceView
import android.view.TextureView
import com.pedro.encoder.input.video.Camera1ApiManager
import com.pedro.encoder.input.video.GetCameraData

class Camera1ApiManagerProxy : Camera1ApiManager {
    constructor(surfaceView: SurfaceView, getCameraData: GetCameraData) : super(
        surfaceView, getCameraData
    )

    constructor(textureView: TextureView, getCameraData: GetCameraData) : super(
        textureView, getCameraData
    )

    constructor(surfaceTexture: SurfaceTexture?, context: Context?) : super(surfaceTexture, context)

    private var callback: PreviewCallback? = null

    override fun onPreviewFrame(data: ByteArray, camera: Camera) {
        callback?.onPreviewFrame(data, camera)
    }

    fun addPreviewCallback(callback: PreviewCallback) {
        this.callback = callback
    }

    interface PreviewCallback {
        fun onPreviewFrame(data: ByteArray, camera: Camera)
    }
}