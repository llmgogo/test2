//
//  WalletBaseApi.m
//  Wallet
//
//  Created by Tom on 18/4/7.
//  Copyright © VECHAIN. All rights reserved.
//

#import "NSJSONSerialization+NilDataParameter.h"
#import "WalletBaseApi.h"
#import "WalletModelFetcher.h"
#import "NSStringAdditions.h"
#import "NSObject+LKModel.h"

@implementation WalletBaseApi


- (id)init
{
    if (self  = [super init]) {
        httpAddress = @"";
        self.requestMethod = RequestGetMethod;
    }
    return self;
}


/**
 *  obj 属性返回类型
 */
- (Class)expectedJsonObjClass
{
    return [NSDictionary class];
}

/**
 * 如果 entity 直接是数组类型，提供数组内的对象类
 *
 */

-(Class)expectedInnerArrayClass{
    return [NSDictionary class];
}

/**
 *  obj 属性值类型
 */
- (Class)expectedModelClass
{
    return [self expectedJsonObjClass];
}

- (void)convertJsonResultToModel:(NSDictionary *)jsonDict
{
    if ([self expectedModelClass] == nil ||
        [self expectedModelClass] == [self expectedJsonObjClass]) {
        self.resultModel = jsonDict;
    } else {
        self.resultModel = [[self expectedModelClass] yy_modelWithDictionary:jsonDict];
    }
}

- (NSMutableDictionary *)buildRequestDict
{
    if (!_requestParmas) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        _requestParmas = dict;
    }
    return _requestParmas;
}

- (NSMutableDictionary *)buildRequestDictWithDepedency:(NSDictionary *)dict {
    _requestParmas = dict.mutableCopy;
    return _requestParmas;
}

- (void)buildModelWithObjDict:(NSDictionary *)dict;
{
}

-(void)loadDataAsyncWithSuccess:(WalletLoadSuccessBlock)success
                        failure:(WalletLoadFailBlock)failure
{
    _successBlock = success;
    _failBlock = failure;
    if ( httpAddress == nil) {
        _failBlock(self,@"");
        return;
    }
    
    NSMutableDictionary *postDict = [self buildRequestDict];
    NSError *error = nil;
    switch (_requestMethod) {
        case RequestGetMethod:
        {
            [WalletModelFetcher requestGetWithUrl:httpAddress
                                          params:postDict
                                           error:&error
                                   responseBlock:^(NSDictionary *responseDict, NSDictionary *responseHeaderFields, NSError *error)
            {
               [self analyseResponseInfo:responseDict
                            headerFileds:responseHeaderFields
                                   error:error];
            }];
        }
            break;
        
        case RequestPostMethod:
        {
            [WalletModelFetcher requestPostWithUrl:httpAddress
                                           params:postDict
                                            error:&error
                                    responseBlock:^(NSDictionary *responseDict, NSDictionary *responseHeaderFields, NSError *error)
            {                
                [self analyseResponseInfo:responseDict
                             headerFileds:responseHeaderFields
                                    error:error];
                
            }];
        }
            break;
                    
        default:
            break;
    }
}

- (void)analyseResponseInfo:(NSDictionary *)responseData
               headerFileds:(NSDictionary *)headerFields
                      error:(NSError *)error {
    self.responseHeaderFields = headerFields;
    NSNumber *errCode = nil;
    NSString *errMsg = nil;
    self.resultModel = responseData; //先给，后面覆盖
    if (responseData != nil) {
        NSDictionary *dict = responseData;
        errCode = [dict valueForKey:@"code"];
        errMsg = [dict valueForKey:@"message"];
        self.resultDict = dict;
        
        if ([responseData isKindOfClass:[NSArray class]]) {
            self.status = RequestSuccess;
            [self convertJsonResultToModel:responseData];
            self.resultModel = responseData;
            _successBlock(self);
            return;
        }
        
        if ((errCode != nil && [errCode integerValue] == 1) || (errCode.integerValue == 0)) {
            
            if ([responseData isKindOfClass:[NSString class]]) { // 说明是 3840 返回格式不符
                
                [self convertJsonResultToModel:nil];
                self.resultModel = nil;
                
                if (self.supportOtherDataFormat) { // 支持其他数据模型
                    self.resultDict = nil;
                    self.status = RequestSuccess;
                    _successBlock(self);
                    return;
                    
                }else { // 不支持
                    errCode = @(3840);
                    
                     // 注释代码，暂且不用，下面的方法中有引用到error 对象
//                    error = [NSError errorWithDomain:NSCocoaErrorDomain
//                                                code:errCode.integerValue
//                                            userInfo:@{NSLocalizedDescriptionKey: @"不支持非json数据结构"}];
                    self.status = RequestFailed;
                }
                
            }else { //说明是其他数据模型
                
                id objDict = nil;
                NSDictionary *dictEntity = [dict objectForKey:@"data"];
                if (_specialRequest) {
                    objDict = responseData;
                }else if(dictEntity != nil && dictEntity != (NSDictionary *)[NSNull null]) {
                    objDict = dictEntity;
                }else{
                    objDict = responseData;
                }
                
                if(objDict && [objDict isKindOfClass:[NSDictionary class]]){  // 返回的有可能不是dict
                    
                    self.status = RequestSuccess;
                    [self convertJsonResultToModel:objDict];
                    
                }else if(objDict && [objDict isKindOfClass:[NSArray class]]){
                    self.status = RequestSuccess;
                    
                    //entity 最外层直接为数组的情况
                    self.resultModel = [NSArray yy_modelArrayWithClass:[self expectedInnerArrayClass] json:objDict];
                }else{
                    self.status = RequestSuccess;
                    self.resultModel = objDict;
                }
                self.status = RequestSuccess;
                _successBlock(self);
                return;
            }
            
        } else {
            self.status = RequestFailed;
        }
        
    } else {
        if ([httpAddress containsString:@"transactions"] && [httpAddress hasSuffix:@"receipt"]) {
            self.status = RequestSuccess;
            _successBlock(self);
            return;
            
        }else{
            
            if (self.supportOtherDataFormat) {
                if (error.code == 3840) {
                    self.resultDict = nil;
                    self.status = RequestSuccess;
                    _successBlock(self);
                    return;
                }else{
                    self.status = RequestFailed;
                }
            }else{
                self.status = RequestFailed;
            }
        }
    }
    
    [self buildErrorInfoWithRequestError:error
                       responseErrorCode:errCode
                        responseErrorMsg:errMsg];
    
}

- (void)buildErrorInfoWithRequestError:(NSError *)error
                     responseErrorCode:(NSNumber *)errCode
                      responseErrorMsg:(NSString *)errMsg
{
    if (error) {
        // ASIHttpRequest发送请求时发生错误，现在都统一默认为网络不可用。
        NSData *errorData = error.userInfo[@"response.error.data"];
        NSString *errorInfo = [[NSString alloc]initWithData:errorData encoding:NSUTF8StringEncoding];
        
        NSDictionary *dictError = [NSJSONSerialization dictionaryWithJsonString:errorInfo];
        
        NSString *temp = dictError[@"message"];
        errMsg = temp.length > 0 ? temp : @"no network";
        errCode = dictError[@"code"];
        
        self.lastError = [NSError errorWithDomain:@"Wallet"
                                             code:errCode.integerValue
                                         userInfo:@{NSLocalizedFailureReasonErrorKey: errMsg.length > 0 ? errMsg : VCNSLocalizedBundleString(@"no_network_hint", nil)}];
        
    }
    else if (nil == errCode || [errCode intValue] != 1) {
        
        if ([errMsg isEqual:[NSNull null]]) {
            errMsg = VCNSLocalizedBundleString(@"Unknown error", nil);
        }else{
            errMsg = [errMsg length] ? errMsg : VCNSLocalizedBundleString(@"Unknown error", nil);
        }
        
        self.lastError = [NSError errorWithDomain:@"Wallet"
                                             code:[errCode integerValue]
                                         userInfo:@{NSLocalizedFailureReasonErrorKey:errMsg}];
    } else {
        self.lastError = nil;
    }
    if (self.status == RequestFailed) {
        if (_failBlock) {
            _failBlock(self,errMsg);
        }
    }
}


@end
