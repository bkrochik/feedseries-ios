//
//  FirstViewController.m
//  Feedseries
//
//  Created by Brian Krochik on 15/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "MyShowsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "EpisodeCell.h"
#import "StoredVars.h"
#import "UIImageView+WebCache.h"
#import "ShowViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
#define allEpisodes [NSURL URLWithString: @"http://feedseries.herokuapp.com/getEpisodes"]
#define myEpisodes [NSURL URLWithString: @"http://feedseries.herokuapp.com/getEpisodesByUser"]
#define showEpisodes [NSURL URLWithString: @"http://feedseries.herokuapp.com/getEpisodesByShow"]



@interface MyShowsViewController ()
{
    NSArray *TitleLabel;
    NSArray *SubtitleLabel;
    NSMutableArray *jsonResults;
    NSInteger dataRows;
    NSInteger offset;
    NSInteger limit;
    NSURL *kjsonURL;
    UIActivityIndicatorView *_activityIndicatorView;
    UIView *_hudView;
}
@end

@implementation MyShowsViewController

@synthesize InputSearch=_InputSearch;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Init
    offset=0;
    limit=5;
    self.myShowsTable.dataSource=self;
    self.myShowsTable.delegate=self;
    self.InputSearch.delegate = self;
    
    
    //Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabMyShows) name:@"tabMyShows" object:nil];
    
    [self loadSpinner];
    
    if ([self.restorationIdentifier isEqualToString:@"myShows"])
        kjsonURL=[NSString stringWithFormat:@"%@?email=%@",myEpisodes,[StoredVars sharedInstance].userId];
    else
         kjsonURL=allEpisodes;
   
    //Get episodes
    [self getEpisodes];
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
        jsonResults = [json objectForKey:@"data"];
    }else{
        jsonResults= [NSMutableArray new];
    }
    
    //Stop Spinner
    [_hudView removeFromSuperview];
    
    //Reload table
    [self.myShowsTable reloadData];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    dataRows=[jsonResults count];
    return dataRows+1;
}

//Table and Cell styles
- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    //CELLs
    cell.backgroundColor =[UIColor colorWithPatternImage: [UIImage imageNamed: @"cell-gradient2.png"]];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    //TABLEVIEW
    tableView.separatorColor= [UIColor colorWithRed: (12/255) green:(12/255) blue: (12/255) alpha: 1.0];
}

//Carga las celdas de la table
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
        Cell.restorationIdentifier= [NSString stringWithFormat:@"%@", [episode objectForKey:@"id"]];
        Cell.episode.text=[NSString stringWithFormat:@"%@", [episode objectForKey:@"number"]];
        Cell.season.text=[NSString stringWithFormat:@"%@", [episode objectForKey:@"season"]];
        Cell.date.text=[NSString stringWithFormat:@"%@", [episode objectForKey:@"firstAired"]];
        Cell.allEpisodeNumber.text=[NSString stringWithFormat:@"%@x%@ ",[episode objectForKey:@"season"], [episode objectForKey:@"number"]];
        //Image
        [Cell.episodeImage setImageWithURL:[NSURL URLWithString:[episode objectForKey:@"poster"]] placeholderImage:[UIImage imageNamed:[episode objectForKey:@"showTitle"]]];
        
    }else if( dataRows>=1){
        Cell =[tableView dequeueReusableCellWithIdentifier:BtnCellIdentifier];
        
        if(!Cell){
            Cell= [[EpisodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BtnCellIdentifier];
        }
        
        Cell.title.text=@"Show more";
    }else if(dataRows==0){
        Cell =[tableView dequeueReusableCellWithIdentifier:BtnCellIdentifier];
        
        if(!Cell){
            Cell= [[EpisodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BtnCellIdentifier];
        }
        
        Cell.title.text=@"Not data available";
    }
    
    return Cell;
}

//Height of cells
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row<dataRows){
        return 100;
    }else if( dataRows>=1){
        return 50;
    }else if(dataRows==0){
        return 50;
    }
}

//Evento cuando se selecciona una celda
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == dataRows && dataRows!=0){
        //More series
        limit+=limit;
        if(_InputSearch.text!=nil  && [_InputSearch.text length] != 0)
            [self getEpisodesByShow];
        else
            [self getEpisodes];
    }else if([_InputSearch showsCancelButton]==NO){
        EpisodeCell *cell = [tableView cellForRowAtIndexPath:indexPath];

        if(![cell.subtitle.text isEqualToString:@""]){
            ShowViewController *showController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Show"];
            showController.EpisodeId=cell.restorationIdentifier;
            showController.BackStoryId=self.restorationIdentifier;
            //Check if i will show show detail or episode
            if ([self.restorationIdentifier isEqualToString:@"myShows"])
                showController.ShowDetail=@"NO";
            else
                showController.ShowDetail=@"YES";
            
            [self presentViewController:showController animated:YES completion:nil];
        }
    }
    
    //Close search bar
    [_InputSearch resignFirstResponder];
    [_InputSearch setShowsCancelButton:NO animated:YES];

}

//Notifiactions
- (void) tabMyShows
{
    UITabBarController *tab= self.parentViewController;
    [tab setSelectedIndex:1];
    limit=5;
    [self getEpisodes];
}

//Search bar
- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton=YES;
}

//Buttton search 
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.restorationIdentifier isEqualToString:@"myShows"])
        limit=5;
    else
        limit=1;
    
    jsonResults= [NSMutableArray new];
    
    [self getEpisodesByShow];
    
    searchBar.showsCancelButton=NO;
    
    [_InputSearch resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    limit=5;
    [self getEpisodes];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

//Btn Refresh
- (IBAction)BtnRefresh:(id)sender {
    [self getEpisodes];
}

-(void)getEpisodesByShow
{
    //init spinner
    [self.view addSubview:_hudView];
    
    dispatch_async(kBgQueue, ^{
        NSString *apiEpisodes;
        apiEpisodes= [NSString stringWithFormat:@"%@?offset=%ld&limit=%ld&email=null&title=%@",showEpisodes,(long)offset,(long)limit,_InputSearch.text];
        NSString *apiEpisodesEncoded = [apiEpisodes stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData* data= [NSData dataWithContentsOfURL:[NSURL URLWithString:apiEpisodesEncoded]];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:NO];
    });
}

-(void)getEpisodes
{
    //Loading spinner
    [self.view addSubview:_hudView];
    
    //Callout
    dispatch_async(kBgQueue, ^{
        NSString *apiEpisodes;
        //Callout
        if ([self.restorationIdentifier isEqualToString:@"myShows"])
            apiEpisodes= [NSString stringWithFormat:@"%@&offset=%ld&limit=%ld",kjsonURL,(long)offset,(long)limit];
        else
            apiEpisodes= [NSString stringWithFormat:@"%@?offset=%ld&limit=%ld",kjsonURL,(long)offset,(long)limit];
        
        NSData* data= [NSData dataWithContentsOfURL:[NSURL URLWithString:apiEpisodes]];
        
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:NO];
    });
}

@end
