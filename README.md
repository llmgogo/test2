



# Vechain Wallet Sdk 


## Introduction

Vechain wallet SDK provides a series of functional interface can help the iOS developers, for example: developers to quickly create the purse, the private key signature, call vechain block interface, data on the chain, and convenient call vechain connex.

**Features:**

- create wallet
- create wallet with mnemonic
- Verify the mnemonic word is legal
- Decryption keystore
- verify Message
- sign message
- encrypt private key to keystore
- encrypt set current wallet address
- Displays a JavaScript text input panel.
- encrypt inject js into webview
- encrypt The call sign control
- Verify the mnemonic word is legal
- Verify get checksum address
- setup node url

## Get Started 

API
===

To use the Framework, add the ethers.Framework to your project and add:

```obj-c
#import <WalletSDK/WalletUtils.h>
```

1，Basic purse using method    

Create a wallet


[WalletUtils createWalletWithPassword:Password
callback:^(WalletAccountModel * _Nonnull account, NSError * _Nonnull error)
{}];

2，dapp Call web3 connex or development

在webview didCommitNavigation add a callback methods

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation;
{
[WalletUtils injectJS:webView];
}

Add the callback method in the webview runJavaScriptTextInputPanelWithPrompt

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler
{
[WalletUtils webView:webView  defaultText:defaultText completionHandler:completionHandler];
}

3，We do not provide private key preservation solution, we only provide a simple way





## API Reference：

+ [API Reference](https://vit.digonchain.com/vechain-mobile-apps/ios-wallet-sdk/blob/master/README.md) for VeChain app developers

## License

Connex is licensed under the
[GNU Lesser General Public License v3.0](https://www.gnu.org/licenses/lgpl-3.0.html), also included
in *LICENSE* file in the repository.

