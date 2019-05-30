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
//  WalletBalanceModel.h
//  VCWallet
//
//  Created by vechaindev on 2018/5/10.
//  Copyright © 2018年 VeChain. All rights reserved.
//

#import "WalletBaseModel.h"

@interface WalletBalanceModel : WalletBaseModel

//Token balance

@property (nonatomic, copy)NSString *data;
@property (nonatomic, copy)NSString *gasUsed;
@property (nonatomic, copy)NSString *reverted;
@property (nonatomic, copy)NSString *vmError;

//VET balaance
@property (nonatomic, copy)NSString *balance;
@property (nonatomic, copy)NSString *energy;
@property (nonatomic, copy)NSString *hasCode;


@end
