//
//  TwitterListViewController.h
//  WFSocialListenerDemo
//
//  Created by Akihiro Uehara on 2013/05/15.
//  Copyright (c) 2013年 Akihiro Uehara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFSocialListener.h"
#import "SwitchSettingCell.h"

@interface TwitterListViewController : UITableViewController<WFSocialListenerDelegate, SwitchSettingCellDelegate>
@property (nonatomic) WFSocialListener *listener;
@end
