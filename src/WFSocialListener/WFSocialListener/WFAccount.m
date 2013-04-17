//
//  WFAccount.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/08.
//  Copyright (c) 2013年 Akihiro Uehara. All rights reserved.
//

#import "WFAccount.h"

@interface WFAccount () {
}
@property (nonatomic) ACAccount *account;
@end

@implementation WFAccount
#pragma mark - Properties
@dynamic identifier;
@dynamic accountType;
@dynamic accountDescription;
@dynamic username;
@dynamic credential;

- (NSString *)getIdentifier {
    return self.account.identifier;
}
- (ACAccountType *)getAccountType {
    return self.account.accountType;
}
- (NSString *)getAccountDescription {
    return self.account.accountDescription;
}
- (NSString *)getUsername {
    return self.account.username;
}
- (ACAccountCredential *)getCredential {
    return self.account.credential;
}

#pragma mark - Constructor
- (id)initWithAccount:(ACAccount *)account {
    self = [super init];
    if (self) {
        self.account = account;
    }
    return self;
}
#pragma mark - Public methods
- (WFAccount *)cloneAccount {
    WFAccount *inst       = [[WFAccount alloc] initWithAccount:self.account];
    inst.account          = self.account;
    inst.clientCredential = self.clientCredential;
    inst.tokenCredential  = self.tokenCredential;

    return inst;
}
@end
