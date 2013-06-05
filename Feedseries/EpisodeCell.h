//
//  EpisodeCell.h
//  Feedseries
//
//  Created by Brian Krochik on 16/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpisodeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UIImageView *episodeImage;
@property (weak, nonatomic) IBOutlet UILabel *episode;
@property (weak, nonatomic) IBOutlet UILabel *season;
@property (weak, nonatomic) IBOutlet UILabel *allEpisodeNumber;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIButton *BtnRemove;

@end
