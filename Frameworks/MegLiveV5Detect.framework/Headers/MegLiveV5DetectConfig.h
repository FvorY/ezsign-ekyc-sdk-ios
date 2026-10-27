//
//  MegLiveV5DetectConfig.h
//  MegLiveV5Detect
//
//  Created by MegviiDev on 2024/2/16.
//

#ifndef MegLiveV5DetectConfig_h
#define MegLiveV5DetectConfig_h

@class MegLiveV5DetectError;

//  活体检测集成方式，默认值为为`MegLiveV5DetectModel_A`
typedef enum : NSUInteger {
    MegLiveV5DetectModel_A           =  1,  //  默认集成方式，在SDK内部通过网络请求进行授权和活体配置的获取，需要配合指定的`hostURL`参数使用。
    MegLiveV5DetectModel_C           =  3,  //  兼容性集成方式，在SDK内部通过网络请求仅进行授权，活体配置需要用户主动传入，需要配合指定的`hostURL`和`configInfo`参数使用。
} MegLiveV5DetectModel;

//  活体检测语言类型，默认值为`MegLiveV5DetectLanguageTypeCh`
typedef enum : NSUInteger {
    MegLiveV5DetectLanguageTypeCh           =  0,  //  中文
} MegLiveV5DetectLanguageType;

//  活体检测设备垂直检测类型，默认值为`MegLiveV5DetectPhoneVerticalTypeDisable`
typedef enum : NSUInteger {
    MegLiveV5DetectPhoneVerticalTypeContinue          =  1,  //  启用设备垂直检测
    MegLiveV5DetectPhoneVerticalTypeFront2            =  2,  //  仅在检测开启的2秒内启用，之后关闭该功能
    MegLiveV5DetectPhoneVerticalTypeDisable           =  3,  //  禁用设备垂直检测
} MegLiveV5DetectPhoneVerticalType;

//  活体检测提示UI效果类型，默认值为`MegLiveV5DetectRemindUITypeDefault`
typedef enum : NSUInteger {
    MegLiveV5DetectRemindUITypeDefault                =  0,  //  提示效果一行模式
    MegLiveV5DetectRemindUITypeMultipleLine           =  1,  //  提示效果多行模式，最多支持三行
} MegLiveV5DetectRemindUIType;

//  活体检测错误类型
typedef enum : NSUInteger {
    MegLiveV5DetectErrorTypeOK                                = 1000,
    MegLiveV5DetectErrorTypeBizTokenDenied                    = 1001,
    MegLiveV5DetectErrorTypeIllegalParameter                  = 1002,
    MegLiveV5DetectErrorTypeAuthenticationFail                = 1003,
    MegLiveV5DetectErrorTypeMobileNotSupport                  = 1004,
    MegLiveV5DetectErrorTypeNullPointException                = 1005,
    MegLiveV5DetectErrorTypeRequestFrequently                 = 1006,
    MegLiveV5DetectErrorTypeNetworkTimeout                    = 1007,
    MegLiveV5DetectErrorTypeInternalError                     = 1008,
    MegLiveV5DetectErrorTypeInvalidBundleID                   = 1009,
    MegLiveV5DetectErrorTypeNetworkError                      = 1010,
    MegLiveV5DetectErrorTypeUserCancel                        = 1011,
    MegLiveV5DetectErrorTypeNoCameraPermission                = 1012,
    MegLiveV5DetectErrorTypeNoCameraSupport                   = 1013,
    MegLiveV5DetectErrorTypeFaceInitFail                      = 1014,
    MegLiveV5DetectErrorTypeLivenessFailure                   = 1016,
    MegLiveV5DetectErrorTypeGotoBackground                    = 1017,
    MegLiveV5DetectErrorTypeLivenessTimeout                   = 1018,
    MegLiveV5DetectErrorTypeDataUploadFail                    = 1019,
    MegLiveV5DetectErrorTypeNFCUserQuit                       = 1020,
    MegLiveV5DetectErrorTypeNFCSystemQuit                     = 1021,
    MegLiveV5DetectErrorTypeScreenNoSupport                   = 1022,
    MegLiveV5DetectErrorTypeScreenNoPermission                = 1023,
    MegLiveV5DetectErrorTypeScreenRecordFail                  = 1024,
    MegLiveV5DetectErrorTypeScreenWriteFail                   = 1025,
} MegLiveV5DetectErrorType;

/**
 FaceID活体检测配置接口管理器加载状态Block。
 */
typedef void(^MegLiveV5StartDetectBlock)(MegLiveV5DetectError* error, NSDictionary* extraOutDict);

/**
 FaceID活体检测配置接口检测完成时Block。该阶段，仅代表检测完成，进行数据回传。检测页面未开始收起。
 */
typedef void(^MegLiveV5EndDetectBlock)(MegLiveV5DetectError* error, NSString* bizTokenStr, NSDictionary* extraOutDict);

/**
 FaceID活体检测配置接口页面收起完成时Block。
 */
typedef void(^MegLiveV5DismissBlock)(void);

#endif /* MegLiveV5DetectConfig_h */
