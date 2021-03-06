//
//  NewsViewController.m
//  Feedseries
//
//  Created by Brian Krochik on 22/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "NewsViewController.h"
#import "EpisodeCell.h"
#import "ShowViewController.h"
#import "StoredVars.h"
#import "UIImageView+WebCache.h"
#import "PKRevealController.h"
#import <QuartzCore/QuartzCore.h>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
#define newsEpisodes [NSURL URLWithString: @"http://feedseries.herokuapp.com/getMessages"]
#define deleteEpisodes [NSURL URLWithString: @"http://feedseries.herokuapp.com/messageDeleteToUser"]

@interface NewsViewController ()
{
    NSArray *TitleLabel;
    NSArray *SubtitleLabel;
    NSMutableArray *jsonResults;
    NSInteger dataRows;
    NSInteger offset;
    NSInteger page;
    NSInteger limit;
    UIActivityIndicatorView *_activityIndicatorView;
    UIView *_hudView;
    NSIndexPath *selectedPath;
}

@end

@implementation NewsViewController
@synthesize newsTable=_newsTable;

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
    
    //Init
    offset=0;
    limit=100;
    page=5;
    
    self.newsTable.dataSource=self;
    self.newsTable.delegate=self;
    
    //Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMessages) name:@"refreshNews" object:nil];

    //Init spinner
    [self loadSpinner];
    
    //Loading spinner
    [self.view addSubview:_hudView];
    
    //Get episodes
    [self getMessages];
    
    //Init refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor =  [UIColor blackColor];
    [refreshControl addTarget:nil action:@selector(updateArray) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

//Refresh list of news
-(void) updateArray{
    [self getMessages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//Table and Cell styles
- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    //CELLs
    cell.backgroundColor =[UIColor colorWithPatternImage: [UIImage imageNamed: @"cell-gradient3.png"]];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    //TABLEVIEW
    tableView.separatorColor= [UIColor colorWithRed: (12/255) green:(12/255) blue: (12/255) alpha: 1.0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    dataRows=[jsonResults count];
    if(dataRows==0)
        return dataRows+1;
    else
        return dataRows;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier= @"Cell";
    static NSString *BtnCellIdentifier= @"BtnCel";
    EpisodeCell *Cell;
    
    if(indexPath.row<dataRows){
        Cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(!Cell){
            Cell= [[EpisodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        NSDictionary *episode =[jsonResults objectAtIndex:indexPath.row];
        Cell.title.text= [NSString stringWithFormat:@"%@", [episode objectForKey:@"showTitle"]];
        Cell.subtitle.text=[NSString stringWithFormat:@"%@", [episode objectForKey:@"title"]];
        Cell.restorationIdentifier= [NSString stringWithFormat:@"%@", [episode objectForKey:@"messageId"]];
        Cell.BtnRemove.restorationIdentifier= [NSString stringWithFormat:@"%@", [episode objectForKey:@"messageId"]];
        Cell.episode.text=[NSString stringWithFormat:@"%@", [episode objectForKey:@"number"]];
        Cell.season.text=[NSString stringWithFormat:@"%@", [episode objectForKey:@"season"]];
        Cell.date.text=[NSString stringWithFormat:@"%@", [episode objectForKey:@"firstAired"]];
        Cell.allEpisodeNumber.text=[NSString stringWithFormat:@"%@x%@ ",[episode objectForKey:@"season"], [episode objectForKey:@"number"]];
        
        [Cell.episodeImage setImageWithURL:[NSURL URLWithString:[episode objectForKey:@"poster"]] placeholderImage:[UIImage imageNamed:@"stub.png"]];
    }else if(dataRows==0){
        Cell =[tableView dequeueReusableCellWithIdentifier:BtnCellIdentifier];
        
        if(!Cell){
            Cell= [[EpisodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BtnCellIdentifier];
        }
        
        Cell.title.text=@"Pull for more news";
    }
    
    return Cell;
}

//Height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row<dataRows){
        return 128;
    }else if(dataRows==0){
        return 50;
    }
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// 1 = Tapped yes
	if (buttonIndex == 1)
	{
        EpisodeCell *cell = [self.newsTable cellForRowAtIndexPath:selectedPath];
        NSUInteger row = [selectedPath row];  
        if (row < dataRows) {
            dispatch_async(kBgQueue, ^{
                [self removeNew:cell.restorationIdentifier];
            });
            [jsonResults removeObjectAtIndex:row];
            [self.newsTable reloadData];
        }
	}
}

-(void)removeNew:(NSString *)messageId{
    @try
    {
        NSString *deleteNewURI =[NSString stringWithFormat: @"%@?messageId=%@",deleteEpisodes,messageId];
        
        NSURL *removeShow= [NSURL URLWithString: deleteNewURI];
        
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL:removeShow];
        
        [request setHTTPMethod:@"DELETE"];
        [request addValue:@"application/json"forHTTPHeaderField:@"Content-Type" ];
        [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    }
    @catch (NSException *ex) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, we can't add it, Try again"]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        NSLog(@"-----%@---------",ex);
        [alert show];
        [self getMessages];
    }
    
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

- (void) fetchedData:(NSData *)responseData {
    
    if(responseData!=nil){
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        jsonResults = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"data"]];
    }else{
        jsonResults= [NSMutableArray new];
    }
    
    //Stop Spinner
    [_hudView removeFromSuperview];
    [self.refreshControl endRefreshing];
  
    //Reload table
    [self.newsTable reloadData];
}

- (void) getMessages
{
    //Callout block
    dispatch_async(kBgQueue, ^{
        NSString *apiEpisodes;
        apiEpisodes= [NSString stringWithFormat:@"%@?offset=%ld&limit=%ld&email=%@",newsEpisodes,(long)offset,(long)limit,[StoredVars sharedInstance].userId];
        NSData* data= [NSData dataWithContentsOfURL:[NSURL URLWithString:apiEpisodes]];
        if(data!=nil)
            [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
        //Stop Spinner
        [_hudView removeFromSuperview];
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(dataRows!=0){
        selectedPath =indexPath;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Watchout!"
                                                           message:@"Did you watch it?"
                                                          delegate:self
                                                 cancelButtonTitle:@"No"
                                                 otherButtonTitles:@"Yes",nil];
        [alert show];
    }
}

@end
