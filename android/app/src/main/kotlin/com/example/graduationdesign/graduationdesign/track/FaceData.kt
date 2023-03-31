package com.example.graduationdesign.graduationdesign.track

/**
 * 人脸的JavaBean，封装了人脸的信息集
 */
class FaceData(
    // 保存人脸框 的宽度
    var faceWidth: Int,
    // 保存人脸框 的高度
    var faceHeight: Int,
    // 送去检测的屏幕宽度
    var screenWidth: Int,
    // 送去检测的屏幕高度
    var screenHeight: Int,
    /**
     * 人脸框的x和y，不等于 width，height，所以还是单独定义算了（没啥关联）
     * float[] landmarks 细化后如下：12个元素
     * 0下标（保存：人脸框的 x）
     * 1下标（保存：人脸框的 y）
     *
     * 2下标（保存：左眼x）
     * 3下标（保存：左眼y）
     *
     * 4下标（保存：右眼x）‘
     * 5下标（保存：右眼y）
     *
     * 6下标（保存：鼻尖x）
     * 7下标（保存：鼻尖y）
     *
     * 7下标（保存：左边嘴角x）
     * 8下标（保存：左边嘴角y）
     *
     * 9下标（保存：右边嘴角x）
     * 10下标（保存：右边嘴角y）
     */
    var landMarks: FloatArray
) {
    override fun toString(): String {
        return "Face{" +
                "landmarks=" + landMarks.contentToString() +
                ", width=" + faceWidth +
                ", height=" + faceHeight +
                ", imgWidth=" + screenWidth +
                ", imgHeight=" + screenHeight +
                '}'
    }
}