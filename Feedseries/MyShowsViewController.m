//
//  FirstViewController.m
//  Feedseries
//
//  Created by Brian Krochik on 15/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "myShowsViewController.h"
#import "EpisodeCell.h"
#import "StoredVars.h"
#import "PKRevealController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
#define allEpisodes [NSURL URLWithString: @"http://feedseries.herokuapp.com/getEpisodes"]
#define myEpisodes [NSURL URLWithString: @"http://feedseries.herokuapp.com/getEpisodesByUser"]

@interface MyShowsViewController ()
{
    NSArray *TitleLabel;
    NSArray *SubtitleLabel;
    NSMutableArray *jsonResults;
    NSInteger dataRows;
    NSInteger offset;
    NSInteger limit;
    UIActivityIndicatorView *spinner;
    NSURL *kjsonURL;    
}
@end

@implementation MyShowsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    if ([self.restorationIdentifier isEqualToString:@"myShows"])
        kjsonURL=[NSString stringWithFormat:@"%@?email=%@",myEpisodes,[StoredVars sharedInstance].userId];
    else
        kjsonURL=allEpisodes;
    
    //Init
    offset=0;
    limit=3;
    self.myShowsTable.dataSource=self;
    self.myShowsTable.delegate=self;
    self.InputSearch.delegate = self;
    
    //Callout
    dispatch_async(kBgQueue, ^{
        //Loading spinner
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = CGPointMake ( self.view.center.x, self.view.center.y );
        spinner.tag = 12;
        [self.view addSubview:spinner];
        [spinner startAnimating];
        NSString *apiEpisodes;
        //Callout
        if ([self.restorationIdentifier isEqualToString:@"myShows"])
            apiEpisodes= kjsonURL;
        else
            apiEpisodes= [NSString stringWithFormat:@"%@?offset=%ld&limit=%ld",kjsonURL,(long)offset,(long)limit];
        
        NSData* data= [NSData dataWithContentsOfURL:[NSURL URLWithString:apiEpisodes]];
        
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
            
    });

}

- (void) fetchedData:(NSData *)responseData {
    //Loading spinner
    [spinner startAnimating];
    
    if(responseData!=nil){
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        jsonResults = [json objectForKey:@"data"];
    }else{
        jsonResults= [NSMutableArray new];
    }
    
    //Stop Spinner
    [spinner stopAnimating];
    
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
        //Cell.episodeImage.image= [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[episode objectForKey:@"poster"]]]];;
    }else if( dataRows>1){
        Cell.title.text=@"Ver mas";
        Cell.subtitle.text=@"";
        Cell.episodeImage.image=nil;
    }else if(dataRows==0){
        Cell.title.text=@"No hay datos";
        Cell.subtitle.text=@"";
        Cell.episodeImage.image=nil;
    }
    
    return Cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Clouse search bar
    [_InputSearch resignFirstResponder];

    if(indexPath.row == dataRows && dataRows!=0){
        //More series
        limit+=limit;

        dispatch_async(kBgQueue, ^{
            //Callout
            NSString *apiEpisodes;
            if ([self.restorationIdentifier isEqualToString:@"myShows"])
                apiEpisodes= kjsonURL;
            else
                apiEpisodes= [NSString stringWithFormat:@"%@?offset=%ld&limit=%ld",kjsonURL,(long)offset,(long)limit];
            NSData* data= [NSData dataWithContentsOfURL:[NSURL URLWithString:apiEpisodes]];
            if(data!=nil)
                [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
        });
    }
}

- (IBAction)btnSettings:(id)sender {
    [self.parentViewController.revealController showViewController:self.parentViewController.revealController.leftViewController];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_InputSearch resignFirstResponder];
}

@end
