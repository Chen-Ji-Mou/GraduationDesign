#include <jni.h>
#include <string>
#include <opencv2/imgproc/types_c.h>
#include <android/log.h>
#include "FaceTrack.h"

// point_detector 人脸关键点模型 关联起来

/**
 * 初始化工作
 * @param env
 * @param thiz
 * @param model_   OpenCV人脸模型
 * @param seeta_   中科院关键点的模型
 * @return         FaceTrack.cpp的long值
 */
extern "C"
JNIEXPORT jlong JNICALL
Java_com_example_graduationdesign_graduationdesign_track_FaceTrack_native_1create(JNIEnv *env,
                                                                                  jobject thiz,
                                                                                  jstring model_,
                                                                                  jstring seeta_) {
    const char *model = env->GetStringUTFChars(model_, nullptr);
    const char *seeta = env->GetStringUTFChars(seeta_, nullptr);

    auto *faceTrack = new FaceTrack(model, seeta);

    env->ReleaseStringUTFChars(model_, model);
    env->ReleaseStringUTFChars(seeta_, seeta);
    return reinterpret_cast<jlong>(faceTrack);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_graduationdesign_graduationdesign_track_FaceTrack_native_1start(JNIEnv *env,
                                                                                 jobject thiz,
                                                                                 jlong self) {
    if (self == 0) {
        return;
    }
    auto *faceTrack = reinterpret_cast<FaceTrack *>(self);
    faceTrack->startTracking();
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_graduationdesign_graduationdesign_track_FaceTrack_native_1stop(JNIEnv *env,
                                                                                jobject thiz,
                                                                                jlong self) {
    if (self == 0) {
        return;
    }
    auto *faceTrack = reinterpret_cast<FaceTrack *>(self);
    faceTrack->stopTracking();
    delete faceTrack;
}

extern "C"
JNIEXPORT jobject JNICALL
Java_com_example_graduationdesign_graduationdesign_track_FaceTrack_native_1detector(JNIEnv *env,
                                                                                    jobject thiz,
                                                                                    jlong self,
                                                                                    jbyteArray data_,
                                                                                    jint camera_id,
                                                                                    jint width,
                                                                                    jint height) {
    if (self == 0) {
        return nullptr;
    }

    jbyte *data = env->GetByteArrayElements(data_, nullptr);
    auto *faceTrack = reinterpret_cast<FaceTrack *>(self); // 通过地址反转CPP对象

    // OpenCV旋转数据操作
    Mat src(height + height / 2, width, CV_8UC1, data); // 摄像头数据data 转成 OpenCv的 Mat
    imwrite("/sdcard/Android/data/com.example.graduationdesign.graduationdesign/cache/camera.jpg",
            src); // 做调试的时候用的（方便查看：有没有摆正，有没有灰度化 等）
    cvtColor(src, src, CV_YUV2RGBA_NV21); // 把YUV转成RGBA
    if (camera_id == 1) { // 前摄
        rotate(src, src, ROTATE_90_COUNTERCLOCKWISE); // 逆时针90度
        flip(src, src, 1); // y 轴 翻转（镜像操作）
    } else {  // 后摄
        rotate(src, src, ROTATE_90_CLOCKWISE);
    }

    // OpenCV基础操作
    cvtColor(src, src, COLOR_RGBA2GRAY); // 灰度化
    equalizeHist(src, src); // 均衡化处理（直方图均衡化，增强对比效果）
    vector<Rect2f> rects;
    faceTrack->detector(src, rects); // 送去定位，要去做人脸的检测跟踪了
    env->ReleaseByteArrayElements(data_, data, 0);

    // rects 他已经有丰富的人脸框框的信息，接下来就是，关键点定位封装操作Face.java

    // TODO 注意：上面的代码执行完成后，就拿到了 人脸检测的成果 放置在rects中

    // C++ 反射 实例化 Face.java 并且保证 Face.java有值

    int imgWidth = src.cols; // 构建 Face.java的 int imgWidth; 送去检测图片的宽
    int imgHeight = src.rows; // 构建 Face.java的 int imgHeight; 送去检测图片的高
    int ret = rects.size(); // 如果有一个人脸，那么size肯定大于0
    if (ret) { // 注意：有人脸，才会进if
        jclass clazz = env->FindClass(
                "com/example/graduationdesign/graduationdesign/track/FaceData");
        jmethodID construct = env->GetMethodID(clazz, "<init>", "(IIII[F)V");
        // int width, int height,int imgWidth,int imgHeight, float[] landmark
        int size = ret * 2; // 乘以2是因为，有x与y， 其实size===2，因为rects就一个人脸

        // 构建 Face.java的 float[] landmarks;
        jfloatArray floatArray = env->NewFloatArray(size);
        for (int i = 0, j = 0; i < size; ++j) {  // 前两个就是人脸的x与y
            float f[2] = {rects[j].x, rects[j].y};
            env->SetFloatArrayRegion(floatArray, i, 2, f);
            i += 2;
        }
        Rect2f faceRect = rects[0];
        int faceWidth = faceRect.width; // 构建 Face.java的 int width; 保存人脸的宽
        int faceHeight = faceRect.height; // 构建 Face.java的 int height; 保存人脸的高
        // 实例化Face.java对象，都是前面JNI课程的基础
        jobject face = env->NewObject(clazz, construct, faceWidth, faceHeight, imgWidth, imgHeight,
                                      floatArray);
        rectangle(src, faceRect, Scalar(0, 0, 255)); // OpenCV内容，你们之前学过的
        for (int i = 1; i < ret; ++i) { // OpenCV内容，你们之前学过的
            circle(src, Point2f(rects[i].x, rects[i].y), 5, Scalar(0, 255, 0));
        }
        imwrite("/sdcard/Android/data/com.example.graduationdesign.graduationdesign/cache/result.jpg",
                src); // 做调试的时候用的（方便查看：有没有摆正，有没有灰度化 等）
        return face; // 返回 jobject == Face.java（已经有值了，有人脸所有的信息了，那么就可以开心，放大眼睛）
    }
    src.release(); // Mat释放工作
    return nullptr;
}