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
#define newUserURL [NSURL URLWithString: @"http://feedseries.herokuapp.com/newUser"]
#define setSmartURL [NSURL URLWithString: @"http://feedseries.herokuapp.com/setSmartPhone"]

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
    
    //Init reveal menu
    NSDictionary *options = @{
                              PKRevealControllerAllowsOverdrawKey : [NSNumber numberWithBool:YES],
                              PKRevealControllerDisablesFrontViewInteractionKey : [NSNumber numberWithBool:YES]
                              };
    
    UIViewController *leftViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MySettings"];
    
    UINavigationController *frontViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MySeries"];
    
    revealController = [PKRevealController revealControllerWithFrontViewController:frontViewController leftViewController:leftViewController options:options];
    
    
    //Add handlers
    self.BtnLblNew.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRegister =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToRegister)];
    [self.BtnLblNew addGestureRecognizer:tapGestureRegister];
    self.BtnLblLogin.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureLogin =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToLogin)];
    [self.BtnLblLogin addGestureRecognizer:tapGestureLogin];
    
    //Inicializo componentes
    self.InputMail.delegate = self;
    self.InputPass.delegate = self;
    self.InputConfPass.delegate = self;
}

- (IBAction)BtnLogin:(id)sender {
    
    if(![self.InputMail.text isEqualToString:@""] && ![self.InputPass.text isEqualToString:@""]){
        //Loading spinner
        [self.view addSubview:_hudView];
        
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
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Please fill the gaps and try it again"]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
}

- (IBAction)BtnRegister:(id)sender {
    if(![self.InputMail.text isEqualToString:@""] && ![self.InputPass.text isEqualToString:@""] && ![self.InputConfPass.text isEqualToString:@""]){
        [self registerUser];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Please fill the gaps and try it again"]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

//Save appleId
- (void) registerUser
{
    //Loading spinner
    [self.view addSubview:_hudView];
    @try
    {
        if([self.InputPass.text isEqualToString:self.InputConfPass.text]){
            NSString *jsonString =[NSString stringWithFormat: @"{'email':'%@','pass':'%@','smartType':'apple','smartId':'%@'}",self.InputMail.text,self.InputPass.text,[StoredVars sharedInstance].deviceToken];
            
            NSMutableURLRequest *request = [NSMutableURLRequest
                                            requestWithURL:newUserURL];
            
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
            [request addValue:@"application/json"forHTTPHeaderField:@"Content-Type" ];
            NSError        *error = nil;
            NSHTTPURLResponse* response = nil;
            
            [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
          
            //Check api response
            if([response statusCode]==200){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                    [self saveRegister:self.InputMail.text];
                });
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Data is wrong, please try again"]
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"The passwords are differet, please try again"]
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            //Hide Spinner
            [_hudView removeFromSuperview];
        }
    }
    @catch (NSException *ex) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, we can't sign you up, Try again"]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        NSLog(@"-----%@---------",ex);
        [alert show];
        //Hide Spinner
        [_hudView removeFromSuperview];
    }
}

- (void) goToRegister
{
    [self presentViewController:[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Register"] animated:YES completion:nil];
}

- (void) goToLogin
{
    [self presentViewController:[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MainStoryboard"] animated:YES completion:nil];
}

- (void) fetchedData:(NSData *)responseData {
    @try
    {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        jsonResults = [json objectForKey:@"data"];
        if([jsonResults objectForKey:@"email"]!=nil)
            [self saveLogin:[jsonResults objectForKey:@"email"]];
        
        NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
        NSString *deviceToken=[defaults  objectForKey:@"deviceToken"];
        if(![[jsonResults objectForKey:@"deviceToken"] isEqualToString:deviceToken])
            [self setAppleId];
    }
    @catch (NSException *ex) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error al intentar ingresar, intentelo nuevamente"]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        NSLog(@"-----%@---------",ex);
        [_hudView removeFromSuperview];
        [alert show];
    }
}

//Save after login
- (void)saveLogin:(NSString*)mail
{
    [StoredVars sharedInstance].userId=mail;
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    [defaults  setObject: [StoredVars sharedInstance].userId forKey:@"userLogued"];
    [defaults synchronize];
    [self presentViewController:revealController animated:YES completion:nil];
}

//Save after register
- (void)saveRegister:(NSString*)mail
{
    [StoredVars sharedInstance].userId=mail;
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    [defaults  setObject: [StoredVars sharedInstance].userId forKey:@"userLogued"];
    [defaults synchronize];
    [self presentViewController:revealController animated:YES completion:nil];
    PKRevealController *reveal =self.presentedViewController;
    UITabBarController *tab =reveal.frontViewController;
    [tab setSelectedIndex:2];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

//Save appleId
- (void) setAppleId
{
    @try
    {
        NSString *jsonString =[NSString stringWithFormat: @"{'email':'%@','smartId':'%@','smartType':'apple'}",[StoredVars sharedInstance].userId,[StoredVars sharedInstance].deviceToken];
        
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL:setSmartURL];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        [request addValue:@"application/json"forHTTPHeaderField:@"Content-Type" ];
        [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    }
    @catch (NSException *ex) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, we can't save your device token it, Try again"]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        NSLog(@"-----%@---------",ex);
        [alert show];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end