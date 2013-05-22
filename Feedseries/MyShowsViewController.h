//
//  FirstViewController.h
//  Feedseries
//
//  Created by Brian Krochik on 15/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyShowsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *InputSearch;
@property (weak, nonatomic) IBOutlet UITableView *myShowsTable;

@end
