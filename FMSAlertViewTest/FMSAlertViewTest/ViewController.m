//
//  ViewController.m
//  FMSAlertManagerTest
//
//  Created by Rich Warren on 5/27/12.
//  Copyright (c) 2012 Freelance Mad Science Labs. All rights reserved.
//

#import "ViewController.h"
#import "FMSAlertManager/FMSAlertManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)showOneButtonAlert:(id)sender {
    
    [[FMSAlertManager sharedAlertManager] 
     showAlertWithTitle:@"One Button Alert" 
     message:@"This is an alert with a single button"
     autoClose:YES
     configurationBlock:^(AddButtonBlock addButton) {
         
         addButton(@"Cancel", ^{
             
             NSLog(@"One Button -- Cancel Button Pressed!");
             
         });
         
     }];
    
}

- (IBAction)showTwoButtonAlert:(id)sender {
    
    
    [[FMSAlertManager sharedAlertManager] 
     showAlertWithTitle:@"Two Button Alert" 
     message:@"This is an alert with two buttons"
     autoClose:YES
     configurationBlock:^(AddButtonBlock addButton) {
         
         addButton(@"OK", ^{
            
             NSLog(@"Two Button -- OK Button Pressed!");
             
         });
         
         addButton(@"Cancel", ^{
             
             NSLog(@"Two Button -- Cancel Button Pressed!");
             
         });
         
     }];
}

- (IBAction)showThreeButtonAlert:(id)sender {
    
    
    [[FMSAlertManager sharedAlertManager] 
     showAlertWithTitle:@"Three Button Alert" 
     message:@"This is an alert with three buttons"
     autoClose:YES
     configurationBlock:^(AddButtonBlock addButton) {
         
         addButton(@"OK", ^{
             
             NSLog(@"Three Button -- OK Button Pressed!");
             
         });
         
         addButton(@"Maybe", ^{
             
             NSLog(@"Three Button -- Maybe Button Pressed!");
             
         });
         
         addButton(@"Ask Again", ^{
            
             NSLog(@"Three Button -- Ask Again Pressed!");
             
         });
         
     }];
}

- (IBAction)showFourButtonAlert:(id)sender {
    
    
    [[FMSAlertManager sharedAlertManager] 
     showAlertWithTitle:@"Four Button Alert" 
     message:@"This is an alert with four buttons"
     autoClose:YES
     configurationBlock:^(AddButtonBlock addButton) {
         
         addButton(@"OK", ^{
             
             NSLog(@"Four Button -- OK Button Pressed!");
             
         });
         
         addButton(@"Maybe", ^{
             
             NSLog(@"Four Button -- Maybe Button Pressed!");
             
         });
         
         addButton(@"Ask Again", ^{
             
             NSLog(@"Four Button -- Ask Again Pressed!");
             
         });
         
         // This one dismisses the alert, but doesn't do anything else.
         addButton(@"Quit Bothering Me!", nil);
         
     }];
}


- (IBAction)showNoButtonAlert:(id)sender {
    
    [[FMSAlertManager sharedAlertManager] 
     showAlertWithTitle:@"An alert without any buttons" 
     message:@"This is an alert without any buttons."
     autoClose:YES
     configurationBlock:nil];    
}

@end
