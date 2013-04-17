//
//  TwitterListViewController.m
//  WFSocialListenerDemo
//
//  Created by Akihiro Uehara on 2013/05/15.
//  Copyright (c) 2013年 Akihiro Uehara. All rights reserved.
//

#import "TwitterListViewController.h"
#import "WFTwitterSetting.h"
#import "OAuthUserAuthenticationViewController.h"

@interface TwitterListViewController () {
    NSArray *_settingContext;
    WFTwitterSetting *_dmSetting;
    BOOL _setDMOn;
}
@end

@implementation TwitterListViewController
#pragma mark - TableViewController life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // FIXME DelegateはAppDelegateにすべき？
    self.listener = [[WFSocialListener alloc] initWithDelegate:self];
    _settingContext = @[@[@"Home time line", [NSNumber numberWithInt:(WFTwitterEventType)TWHomeTimeLine]],
                        @[@"Mention",        [NSNumber numberWithInt:(WFTwitterEventType)TWMention]],
                        @[@"Retweet",        [NSNumber numberWithInt:(WFTwitterEventType)TWRetweet]],
                        @[@"Favorited",      [NSNumber numberWithInt:(WFTwitterEventType)TWFavorited]],
                        @[@"NewFollower",    [NSNumber numberWithInt:(WFTwitterEventType)TWNewFollower]],
                        @[@"DirectMessage",  [NSNumber numberWithInt:(WFTwitterEventType)TWDirectMessage]]];
}

-(void)viewWillAppear:(BOOL)animated {
    if(_setDMOn) {
        [_dmSetting setWatchFlag:TWDirectMessage value:YES];
        _setDMOn = NO;
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_listener.twitterSettings count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    WFTwitterSetting *setting = [_listener.twitterSettings objectAtIndex:section];
    return setting.name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_settingContext count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SwitchSettingCell";
    
    SwitchSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    WFTwitterSetting *setting = [_listener.twitterSettings objectAtIndex:[indexPath section]];

    NSArray *context = [_settingContext objectAtIndex:indexPath.row];
    NSString *title  = [context objectAtIndex:0];
    WFTwitterEventType eventType = [[context objectAtIndex:1] intValue];
    [cell setSetting:title setting:setting forEventType:eventType];
    cell.delegate = nil;
    
    if (eventType == TWDirectMessage) {
        cell.delegate = self;
    }
    
    return cell;
}

#pragma mark - Private method

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAuthenticationView"]) {
        OAuthUserAuthenticationViewController *dst = segue.destinationViewController;
        dst.setting   = _dmSetting;
        _setDMOn      = YES;
    }
}

#pragma mark - SwitchSettingCellDelegate
- (void)requestCredentialToWatchDM:(SwitchSettingCell *)sender {
    if (!sender.setting.canAccessDirectMessage) {
        _dmSetting = sender.setting;
        [self performSegueWithIdentifier:@"showAuthenticationView" sender:self];
    }
}

#pragma mark - Delegates
- (void)didTwitterUpdated:(WFSocialListener *)sender account:(ACAccount *)account eventType:(WFTwitterEventType)eventType json:(id)json {
    //    DLog(@"%s sender:%@ account:%@ eventType:%d json:%@", __func__, sender, account, eventType, json);

    // セルを探す
    for(int sec =0; sec < self.tableView.numberOfSections; sec++) {
        const int rows = [self.tableView numberOfRowsInSection:sec];
        for(int row =0; row < rows; row++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:sec];
            SwitchSettingCell *cell =(SwitchSettingCell *) [self.tableView cellForRowAtIndexPath:path];
            if(cell.eventType == eventType && [cell.setting.name isEqualToString:account.username]) {
                [cell flushColor];
                return;
            }
        }
    }

}
- (void)didReadAccounts:(WFSocialListener *)sender accountTypeIdentifier:(NSString *)identifier {
    [self.tableView reloadData];
    [_listener start];
}
@end
