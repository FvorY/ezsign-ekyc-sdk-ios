//
//  MGFaceIDCameraManager.h
//  MGFaceIDBaseKit
//
//  Created by MegviiDev on 2019/1/29.
//  Copyright © 2019 Megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MGCameraDelegate.h"

NS_ASSUME_NONNULL_BEGIN

//  该参数仅在后置多摄设备上有效。前置或者非多摄设备默认使用主摄像头`MGFaceIDCameraDeviceTypeNormal`
typedef enum : NSUInteger {
    MGFaceIDCameraDeviceTypeNormal,                 //  默认主摄，一般为广角摄像头
    MGFaceIDCameraDeviceTypeTelephoto,              //  长焦摄像头
    MGFaceIDCameraDeviceTypeWAndT,                  //  广角和长焦，双摄自动切换
    MGFaceIDCameraDeviceTypeUltraWide,              //  超广角摄像头
    MGFaceIDCameraDeviceTypeWAndUW,                 //  广角和超广角，双摄自动切换
} MGFaceIDCameraDeviceType;

@interface MGFaceIDCameraManager : NSObject

@property (nonatomic, weak) id <MGCameraDelegate> delegate;
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

+ (instancetype)videoPreset:(NSString *)sessionPreset
             devicePosition:(AVCaptureDevicePosition)devicePosition
                videoRecord:(BOOL)isRecordVideo
                 videoSound:(BOOL)isRecordAudio;

+ (instancetype)videoPreset:(NSString *)sessionPreset
             devicePosition:(AVCaptureDevicePosition)devicePosition
                 deviceType:(MGFaceIDCameraDeviceType)deviceType
                videoRecord:(BOOL)isRecordVideo
                 videoSound:(BOOL)isRecordAudio;

/**
 视频流的预览layer

 @return 视频流预览图
 */
- (AVCaptureVideoPreviewLayer *)videoPreview;

/**
 重置相机白平衡
 */
- (void)resetWhiteBalance:(float)value;


- (void)changeManualExposureWithISO:(BOOL)isMagnify adjustV:(int)adjustISO;

/**
 重置相机曝光策略
 */
- (void)resetWhiteAutoExposure;

/**
 开启摄像机
 */
- (void)startRunning;

/**
 关闭摄像机。同时取消可能存在的录制
 */
- (void)stopRunning;
/**
 关闭摄像机。不取消可能存在的录制
 */
- (void)stopRunningWithOnlySession;

/**
 设置视频录制质量。取值范围为(0, 1]。其中值越大，质量越高。
 */
- (void)setRecordQuality:(float)quality;

/**
 开始录像
 */
- (void)startRecording;

/**
 停止录像
 */
- (void)stopRceording;

/**
 重置录像，丢弃之前已录制文件
 */
- (void)resetRceording;

/**
 自定义录像视频文件名称

 @param videoName 文件名称，后缀为`.mov`
 */
- (void)cameraVideoRecordName:(NSString *)videoName;

/**
 自定义录像视频帧率。该参数为近似值，录制的视频帧率可能和设置的FPS有差异。

 @param videoFPS 视频帧率，阈值范围[0, 33]，其中0表示使用默认帧率。
 */
- (void)cameraVideoRecordFPS:(NSUInteger)videoFPS;

/**
 自定义录制配置-是否手动添加Buffer数据，默认为NO，不手动添加
 如果配置该参数为YES，需要主动调用`-cameraVideoRecordWithSampleBuffer:connection:`接口传入sambuffer数据，SDK不在进行摄像头数据录制操作。

 @param isManualInput 是否手动添加
 */
- (void)cameraVideoRecordManualInput:(BOOL)isManualInput;

/**
 自定义录像视频分辨率。一般情况下应该小于等于设置的相机分辨率。

 @param width  录像视频宽度
 @param height 录像视频高度
 */
- (void)cameraVideoRecordPixelWithWidth:(int)width height:(int)height;

/**
 录制视频过程中手动添加Buffer数据。手动添加数据可能导致FPS低于期望值

 @param sampleBuffer Buffer数据
 @param connection 连接器信息
 */
- (void)cameraVideoRecordWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
                               connection:(AVCaptureConnection *)connection;

/**
 切换分辨率，使用captureStillImage拍照获取一张图片信息。
 会先停止当前已开启session。拍摄获取到的图片通过delegate`mgCaptureTakePhoto:`获取。
 
 @param photoSessionPreset 指定分辨率
 */
- (void)cameraTakePhotoWithSessionPreset:(NSString *)photoSessionPreset;

/**
 切换分辨率，使用视频帧编码获取一张图片信息。
 会先停止当前已开启session。获取到的图片通过delegate`mgCaptureTakePhoto:`获取。
 
 @param frameSessionPreset 指定分辨率
 @param delayFrame 指定编码帧。session启动后指定帧数。默认情况下，单帧间隔33毫秒。
 */
- (void)cameraFramePhotoWithSessionPreset:(NSString *)frameSessionPreset delayFrame:(NSUInteger)delayFrame;

/**
 获取SDK版本信息

 @return SDK版本号
 */
+ (NSString *)getSDKVersion;

@end

NS_ASSUME_NONNULL_END
