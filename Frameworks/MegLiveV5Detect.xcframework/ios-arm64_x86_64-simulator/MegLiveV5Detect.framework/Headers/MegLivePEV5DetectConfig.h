//
//  MegLivePEV5DetectConfig.h
//  MegLiveV5Detect
//
//  Created by MegviiDev on 2024/2/16.
//

#ifndef MegLivePEV5DetectConfig_h
#define MegLivePEV5DetectConfig_h
@class MegLivePEV5DetectError;

//  活体检测集成方式，默认值为`MegLivePEV5DetectModel_A`
typedef enum : NSUInteger {
    MegLivePEV5DetectModel_A           =  1,  //  默认集成方式，在SDK内部进行配置的网络请求。需要配合指定HostURL使用
    MegLivePEV5DetectModel_B           =  2,  //  集成方式B。SDK内部将请求配置的数据传给客户，客户进行网络请求后将配置数据回传给SDK
} MegLivePEV5DetectModel;

//  活体检测语言类型，默认值为`MegLivePEV5DetectLanguageTypeCh`
typedef enum : NSUInteger {
    MegLivePEV5DetectLanguageTypeCh           =  0,  //  中文
    MegLivePEV5DetectLanguageTypeEn           =  1,  //  英文
} MegLivePEV5DetectLanguageType;

//  活体检测设备垂直检测类型，默认值为`MegLivePEV5DetectPhoneVerticalTypeDisable`
typedef enum : NSUInteger {
    MegLivePEV5DetectPhoneVerticalTypeContinue          =  1,  //  启用设备垂直检测
    MegLivePEV5DetectPhoneVerticalTypeFront2            =  2,  //  仅在检测开启的2秒内启用，之后关闭该功能
    MegLivePEV5DetectPhoneVerticalTypeDisable           =  3,  //  禁用设备垂直检测
} MegLivePEV5DetectPhoneVerticalType;

//  活体检测提示UI效果类型，默认值为`MegLivePEV5DetectRemindUITypeDefault`
typedef enum : NSUInteger {
    MegLivePEV5DetectRemindUITypeDefault                =  0,  //  提示效果一行模式
    MegLivePEV5DetectRemindUITypeMultipleLine           =  1,  //  提示效果多行模式，最多支持三行
} MegLivePEV5DetectRemindUIType;

//  活体检测错误类型
typedef enum : NSUInteger {
    MegLivePEV5DetectErrorTypeOK                                = 1000,
    MegLivePEV5DetectErrorTypeBizTokenDenied                    = 1001,
    MegLivePEV5DetectErrorTypeIllegalParameter                  = 1002,
    MegLivePEV5DetectErrorTypeAuthenticationFail                = 1003,
    MegLivePEV5DetectErrorTypeMobileNotSupport                  = 1004,
    MegLivePEV5DetectErrorTypeNullPointException                = 1005,
    MegLivePEV5DetectErrorTypeRequestFrequently                 = 1006,
    MegLivePEV5DetectErrorTypeNetworkTimeout                    = 1007,
    MegLivePEV5DetectErrorTypeInternalError                     = 1008,
    MegLivePEV5DetectErrorTypeInvalidBundleID                   = 1009,
    MegLivePEV5DetectErrorTypeNetworkError                      = 1010,
    MegLivePEV5DetectErrorTypeUserCancel                        = 1011,
    MegLivePEV5DetectErrorTypeNoCameraPermission                = 1012,
    MegLivePEV5DetectErrorTypeNoCameraSupport                   = 1013,
    MegLivePEV5DetectErrorTypeFaceInitFail                      = 1014,
    MegLivePEV5DetectErrorTypeLivenessFailure                   = 1016,
    MegLivePEV5DetectErrorTypeGotoBackground                    = 1017,
    MegLivePEV5DetectErrorTypeLivenessTimeout                   = 1018,
    MegLivePEV5DetectErrorTypeDataUploadFail                    = 1019,
    MegLivePEV5DetectErrorTypeNFCUserQuit                       = 1020,
    MegLivePEV5DetectErrorTypeNFCSystemQuit                     = 1021,
    MegLivePEV5DetectErrorTypeScreenNoSupport                   = 1022,
    MegLivePEV5DetectErrorTypeScreenNoPermission                = 1023,
    MegLivePEV5DetectErrorTypeScreenRecordFail                  = 1024,
    MegLivePEV5DetectErrorTypeScreenWriteFail                   = 1025,
} MegLivePEV5DetectErrorType;

/**
 FaceID活体检测配置接口管理器加载状态Block。
 */
typedef void(^MegLivePEV5StartDetectBlock)(MegLivePEV5DetectError* error, NSDictionary* extraOutDict);
/**
 FaceID活体检测配置接口检测完成时Block。该阶段，仅代表检测完成，进行数据回传。检测页面未开始收起。
 */
typedef void(^MegLivePEV5EndDetectBlock)(MegLivePEV5DetectError* error, NSString* bizTokenStr, NSData* deltaData, NSDictionary* extraOutDict);
/**
 FaceID活体检测配置接口页面收起完成时Block。
 */
typedef void(^MegLivePEV5DismissBlock)(void);

/**
 FaceID活体检测配置接口响应Block。该参数仅在集成方案B时有效。请在默认线程或者非主线程中调用该block。回到主线程中调用该block，会导致网络卡顿，直到超时。
 */
typedef void(^MegLivePEV5ConfigResponseBlock)(NSDictionary* responseDict);

/**
 FaceID活体检测配置接口请求Block。该参数仅在集成方案B时有效。该block内部为子线程。如果需要进行UI操作，请手动回到主线程。
 */
typedef void(^MegLivePEV5ConfigBlock)(NSString* bizToken, NSDictionary* requestDict, MegLivePEV5ConfigResponseBlock responseBlock);


#endif /* MegLivePEV5DetectConfig_h */
