//
//  WalletManageModel.m
//  VCWallet
//
//  Created by Tom on 2018/4/18.
//  Copyright © 2018年 VeChain. All rights reserved.
//

#import "WalletManageModel.h"

@implementation WalletManageModel


@end

@implementation WalletCoinModel


+(NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"pdescription_cn":@"description_cn",
             @"pdescription_en":@"description_en",             
             };
}

@end
