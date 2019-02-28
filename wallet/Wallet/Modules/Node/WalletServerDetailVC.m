//
//  WalletServerDetailVC.m
//  walletSDKDemo
//
//  Created by 曾新 on 2019/1/30.
//  Copyright © 2019年 demo. All rights reserved.
//

#import "WalletServerDetailVC.h"

@interface WalletServerDetailVC ()
{
    NSString *_netNameText;
    NSString *_netUrlText;
}
@property (weak, nonatomic) IBOutlet UILabel *netName;
@property (weak, nonatomic) IBOutlet UILabel *netUrl;

@end

@implementation WalletServerDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _netName.text = _netNameText;
    _netUrl.text = _netUrlText;
}

- (void)netName:(NSString *)netName netUrl:(NSString *)netUrl
{
    _netNameText = netName;
    _netUrlText = netUrl;
}


@end
