package com.example.graduationdesign.graduationdesign

import android.content.Context

class Utils {
    companion object {
        fun sp2px(context: Context, spValue: Int): Float {
            val fontScale = context.resources.displayMetrics.scaledDensity
            return spValue * fontScale + 0.5f
        }
    }
}