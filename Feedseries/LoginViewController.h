//
//  LoginViewController.h
//  Feedseries
//
//  Created by Brian Krochik on 18/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *InputMail;
@property (weak, nonatomic) IBOutlet UITextField *InputPass;
@property (weak, nonatomic) IBOutlet UITextField *InputConfPass;
@property (weak, nonatomic) IBOutlet UIButton *BtnLogin;
@property (weak, nonatomic) IBOutlet UILabel *BtnLblNew;
@property (weak, nonatomic) IBOutlet UIButton *BtnRegister;
@property (weak, nonatomic) IBOutlet UILabel *BtnLblLogin;

@end
