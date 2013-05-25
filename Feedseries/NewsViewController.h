//
//  NewsViewController.h
//  Feedseries
//
//  Created by Brian Krochik on 22/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *newsTable;

@end
