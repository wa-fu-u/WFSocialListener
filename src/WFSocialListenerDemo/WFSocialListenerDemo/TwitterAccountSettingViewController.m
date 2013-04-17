//
//  TwitterAccountSettingViewController.m
//  WFSocialListenerDemo
//
//  Created by Akihiro Uehara on 2013/05/04.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "TwitterAccountSettingViewController.h"
#import "OAuthUserAuthenticationViewController.h"

@interface TwitterAccountSettingViewController () {
    NSArray *_settingContext;
    SwitchSettingCell *_dmCell;
    BOOL _setDMOn;
}
@end

@implementation TwitterAccountSettingViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    _settingContext = @[@[@"Home time line", [NSNumber numberWithInt:(WFTwitterEventType)TWHomeTimeLine]],
                        @[@"Mention",        [NSNumber numberWithInt:(WFTwitterEventType)TWMention]],
                        @[@"Retweet",        [NSNumber numberWithInt:(WFTwitterEventType)TWRetweet]],
                        @[@"Favorited",      [NSNumber numberWithInt:(WFTwitterEventType)TWFavorited]],
                        @[@"NewFollower",    [NSNumber numberWithInt:(WFTwitterEventType)TWNewFollower]],
                        @[@"DirectMessage",  [NSNumber numberWithInt:(WFTwitterEventType)TWDirectMessage]]];
}
- (void)viewWillAppear:(BOOL)animated
{
    if (_setDMOn) {
        [_setting setWatchFlag:TWDirectMessage value:YES];
        _setDMOn = NO;        
    }
    [self.tableView reloadData];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_settingContext count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SwitchSettingCell";

    SwitchSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSArray *context = [_settingContext objectAtIndex:indexPath.row];
    NSString *title  = [context objectAtIndex:0];
    WFTwitterEventType eventType = [[context objectAtIndex:1] intValue];
    [cell setSetting:title setting:self.setting forEventType:eventType];
    cell.delegate = nil;
    
    if (eventType == TWDirectMessage) {
        _dmCell = cell;
        _dmCell.delegate = self;
    }

    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
#pragma mark - OVerride methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAuthenticationView"]) {
        OAuthUserAuthenticationViewController *dst = segue.destinationViewController;
        dst.setting   = self.setting;
        _setDMOn      = YES;
    }
}
#pragma mark - SwitchSettingCellDelegate
- (void)requestCredentialToWatchDM:(SwitchSettingCell *)sender {
    if (!_setting.canAccessDirectMessage) {
        [self performSegueWithIdentifier:@"showAuthenticationView" sender:self];
    }
}
@end
