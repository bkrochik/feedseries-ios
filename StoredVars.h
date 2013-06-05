//
//  StoredVars.h
//  Feedseries
//
//  Created by Brian Krochik on 18/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoredVars : NSObject

@property (nonatomic) NSString * userId;
@property (nonatomic) NSString * episodeId;
@property (nonatomic) NSString * deviceToken;
+ (StoredVars*) sharedInstance;

@end
