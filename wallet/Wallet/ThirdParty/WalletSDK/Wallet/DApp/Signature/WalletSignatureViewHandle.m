//
//  WalletSignatureViewHandle.m
//  WalletSDK
//
//  Created by 曾新 on 2019/2/14.
//  Copyright © 2019年 VeChain. All rights reserved.
//

#import "WalletSignatureViewHandle.h"
#import "WalletManageModel.h"
#import "WalletAlertShower.h"
#import "WalletMBProgressShower.h"
#import "WalletSignatureView.h"
#import "WalletGradientLayerButton.h"
#import "WalletBlockInfoApi.h"
#import "WalletTransactionApi.h"
#import "WalletTransantionsReceiptApi.h"
#import "WalletGenesisBlockInfoApi.h"
#import "WalletSignatureView+transferToken.h"
#import "WalletDAppSignPreVC.h"
#import "UIButton+block.h"
#import "WalletDAppSignPreVC.h"
#import "WalletSingletonHandle.h"
#import "NSBundle+Localizable.h"
#import "WalletGetSymbolApi.h"
#import "WalletGetDecimalsApi.h"
#import "WalletDAppHead.h"


@implementation WalletSignatureViewHandle

- (void)checkBalcanceFromAddress:(NSString *)fromAddress amount:(NSString *)amount gasLimit:(NSString *)gasLimit block:(void(^)())block
{
    if (fromAddress.length > 0) {
        // vet检查
        [self getVETBalance:fromAddress amount:(NSString *)amount block:^{
            if (block) {
                block();
            }
        }];
        
        [self getVTHOBalance:fromAddress gasLimit:gasLimit block:^{
            if (block) {
                block();
            }
        }];
        return ;
    }
}

- (void)getVETBalance:(NSString *)address amount:(NSString *)amount block:(void(^)())block
{
 
    NSString *blockHost = [WalletUserDefaultManager getBlockUrl];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/accounts/%@",blockHost,address];
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    [httpManager GET:urlString
          parameters:nil
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         NSDictionary *dictResponse = (NSDictionary *)responseObject;
         NSString *balance = dictResponse[@"balance"];
         
         BigNumber *bigNumberCount = [BigNumber bigNumberWithHexString:balance];
         NSString *vetBalance = [Payment formatEther:bigNumberCount];
         
         NSDecimalNumber *vetBalanceNum = [NSDecimalNumber decimalNumberWithString:vetBalance];
         NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithString:amount];
         
         if ([vetBalanceNum compare:amountNum] == NSOrderedAscending) {
             
             NSString *tempAmount = amount;
             if ([amount containsString:@"0x"]) {
                 
                 BigNumber *bigNumberCount = [BigNumber bigNumberWithHexString:amount];
                 tempAmount = [Payment formatEther:bigNumberCount];
             }
             
             NSString *msg = [NSString stringWithFormat:VCNSLocalizedString(@"contact_buy_failed_not_enough1", nil),vetBalance.floatValue,tempAmount.floatValue];
             
             [WalletAlertShower showAlert:VCNSLocalizedString(@"transfer_wallet_send_balance_not_enough", nil)
                                      msg:msg
                                    inCtl:[WalletTools getCurrentVC]
                                    items:@[VCNSLocalizedString(@"dialog_yes", nil)]
                               clickBlock:^(NSInteger index)
              {
              }];
         }else{
             if (block) {
                 block();
             }
         }
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         
         
     }];
}

- (void)getVTHOBalance:(NSString *)address gasLimit:(NSString *)gasLimit block:(void(^)())block
{
    NSString *blockHost = [WalletUserDefaultManager getBlockUrl];
    NSString *urlString = [NSString stringWithFormat:@"%@/accounts/%@",blockHost,vthoTokenAddress]  ;
    
    NSMutableDictionary *dictParm = [NSMutableDictionary dictionary];
    [dictParm setObject:[WalletTools tokenBalanceData:address] forKey:@"data"];
    [dictParm setObject:@"0x0" forKey:@"value"];
    
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [httpManager POST:urlString parameters:dictParm progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dictResponse = (NSDictionary *)responseObject;
        NSString *amount = dictResponse[@"data"];
        
        BigNumber *bigNumberCount = [BigNumber bigNumberWithHexString:amount];
        NSString *vthoBalance = [Payment formatEther:bigNumberCount];
        
        NSDecimalNumber *vthoBalanceNum = [NSDecimalNumber decimalNumberWithString:vthoBalance];
        
        NSDecimalNumber *transferVthoAmount = [NSDecimalNumber decimalNumberWithString:gasLimit];
        
        if ([vthoBalanceNum  compare:transferVthoAmount] == NSOrderedAscending) {
            
            NSString *msg = [NSString stringWithFormat:VCNSLocalizedString(@"contact_buy_failed_not_enough3", nil),vthoBalanceNum.floatValue,gasLimit.floatValue];
            
            [WalletAlertShower showAlert:VCNSLocalizedString(@"transfer_wallet_send_balance_not_enough", nil)
                                     msg:msg
                                   inCtl:[WalletTools getCurrentVC]
                                   items:@[VCNSLocalizedString(@"dialog_yes", nil)]
                              clickBlock:^(NSInteger index)
             {
             }];
        }else{
            if (block) {
                block();
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Get VTHO balance failure. error: %@", error);
    }];
}


- (void)tokenAddressConvetCoinInfo:(NSString *)tokenAddress coinModel:(WalletCoinModel *)coinModel block:(void(^)(void))block
{
    [WalletMBProgressShower showLoadData:[WalletTools getCurrentVC].view Text:VCNSLocalizedString(@"loading...", nil)];
    WalletGetSymbolApi *getSymbolApi = [[WalletGetSymbolApi alloc]initWithTokenAddress:tokenAddress];
    [getSymbolApi loadDataAsyncWithSuccess:^(VCBaseApi *finishApi) {
        
        NSDictionary *dictResult = finishApi.resultDict;
        NSString *symobl = dictResult[@"data"];
        if (symobl.length < 128) {
            [WalletMBProgressShower showTextIn:[WalletTools getCurrentVC].view Text:ERROR_REQUEST_PARAMS_MSG During:1];
            return ;
        }
        symobl = [WalletTools abiDecodeString:symobl];
        coinModel.symobl = symobl;
        
        WalletGetDecimalsApi *getDecimalsApi = [[WalletGetDecimalsApi alloc]initWithTokenAddress:tokenAddress];
        [getDecimalsApi loadDataAsyncWithSuccess:^(VCBaseApi *finishApi) {
            [WalletMBProgressShower hide:[WalletTools getCurrentVC].view];

            NSDictionary *dictResult = finishApi.resultDict;
            NSString *decimalsHex = dictResult[@"data"];
            NSString *decimals = [BigNumber bigNumberWithHexString:decimalsHex].decimalString;
            coinModel.decimals = decimals.integerValue;
            
            if (block) {
                block();
            }
            
        }failure:^(VCBaseApi *finishApi, NSString *errMsg) {
            [WalletMBProgressShower hide:[WalletTools getCurrentVC].view];
            [WalletMBProgressShower showTextIn:[WalletTools getCurrentVC].view Text:ERROR_REQUEST_PARAMS_MSG During:1];
        }];
    }failure:^(VCBaseApi *finishApi, NSString *errMsg) {
        [WalletMBProgressShower hide:[WalletTools getCurrentVC].view];
        [WalletMBProgressShower showTextIn:[WalletTools getCurrentVC].view Text:ERROR_REQUEST_PARAMS_MSG During:1];
    }];
}

@end
