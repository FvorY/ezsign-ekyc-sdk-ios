//
//  MegLiveV5DetectError.h
//  MegLiveV5Detect
//
//  Created by MegviiDev on 2024/2/16.
//

#import <Foundation/Foundation.h>
#import <MegLiveV5Detect/MegLiveV5DetectConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface MegLiveV5DetectError : NSObject

@property (nonatomic, assign) MegLiveV5DetectErrorType errorCode;
@property (nonatomic, strong) NSString* errorMessage;

@end

NS_ASSUME_NONNULL_END
