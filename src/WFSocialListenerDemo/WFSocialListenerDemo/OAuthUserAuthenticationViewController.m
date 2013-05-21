//
//  OAuthUserAuthenticationViewController.m
//  WFSocialListenerDemo
//
//  Created by Akihiro Uehara on 2013/05/04.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "OAuthUserAuthenticationViewController.h"
#import "TwitterAPI_APP_TOKEN.h"

@implementation OAuthUserAuthenticationViewController
- (void)viewDidAppear:(BOOL)animated {
    NSAssert([kAppKey length] > 0, @"kAppKey in TwitterAPI_APP_TOKEN.h must be set." );
    NSAssert([kAppSecret length] > 0, @"kAppSecret in TwitterAPI_APP_TOKEN.h must be set." );
    
    [self.setting
     requestDMToken:self.webView
     key:kAppKey
     secret:kAppSecret
     callbackURI:@"http://www.wa-fu-u.com"
     
     handler:^(BOOL succeeded, NSError *error) {
         if ( ! succeeded ) {
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:@"Credential error."
                                   message:[NSString stringWithFormat:@"%@",error ]
                                   delegate:self
                                   cancelButtonTitle:nil
                                   otherButtonTitles:@"OK", nil];
             [alert show];
         } else {
             [self closeView];
         }
     }];
}
-(void) closeView {
    self.webView.delegate = nil;
    [self.webView stopLoading];
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self closeView];
}
@end
