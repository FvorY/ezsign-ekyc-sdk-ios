//
//  MegLivePEV5DetectError.h
//  MegLiveV5Detect
//
//  Created by MegviiDev on 2024/2/16.
//

#import <Foundation/Foundation.h>
#import <MegLiveV5Detect/MegLivePEV5DetectConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface MegLivePEV5DetectError : NSObject

@property (nonatomic, assign) MegLivePEV5DetectErrorType errorCode;
@property (nonatomic, strong) NSString* errorMessage;

@end

NS_ASSUME_NONNULL_END
