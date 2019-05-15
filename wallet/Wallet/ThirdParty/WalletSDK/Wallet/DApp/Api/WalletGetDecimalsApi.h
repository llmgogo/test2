//
//  WalletGetDecimalsApi.h
//  VeWallet
//
//  Created by Tom on 2019/1/16.
//  Copyright © 2019年 VeChain. All rights reserved.
//

#import "VCBaseApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface WalletGetDecimalsApi : VCBaseApi

-(instancetype)initWithTokenAddress:(NSString *)tokenAddress;

@end

NS_ASSUME_NONNULL_END
