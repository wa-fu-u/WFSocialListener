//
//  SwitchSettingCell.m
//  WFSocialListenerDemo
//
//  Created by Akihiro Uehara on 2013/05/04.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "SwitchSettingCell.h"

@interface SwitchSettingCell () {
}
@end

@implementation SwitchSettingCell
#pragma mark - Public methods
- (IBAction)settingSwitchValueChanged:(id)sender {
    if ( _eventType == TWDirectMessage && !self.setting.canAccessDirectMessage && self.settingSwitch.on == YES) {
        [self.delegate requestCredentialToWatchDM:self];
    }

    [_setting setWatchFlag:_eventType value:self.settingSwitch.on];
    [self  updateSwitchView];

}

- (void)setSetting:(NSString *)title setting:(WFTwitterSetting *)setting forEventType:(WFTwitterEventType) eventType {
    self.setting   = setting;
    _eventType = eventType;
    
    self.titleLabel.text  = title;
    [self updateSwitchView];
}
- (void)updateSwitchView {
    self.settingSwitch.on = [self.setting readWatchFlag:_eventType];
}

-(void)flushColor {
    UIView *v = self.contentView;
    UIColor *orgColor = v.backgroundColor;
    [UIView animateWithDuration:2 animations:^{
        v.backgroundColor = [UIColor redColor];
        [UIView animateWithDuration:4 animations:^{
            v.backgroundColor = orgColor;
        }];
    }];
}
@end
