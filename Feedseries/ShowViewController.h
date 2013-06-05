//
//  ShowViewController.h
//  Feedseries
//
//  Created by Brian Krochik on 23/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *BtnAction;
@property (weak, nonatomic) IBOutlet UIImageView *ImgShow;
@property (weak, nonatomic) IBOutlet UILabel *TxtTitle;
@property (weak, nonatomic) IBOutlet UILabel *TxtDescription;
@property (weak, nonatomic) IBOutlet UITextView *TxtOverview;
@property (weak, nonatomic) IBOutlet UILabel *TxtEpisode;
@property (weak, nonatomic) IBOutlet UILabel *TxtDate;


@property (weak, nonatomic) NSString *EpisodeId;
@property (weak, nonatomic) NSString *BackStoryId;
@property (weak, nonatomic) NSString *ShowDetail;
@property (weak, nonatomic) NSString *ShowId;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *BtnBack;

@end
