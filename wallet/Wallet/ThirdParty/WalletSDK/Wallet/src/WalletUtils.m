//
//  WalletUtils.m
//
//  Created by VeChain on 2018/8/12.
//  Copyright © 2018年 VeChain. All rights reserved.
//

#import "WalletUtils.h"
#import "WalletDAppHandle.h"
#import "WalletSignatureView.h"
#import "WalletTools.h"
#import "WalletDAppHead.h"
#import "WalletSingletonHandle.h"

@implementation WalletUtils
{
}

+ (void)createWalletWithPassword:(NSString *)password
                       callback:(void(^)(Account *account))block
{
    __block Account *account = [Account randomMnemonicAccount];
    
    [account encryptSecretStorageJSON:password callback:^(NSString *json) {
        
         account.keystore = json;
        if (block) {
            block(account);
        }
    }];
}

+ (void)creatWalletWithMnemonic:(NSString *)mnemonic
                      password:(NSString *)password
                      callback:(void(^)(Account *account))block
{
    __block Account *account = [Account accountWithMnemonicPhrase:mnemonic];
    
    [account encryptSecretStorageJSON:password callback:^(NSString *json) {
        
        account.keystore = json;
        if (block) {
            block(account);
        }
    }];
}

+ (BOOL)isValidMnemonicPhrase:(NSString*)phrase
{
    return [Account isValidMnemonicPhrase:phrase];
}

+ (void)decryptSecretStorageJSON:(NSString*)json
                        password:(NSString*)password
                        callback:(void (^)(Account *account, NSError *NSError))callback
{
    [Account decryptSecretStorageJSON:json password:password callback:callback];
}

+ (Address*)recoverAddressFromMessage:(NSData*)message
                signature:(Signature*)signature
{
   return [Account verifyMessage:message signature:signature];
}

+ (void)sign:(NSData*)message
    keystore:(NSString*)json
    password:(NSString*)password
       block:(void (^)(Signature *signature))block
{
    [Account decryptSecretStorageJSON:json
                             password:password
                             callback:^(Account *account, NSError *NSError)
     {
#warning 签出 1或者 0,fail alert
         // 签名交易
         if (NSError == nil) {
            SecureData *data = [SecureData BLAKE2B:message];
            Signature *signature = [account signDigest:data.data];
             if (block) {
                 block(signature);
             }
         }
     }];
}

+ (void)encryptSecretStorageJSON:(NSString*)password
                         account:(Account *)account
                        callback:(void (^)(NSString *))callback
{
    [account encryptSecretStorageJSON:password
                             callback:^(NSString *json)
    {
         if (json.length > 0) {
             if (callback) {
                 callback(json);
             }
         }
    }];
}

+ (void)setCurrentWallet:(NSString *)address
{
    [[WalletSingletonHandle shareWalletHandle] setCurrentModel:address];
}

+ (void)initWithWalletDict:(NSMutableArray *)walletList
{
    [[WalletDAppHandle shareWalletHandle]initWithWalletDict:walletList];
}

+ (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler
{
    NSLog(@"defaultText == %@",defaultText);
    
    WalletDAppHandle *dappHandle = [WalletDAppHandle shareWalletHandle];
    [dappHandle webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
}

+ (void)injectJS:(WKWebView *)webview
{
    WalletDAppHandle *dappHandle = [WalletDAppHandle shareWalletHandle];
    [dappHandle injectJS:webview];
}

+ (void)signViewFromAddress:(NSString *_Nonnull)fromAddress toAddress:(NSString *_Nonnull)toAddress amount:(NSString *_Nonnull)amount symbol:(NSString *_Nonnull)symbol gas:(NSString *)gas tokenAddress:(NSString *)tokenAddress decimals:(int)decimals block:(void(^)(NSString *txId))block
{
    NSMutableDictionary *dictParam = [NSMutableDictionary dictionary];
    CGFloat defaultGasPriceCoef = [BigNumber bigNumberWithHexString:DefaultGasPriceCoef].decimalString.floatValue;
    BigNumber *gasCanUse = [WalletTools calcThorNeeded:defaultGasPriceCoef gas:[NSNumber numberWithInteger:gas.integerValue]];
    
    NSString *miner = [[Payment formatEther:gasCanUse options:2] stringByAppendingString:@" VTHO"];
    
    [dictParam setValueIfNotNil:miner forKey:@"miner"];
    [dictParam setValueIfNotNil:[BigNumber bigNumberWithHexString:DefaultGasPriceCoef] forKey:@"gasPriceCoef"];
    [dictParam setValueIfNotNil:gas forKey:@"gas"];
    [dictParam setValueIfNotNil:toAddress forKey:@"to"];
    [dictParam setValueIfNotNil:amount forKey:@"amount"];
    
    WalletCoinModel *coinModel = [[WalletCoinModel alloc]init];
    coinModel.coinName         = symbol;
    coinModel.transferGas      = gas;
    coinModel.decimals         = decimals;
    [dictParam setValueIfNotNil:coinModel forKey:@"coinModel"];
    
    WalletSignatureView *signatureView = [[WalletSignatureView alloc] initWithFrame:[WalletTools getCurrentVC].view.bounds];
    signatureView.transferType = JSVTHOTransferType;

    if ([symbol.lowercaseString isEqualToString:@"vet"]) {
        signatureView.transferType = JSVETTransferType;
    }
    [signatureView updateView:fromAddress
                    toAddress:toAddress
                 contractType:NoContract_transferToken
                       amount:amount
                       params:@[dictParam]];
    [[WalletTools getCurrentVC].navigationController.view addSubview:signatureView];
    
    signatureView.transferBlock = ^(NSString * _Nonnull txid) {
        NSLog(@"txid = %@",txid);
        
        if (block) {
            block(txid);
        }
    };
}

@end
