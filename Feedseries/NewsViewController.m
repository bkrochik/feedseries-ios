//
//  NewsViewController.m
//  Feedseries
//
//  Created by Brian Krochik on 22/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "NewsViewController.h"
#import "EpisodeCell.h"
#import "StoredVars.h"
#import "UIImageView+WebCache.h"
#import "PKRevealController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
#define newsEpisodes [NSURL URLWithString: @"http://feedseries.herokuapp.com/getMessages"]

@interface NewsViewController ()
{
    NSArray *TitleLabel;
    NSArray *SubtitleLabel;
    NSMutableArray *jsonResults;
    NSInteger dataRows;
    NSInteger offset;
    NSInteger page;
    NSInteger limit;
    UIActivityIndicatorView *spinner;
}

@end

@implementation NewsViewController

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
    
    //Init
    offset=0;
    limit=100;
    page=5;
    
    self.newsTable.dataSource=self;
    self.newsTable.delegate=self;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor =  [UIColor whiteColor];
    [refreshControl addTarget:nil action:@selector(updateArray) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    //Loading spinner
    [spinner startAnimating];
    
    //Get episodes
    [self getMessages];
    
    //Stop Spinner
    [spinner stopAnimating];
}

-(void) updateArray{
    [self getMessages];
    [self.refreshControl endRefreshing];
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

- (void) fetchedData:(NSData *)responseData {
    if(responseData!=nil){
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        jsonResults = [json objectForKey:@"data"];
    }else{
        jsonResults= [NSMutableArray new];
    }
    
    [self.newsTable reloadData];
}

//Table and Cell styles
- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    //CELLs
    cell.backgroundColor =[UIColor colorWithPatternImage: [UIImage imageNamed: @"cell-gradient.png"]];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    //TABLEVIEW
    tableView.separatorColor= [UIColor colorWithRed: (12/255) green:(12/255) blue: (12/255) alpha: 1.0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    dataRows=[jsonResults count];
    return dataRows+1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier= @"Cell";
    
    EpisodeCell *Cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!Cell){
        Cell= [[EpisodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.row<dataRows){
        NSDictionary *episode =[jsonResults objectAtIndex:indexPath.row];
        Cell.title.text= [NSString stringWithFormat:@"%@ - %@ ", [episode objectForKey:@"showTitle"], [episode objectForKey:@"firstAired"]];
        Cell.subtitle.text=[NSString stringWithFormat:@"%@  %@x%@ ", [episode objectForKey:@"title"], [episode objectForKey:@"season"], [episode objectForKey:@"number"]];
        
        [Cell.episodeImage setImageWithURL:[NSURL URLWithString:[episode objectForKey:@"poster"]] placeholderImage:[UIImage imageNamed:[episode objectForKey:@"showTitle"]]];
        
    }else if( dataRows>=1){
        Cell.title.text=@"Ver mas";
        Cell.subtitle.text=@"";
        Cell.episodeImage.image=nil;
    }else if(dataRows==0){
        Cell.title.text=@"No hay datos";
        Cell.subtitle.text=@"";
        Cell.episodeImage.image=nil;
    }
    
    Cell.backgroundColor = [UIColor redColor];
    return Cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
       
}

//Load Spinner
- (void) loadSpinner
{
    //Loading spinner
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake ( self.view.center.x, self.view.center.y );
    spinner.tag = 12;
    [self.view addSubview:spinner];
}

- (void) getMessages
{
    //Callout
    dispatch_async(kBgQueue, ^{
        NSURL *kjsonURL= [NSString stringWithFormat:@"%@?offset=%ld&limit=%ld&email=%@",newsEpisodes,(long)offset,(long)limit,[StoredVars sharedInstance].userId];
        //Callout
        NSData* data= [NSData dataWithContentsOfURL:[NSURL URLWithString:kjsonURL]];
        
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });

}

@end
