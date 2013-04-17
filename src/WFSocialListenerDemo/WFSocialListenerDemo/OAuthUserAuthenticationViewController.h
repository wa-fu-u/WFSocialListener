//
//  OAuthUserAuthenticationViewController.h
//  WFSocialListenerDemo
//
//  Created by Akihiro Uehara on 2013/05/04.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFSocialListener.h"

@interface OAuthUserAuthenticationViewController : UIViewController<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic) WFTwitterSetting *setting;
@end
