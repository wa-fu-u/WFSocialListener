//
//  TwitterAccountSettingViewController.h
//  WFSocialListenerDemo
//
//  Created by Akihiro Uehara on 2013/05/04.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFTwitterSetting.h"
#import "SwitchSettingCell.h"

@interface TwitterAccountSettingViewController : UITableViewController<SwitchSettingCellDelegate>

@property (nonatomic) WFTwitterSetting *setting;

@end
