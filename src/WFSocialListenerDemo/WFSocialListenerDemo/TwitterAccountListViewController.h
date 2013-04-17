//
//  TwitterAccountListViewController.h
//  WFSocialListenerDemo
//
//  Created by Akihiro Uehara on 2013/05/03.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFSocialListener.h"

@interface TwitterAccountListViewController : UITableViewController<WFSocialListenerDelegate>
@property (nonatomic) WFSocialListener *listener;
@end
