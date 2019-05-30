/**
    Copyright (c) 2019 vechaindev <support@vechain.com>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.

**/

//
//  WalletDAppHandle+transfer.h
//  WalletSDK
//
//  Created by vechaindev on 2019/4/2.
//  Copyright © 2019年 VeChain. All rights reserved.
//

#import "WalletDAppHandle.h"

NS_ASSUME_NONNULL_BEGIN

@interface WalletDAppHandle (transfer)

- (void)signTransfer:(TransactionParameter *)paramModel
            keystore:(NSString *)keystore
            password:(NSString *)password
              isSend:(BOOL)isSend
            callback:(void(^)(NSString *txId))callback;

@end

NS_ASSUME_NONNULL_END
