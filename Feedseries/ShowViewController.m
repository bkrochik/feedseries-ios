//
//  ShowViewController.m
//  Feedseries
//
//  Created by Brian Krochik on 23/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "ShowViewController.h"
#import "EpisodeCell.h"
#import "StoredVars.h"
#import <QuartzCore/QuartzCore.h>
#import "PKRevealController.h"
#import "UIImageView+WebCache.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
#define showEpisode [NSURL URLWithString: @"http://feedseries.herokuapp.com/getEpisodeById"]
#define addShow [NSURL URLWithString: @"http://feedseries.herokuapp.com/newUserShow"]
#define deleteShow [NSString stringWithFormat: @"http://feedseries.herokuapp.com/deleteUserShow"]
@interface ShowViewController ()
{
    NSMutableArray *jsonResults;
    BOOL *follow;
    NSString *showId;
    UIActivityIndicatorView *_activityIndicatorView;
    UIView *_hudView;
}

@end

@implementation ShowViewController
@synthesize EpisodeId;
@synthesize BackStoryId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSpinner];
    [self getEpisodesByShowId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) fetchedData:(NSData *)responseData {
    if(responseData!=nil){
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        jsonResults = [json objectForKey:@"data"];
    }else{
        jsonResults= [NSMutableArray new];
    }
    //Stop Spinner
    [_hudView removeFromSuperview];
    
    [self loadEpisode];
}

-(void)loadEpisode
{
        NSDictionary *episode =[jsonResults objectAtIndex:0];
    
        [self.ImgShow setImageWithURL:[NSURL URLWithString:[episode objectForKey:@"banner"]] placeholderImage:[UIImage imageNamed:[episode objectForKey:@"showTitle"]]];
        self.TxtTitle.text= [NSString stringWithFormat:@"%@ - %@ ", [episode objectForKey:@"showTitle"], [episode objectForKey:@"firstAired"]];
        self.TxtDescription.text= [NSString stringWithFormat:@"%@  %@x%@ ", [episode objectForKey:@"title"], [episode objectForKey:@"season"], [episode objectForKey:@"number"]];
        self.TxtOverview.text=[NSString stringWithFormat:@"%@", [episode objectForKey:@"overview"]];
        showId=[NSString stringWithFormat:@"%@", [episode objectForKey:@"showId"]];
    
        //Check if i follow or not that show
        NSString *haveIt=[NSString stringWithFormat:@"%@", [episode objectForKey:@"iHaveIt"]];

        if([haveIt isEqualToString:@"true"]){
            [self.BtnAction setTitle:@"Remove" forState:UIControlStateNormal];
            [self.BtnAction setTitle:@"Remove" forState:UIControlStateSelected];
            follow=NO;
        }else{
            [self.BtnAction setTitle:@"Follow" forState:UIControlStateNormal];
            [self.BtnAction setTitle:@"Follow" forState:UIControlStateSelected];
            follow=YES;
        }
        [self.BtnAction setHidden:NO];
        [self reloadInputViews];
}

//Load Spinner
- (void) loadSpinner
{
    _hudView = [[UIView alloc] initWithFrame:CGRectMake(75, 155, 170, 170)];
    _hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _hudView.clipsToBounds = YES;
    _hudView.layer.cornerRadius = 10.0;
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.frame = CGRectMake(65, 40, _activityIndicatorView.bounds.size.width, _activityIndicatorView.bounds.size.height);
    [_hudView addSubview:_activityIndicatorView];
    [_activityIndicatorView startAnimating];
    
    UILabel *_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
    _captionLabel.backgroundColor = [UIColor clearColor];
    _captionLabel.textColor = [UIColor whiteColor];
    _captionLabel.adjustsFontSizeToFitWidth = YES;
    _captionLabel.textAlignment = UITextAlignmentCenter;
    _captionLabel.text = @"Loading...";
    [_hudView addSubview:_captionLabel];
}

- (IBAction)back:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnAction:(id)sender {
    if([self.BtnAction.titleLabel.text isEqualToString:@"Follow"])
        [self followShow];
    else
        [self removeShow];
}

-(void)followShow{
    @try
    {
        NSString *jsonString =[NSString stringWithFormat: @"{'showId':'%@','email':'%@'}",showId,[StoredVars sharedInstance].userId];
        
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL:addShow];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        [request addValue:@"application/json"forHTTPHeaderField:@"Content-Type" ];
        [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"tabMyShows" object:self];
            [self dismissModalViewControllerAnimated:YES];
        });
    }
    @catch (NSException *ex) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, we can't add it, Try again"]
                                                            delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        NSLog(@"-----%@---------",ex);
        [alert show];
    }
}

-(void)removeShow{
    @try
    {
        NSString *removeUri =[NSString stringWithFormat: @"%@?showId=%@&email=%@",deleteShow,showId,[StoredVars sharedInstance].userId];
        
        NSURL *removeShow= [NSURL URLWithString: removeUri];
        
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL:removeShow];
        
        [request setHTTPMethod:@"DELETE"];
        [request addValue:@"application/json"forHTTPHeaderField:@"Content-Type" ];
        [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"tabMyShows" object:self];
            [self dismissModalViewControllerAnimated:YES];       
        });
    }
    @catch (NSException *ex) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, we can't add it, Try again"]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        NSLog(@"-----%@---------",ex);
        [alert show];
    }

}


-(void)getEpisodesByShowId
{
    //Loading spinner
    [self.view addSubview:_hudView];
    //Callout block
    dispatch_async(kBgQueue, ^{
        NSString *apiEpisodes;
        apiEpisodes= [NSString stringWithFormat:@"%@?episodeId=%@&email=%@",showEpisode,EpisodeId,[StoredVars sharedInstance].userId];
        NSData* data= [NSData dataWithContentsOfURL:[NSURL URLWithString:apiEpisodes]];
        if(data!=nil)
            [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:NO];
    });
}

@end
