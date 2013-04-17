//
//  TwitterAccountListViewController.m
//  WFSocialListenerDemo
//
//  Created by Akihiro Uehara on 2013/05/03.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "TwitterAccountListViewController.h"
#import "WFTwitterSetting.h"
#import "TwitterAccountSettingViewController.h"

@interface TwitterAccountListViewController () {
}
@end

@implementation TwitterAccountListViewController
#pragma mark - TableViewController life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // FIXME DelegateはAppDelegateにすべき？
    self.listener = [[WFSocialListener alloc] initWithDelegate:self];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [_listener.twitterSettings count];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TwitterAccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    // 更新をかける
    WFTwitterSetting *setting = [_listener.twitterSettings objectAtIndex:[indexPath row]];
    // FIXME  ユーザ情報の更新、これ必要か？
    if (setting.name != nil) {
        [self updateCellView:cell setting:setting];
    } else {
        [self updateCellView:cell setting:nil];
        [setting requestUserStatus:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self updateCellView:cell setting:setting];
            }
        }];
    }
    
    return cell;
}

#pragma mark - Private method
- (void)updateCellView:(UITableViewCell *)cell setting:(WFTwitterSetting *)setting {
    if (setting != nil && setting.name != nil) {
        cell.textLabel.text       = setting.name;
        cell.detailTextLabel.text = setting.screen_name;
        NSData *data              = [NSData dataWithContentsOfURL:[NSURL URLWithString:setting.profile_image_url]];
        cell.imageView.image      = [[UIImage alloc] initWithData:data];
    } else {
        cell.textLabel.text       = @"unkown";
        cell.detailTextLabel.text = @"";
        cell.imageView.image      = nil;        
    }
}
#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSetting"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TwitterAccountSettingViewController *dst = segue.destinationViewController;
        dst.setting = [_listener.twitterSettings objectAtIndex:indexPath.row];
        // FIXME
        [_listener start];
    }
}

#pragma mark - Delegates
- (void)didTwitterUpdated:(WFSocialListener *)sender account:(ACAccount *)account eventType:(WFTwitterEventType)eventType json:(id)json {
//    DLog(@"%s sender:%@ account:%@ eventType:%d json:%@", __func__, sender, account, eventType, json);
//    DLog(@"%s sender:%@ account:%@ eventType:%d", __func__, sender, account.username, eventType);
}
- (void)didReadAccounts:(WFSocialListener *)sender accountTypeIdentifier:(NSString *)identifier {
    [self.tableView reloadData];
    [_listener start];
}
@end
