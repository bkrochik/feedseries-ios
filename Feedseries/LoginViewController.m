//
//  LoginViewController.m
//  Feedseries
//
//  Created by Brian Krochik on 18/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "LoginViewController.h"
#import "StoredVars.h"
#import "PKRevealController.h"
#import <QuartzCore/QuartzCore.h>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
#define kjsonURL [NSURL URLWithString: @"http://feedseries.herokuapp.com/getUser"]

@interface LoginViewController ()
{
    IBOutlet UIButton *BtnLogin;
    NSDictionary *jsonResults;
    PKRevealController *revealController;
    UIActivityIndicatorView *_activityIndicatorView;
    UIView *_hudView;
}
@end

@implementation LoginViewController

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
    
    //Genero menu lateral
    NSDictionary *options = @{
                              PKRevealControllerAllowsOverdrawKey : [NSNumber numberWithBool:YES],
                              PKRevealControllerDisablesFrontViewInteractionKey : [NSNumber numberWithBool:YES]
                              };
    
    //Init reveal menu
    UIViewController *leftViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MySettings"];
    
    UINavigationController *frontViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MySeries"];
    
    revealController = [PKRevealController revealControllerWithFrontViewController:frontViewController leftViewController:leftViewController options:options];
    
    //Inicializo componentes
    self.InputMail.delegate = self;
    self.InputPass.delegate = self;
}

- (IBAction)BtnLogin:(id)sender {    
    //Callout login
    NSError* error = nil;
    NSString *loginUri= [NSString stringWithFormat:@"%@?email=%@&pass=%@",kjsonURL,self.InputMail.text,self.InputPass.text];

    NSData* data= [NSData dataWithContentsOfURL:[NSURL URLWithString:loginUri] options:NSDataReadingUncached error:&error];
    [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:NO];
    
    if (error) {
        NSLog(@"---------%@", [error localizedDescription]);
    } else {
        NSLog(@"Data has loaded successfully.");
    }
}

- (void) fetchedData:(NSData *)responseData {
    //Loading spinner
    [self.view addSubview:_hudView];
    @try
    {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        jsonResults = [json objectForKey:@"data"];
        if([jsonResults objectForKey:@"email"]!=nil)
            [self saveLogin:[jsonResults objectForKey:@"email"]];
    }
    @catch (NSException *ex) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error al intentar ingresar, intentelo nuevamente"]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        NSLog(@"-----%@---------",ex);
        [_hudView removeFromSuperview];
        [alert show];
    }
}

//Save
- (void)saveLogin:(NSString*)mail
{
    [StoredVars sharedInstance].userId=mail;
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    [defaults  setObject: [StoredVars sharedInstance].userId forKey:@"userLogued"];
    [defaults synchronize];
    [self presentViewController:revealController animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end