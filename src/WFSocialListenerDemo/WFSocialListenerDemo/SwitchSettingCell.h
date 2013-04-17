//
//  SwitchSettingCell.h
//  WFSocialListenerDemo
//
//  Created by Akihiro Uehara on 2013/05/04.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFTwitterSetting.h"

@class SwitchSettingCell;

@protocol SwitchSettingCellDelegate <NSObject>
- (void)requestCredentialToWatchDM:(SwitchSettingCell *)sender;
@end

@interface SwitchSettingCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel  *titleLabel;
@property (nonatomic, weak) IBOutlet UISwitch *settingSwitch;

@property (nonatomic) WFTwitterSetting *setting;
@property (nonatomic, weak) NSObject<SwitchSettingCellDelegate> *delegate;
@property (nonatomic) WFTwitterEventType eventType;

- (IBAction)settingSwitchValueChanged:(id)sender;
- (void)setSetting:(NSString *)title setting:(WFTwitterSetting *)setting forEventType:(WFTwitterEventType) eventType;
- (void)updateSwitchView;

-(void)flushColor;
@end
