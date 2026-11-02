//
//  MegLivePEV5DetectItem.h
//  MegLiveV5Detect
//
//  Created by MegviiDev on 2021/10/15.
//

#import <UIKit/UIKit.h>
#import <MegLiveV5Detect/MegLivePEV5DetectConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface MegLivePEV5DetectUIConfigItem : NSObject

@property (nonatomic, assign) MegLivePEV5DetectRemindUIType remindUIType;               //  提示UI效果类型。默认类型为`MegLivePEV5DetectRemindUITypeDefault`
@property (nonatomic, strong) UIColor* livenessHomeNormalRemindTextColor;               //  提示文字颜色正常状态，默认颜色为0x292929。
@property (nonatomic, strong) UIColor* livenessHomeDeviceVerticalRemindColor;           //  手机竖向垂直提示字体颜色，默认颜色为0xFFFFFF。仅remindUIType==MegLivePEV5DetectRemindUITypeDefault时生效
@property (nonatomic, strong) UIColor* livenessHomeMultipleLineDeviceVerticalRemindColor;           //  多行效果子下手机竖向垂直提示字体颜色，默认颜色为0x292929。仅remindUIType==MegLivePEV5DetectRemindUITypeMultipleLine时生效
@property (nonatomic, strong) UIColor* livenessHomeProcessBarColor;                     //  活体阶段进度条颜色，仅动作活体模式和炫彩不打光模式，距离活体照镜子模式生效，默认颜色为0x267CE0。炫彩打光模式不生效
@property (nonatomic, strong) UIColor* livenessHomeBackgroundColor1;                    //  主题上部圆圈颜色，默认颜色为0x79DDF0
@property (nonatomic, strong) UIColor* livenessHomeBackgroundColor2;                    //  主题下部圆圈颜色，默认颜色为0x0678FC
@property (nonatomic, strong) UIColor* livenessHomeActionHatColor;                      //  动作活体过程中顶部阴影颜色，默认颜色为0x0678FC
@property (nonatomic, strong) UIColor* livenessHomeCheckingLineStartColor;                    //  验证阶段进度条颜色，渐变色。默认开始颜色为0x267CE0
@property (nonatomic, strong) UIColor* livenessHomeCheckingLineEndColor;                      //  验证阶段进度条颜色，渐变色。默认结束颜色为0xFFFFFF
@property (nonatomic, strong) UIColor* livenessHomeActionLineDoingColor;					  //  灵动活体动作阶段未完成时线条状态颜色。默认颜色为0xD8D8D8
@property (nonatomic, strong) UIColor* livenessHomeActionLineDoneColor;						  //  灵动活体动作阶段已完成时线条状态颜色。默认颜色为0x267CE0

//  退出提示框
@property (nonatomic, assign) CGFloat livenessHomeExitPopupwindowTextSize;              //  退出弹窗标题字号。默认字号为17号
@property (nonatomic, assign) CGFloat livenessHomeExitPopupwindowBodySize;              //  退出弹窗正文字号。默认字号为13号
@property (nonatomic, strong) UIColor* livenessHomeConfirmButtonColor;                  //  确认按钮颜色。默认颜色为0x000000
@property (nonatomic, strong) UIColor* livenessHomeCancelButtonColor;                   //  取消按钮颜色。默认颜色为0x000000

//  协议页面
@property (nonatomic, assign) CGFloat livenessHomeAgreementpageTitleTextSize;                    //  协议页面顶部标题字体大小。默认字号为26号
@property (nonatomic, assign) CGFloat livenessHomeAgreementpageBottomTitleTextSize;              //  协议页面底部提示字体大小。默认字号为14号
@property (nonatomic, strong) UIColor* livenessHomeAgreementpageBottomButtonBeforeClickColor;                  //  协议页面按钮正常态。默认颜色为0x3B94FC
@property (nonatomic, strong) UIColor* livenessHomeAgreementpageBottomButtonAfterClickColor;                   //  协议页面按钮高亮态度。默认颜色为0x267CE0

//  顶部提示
@property (nonatomic, strong) UIColor* livenessHomeCustomPromptBackgroundColor;         //  活体界面全局提示背景颜色。默认颜色为0xFDEBEB
@property (nonatomic, strong) UIColor* livenessHomeCustomPromptTextColor;               //  活体界面全局提示字体颜色。默认颜色为0xDA3130
@property (nonatomic, strong) UIColor* livenessCustomPromptColor;                       //  活体界面确认模式提示字体颜色。默认颜色为0xD3463E

@end

@interface MegLivePEV5DetectLivenessConfigItem : NSObject
//  该对象的所有参数，不设置的情况下使用默认值。设置范围外的错误结果，该设置无效，使用默认值。

@property (nonatomic, strong) NSString* livenessType;                               //  指定活体方式。目前仅支持"meglive","flash","initiative_flash","distance_flash"
//  当活体方式为"meglive"时有效
@property (nonatomic, assign) NSInteger actionLivenessTimeout;                      //  动作活体超时时间，单位为秒。取值范围为(0,60]
@property (nonatomic, assign) NSInteger actionLivenessCount;                        //  动作活体动作个数。取值范围为[1,4]
@property (nonatomic, strong) NSArray<NSNumber *>* actionLiveTypeList;              //  动作活体动作阶段动作序列，形如@[@1, @3]指定具体的动作列表。如果同时设置该值和`actionLivenessCount`。请确保该序列count和`actionLivenessCount`一致。

//  当活体方式为"flash","initiative_flash","distance_flash"时有效
@property (nonatomic, assign) BOOL flashLivenessIsDoLight;                          //  炫彩阶段打光设置，默认为YES。其中YES为打光，NO为不打光。
//  当活体方式为"flash"时有效
@property (nonatomic, assign) NSInteger flashLivenessTimeout;                       //  炫彩活体超时时间，单位为秒。取值范围为(0,180]
@property (nonatomic, assign) NSInteger flashLivenessColorCount;                    //  炫彩活体颜色个数。取值范围为[4,8]
//  当活体方式为"initiative_flash"时有效
@property (nonatomic, assign) NSInteger initiativeActionType  __deprecated_msg("Use 'initiativeActionTypeList'");           //  动作类型。其中1为眨眼，2为张嘴，3为摇头，4为点头。已弃用。
@property (nonatomic, assign) NSInteger initiativeActionTimeout;                    //  灵动活体动作阶段超时时间，单位为秒。取值范围为(0,60]
@property (nonatomic, assign) NSInteger initiativeFlashColor;                       //  灵动活体炫彩阶段打光颜色个数，取值范围为[4,8]
@property (nonatomic, assign) NSInteger initiativeFlashTimeout;                     //  灵动活体炫彩阶段超时时间，单位为秒。取值范围为(0,180]
@property (nonatomic, assign) NSInteger initiativeActionCount;                      //  灵动活体动作阶段动作个数。默认为1。取值范围为[1,4]
@property (nonatomic, strong) NSArray<NSNumber *>* initiativeActionTypeList;        //  灵动活体动作阶段动作序列，形如@[@1, @3]指定具体的动作列表。如果同时设置该值和`initiativeActionCount`。请确保该序列count和`initiativeActionCount`一致。

//  当活体方式为"distance_flash"时有效
@property (nonatomic, assign) NSInteger distanceMoveTimeout;                        //  移动阶段超时时间，单位为秒。默认为60。取值范围为(0,180]
@property (nonatomic, assign) NSInteger distanceFlashColor;                         //  炫彩阶段打光颜色个数，默认为4。取值范围为[4,8]
@property (nonatomic, assign) NSInteger distanceFlashTimeout;                       //  炫彩阶段超时时间，单位为秒，默认为120。取值范围为(0,180]

@end

@interface MegLivePEV5DetectInitConfigItem : NSObject

//  指定FaceIDV5SDK语言类型，关于SDK语言资源加载的方式，详情见文档。必需
@property (nonatomic, assign) MegLivePEV5DetectLanguageType languageType;
//  指定FaceIDV5SDK拉取配置的方案，默认为MegLivePEV5DetectModel_A。必需
@property (nonatomic, assign) MegLivePEV5DetectModel model;
//  指定FaceIDV5SDK拉取配置的HOST地址。当model为MegLivePEV5DetectModel_A时必需。
@property (nonatomic, strong) NSString* hostURL;

//  指定活体方式。非必需
@property (nonatomic, strong) MegLivePEV5DetectLivenessConfigItem* livenessConfig;
//  指定活体V5的UI样式。非必需
@property (nonatomic, strong) MegLivePEV5DetectUIConfigItem* customUI;
//  指定活体V5SDK资源绝对路径，以'bundle'为结尾。如果该值为nil或者""，则从MainBundle中读取资源。关于资源加载的方式，详情见文档。非必需
@property (nonatomic, strong) NSString* bundleFilePath;
//  指定活体检测过程中设备垂直检测类型。默认为`MegLivePEV5DetectPhoneVerticalTypeDisable`。非必需
@property (nonatomic, assign) MegLivePEV5DetectPhoneVerticalType phoneVertical;
//  是否进行音量调节。其中YES为开启，NO为不开启。开启后，会将当前设备音量调节到`maxPhoneVolume`。默认为NO。非必需
@property (nonatomic, assign) BOOL isAdjustPhoneVolume;
//  音量调节后最大音量。阈值范围为[0, 100]，默认为0。该参数仅在`isAdjustPhoneVolume`值为YES时生效。非必需
@property (nonatomic, assign) int adjustPhoneVolume;
//  设置为静音模式。YES为设置静音模式，NO为不设置。默认值为NO。非必需
@property (nonatomic, assign) BOOL isMute;
//  指定是否显示活体检测页面底部powerby图片。默认值为NO，不显示。非必需
@property (nonatomic, assign) BOOL showPoweryby;

@end

NS_ASSUME_NONNULL_END
