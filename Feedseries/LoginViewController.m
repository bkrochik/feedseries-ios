//
//  LoginViewController.m
//  Feedseries
//
//  Created by Brian Krochik on 18/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "LoginViewController.h"
#import "StoredVars.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
#define kjsonURL [NSURL URLWithString: @"http://feedseries.herokuapp.com/getUser"]

@interface LoginViewController ()
{
    IBOutlet UIButton *BtnLogin;
    NSDictionary *jsonResults;
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
    self.InputMail.delegate = self;
    self.InputPass.delegate = self;
    if ([self isLogged]==true) {
        [self performSegueWithIdentifier:@"MySeries" sender:self];
    }
}

- (IBAction)BtnLogin:(id)sender {
    //Callout login
    NSError* error = nil;
    NSString *loginUri= [NSString stringWithFormat:@"%@?email=%@&pass=%@",kjsonURL,self.InputMail.text,self.InputPass.text];
    NSData* data= [NSData dataWithContentsOfURL:[NSURL URLWithString:loginUri] options:NSDataReadingUncached error:&error];
    [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    
    if (error) {
        NSLog(@"---------%@", [error localizedDescription]);
    } else {
        NSLog(@"Data has loaded successfully.");
    }
}

- (void) fetchedData:(NSData *)responseData {
    @try
    {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        jsonResults = [json objectForKey:@"data"];
        if(jsonResults!=[jsonResults objectForKey:@"email"])
            [self saveLogin];
    }
    @catch (NSException *ex) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error al intentar ingresar, intentelo nuevamente"]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

//Save
- (void)saveLogin
{
    NSString *saveString=self.InputMail.text;
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    [defaults  setObject:saveString forKey:@"userLogued"];
    [defaults synchronize];
    [self performSegueWithIdentifier:@"MySeries" sender:self];
}

//Check if user is logged
- (BOOL)isLogged
{
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    NSString *loadString=[defaults  objectForKey:@"userLogued"];
    if([loadString isEqualToString:@"666"])
        return false;
    else{
        [StoredVars sharedInstance].userId=loadString;
        return true;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
