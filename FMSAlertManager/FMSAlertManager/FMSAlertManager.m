//    Copyright (c) 2012, Richard Warren
//    All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without modification,
//    are permitted provided that the following conditions are met:
//
//        * Redistributions of source code must retain the above copyright notice, this
//          list of conditions and the following disclaimer.
//
//        * Redistributions in binary form must reproduce the above copyright notice,
//          this list of conditions and the following disclaimer in the documentation
//          and/or other materials provided with the distribution.
//
//        * Neither the name of the <ORGANIZATION> nor the names of its contributors may
//          be used to endorse or promote products derived from this software without
//            specific prior written permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//    SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//    STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
//    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#if !__has_feature(objc_arc)
#error AFNetworking must be built with ARC.
// You can turn on ARC for only AFNetworking files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "FMSAlertManager.h"

typedef NSString FMSAlertID; /**< Used to identify an active UIAlertView */

/**
 * @brief Private propreties for FMSAlertManager
 *
 * These are the private, internal properties used by FMSAlertManager.
 */

@interface FMSAlertManager ()

/** A private property that stores the active UIAlertView instances, indexed by RWAlertID */
@property (strong, nonatomic) NSMutableDictionary *alerts;

/** A private property that stores an array of button action blocks, indexed by RWAlertID */
@property (strong, nonatomic) NSMutableDictionary *blockLists;   

/** A private property that stores the observer for the UIApplicationDidEnterBackgroundNotification */
@property (strong, nonatomic) id enterBackgroundObserver;       

/** 
 * A private property that stores an array of UIAlertViews that 
 * should be closed when the app goes into the background 
 */

@property (strong, nonatomic) NSMutableArray *viewsToAutoClose; 

@end

@implementation FMSAlertManager


// The designated initializer
- (id)init
{
    self = [super init];
    
    if (self) {
            
        _alerts = [NSMutableDictionary dictionary];
        _blockLists = [NSMutableDictionary dictionary];
        _viewsToAutoClose = [NSMutableArray array];

        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        _enterBackgroundObserver =
        [center addObserverForName:UIApplicationDidEnterBackgroundNotification
                            object:[UIApplication sharedApplication]
                             queue:[NSOperationQueue mainQueue]
                        usingBlock:^(NSNotification *note) {
                            [self autoCloseBeforeEnteringBackground];
                        }];
    }
    
    return self;
}

// Just used to remove the UIApplicationDidEnterBackgroundNotification observer
- (void)dealloc {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self.enterBackgroundObserver];
}

#pragma mark - Public Methods


+ (id)sharedAlertManager {
    
    static FMSAlertManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[self alloc] init];
        
    });
    
    return manager;
}

- (id)showAlertWithTitle:(NSString *)title
                 message:(NSString *)message
               autoClose:(BOOL)autoClose
      configurationBlock:(void (^)(AddButtonBlock addButton))config {
    
    // Setup
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    
    FMSAlertID *key = [self keyForAlertView:alert];
    NSMutableArray *blockList = [NSMutableArray array];
    
    // Build the config blocks
    AddButtonBlock addButton = [self createAddButtonBlockForAlertView:alert
                                                         andBlockList:blockList];
    
    // Call the config block
    if (config != nil) config(addButton);
    
    // Save Data
    [self.alerts setObject:alert forKey:key];
    [self.blockLists setObject:blockList forKey:key];
    
    // Display the view
    [alert show];
    
    
    // if it doesn't have any buttons, autodismiss it
    if (alert.numberOfButtons == 0) {
        
        [self autoDismissAlertView:alert];
    }
    
    if (autoClose) {
        [self.viewsToAutoClose addObject:alert];
    }
    
    return alert;
}

#pragma mark - Private Methods

// Generates a unique key for the alert view by combining the view's title with it's pointer.
-(FMSAlertID *)keyForAlertView:(UIAlertView *)view {
    
    return [view.title stringByAppendingFormat:@" <%p>", view];
    
}

// Generates a properly formatted AddButtonBlock.
- (AddButtonBlock)createAddButtonBlockForAlertView:(UIAlertView *)alert 
                                      andBlockList:(NSMutableArray *)blockList {
    
    return ^(NSString *title, ResponseBlock block){
        
        [alert addButtonWithTitle:title];
        
        if (block != nil) {
            
            [blockList addObject:block];
            
        } else {
            
            [blockList addObject:^{}];
            
        }
    };
}

// Automatically dismisses the provided alert view after 2.0 seconds
- (void)autoDismissAlertView:(UIAlertView *)alert
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = 
    dispatch_time(DISPATCH_TIME_NOW, 
                  (long long)(delayInSeconds * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [alert dismissWithClickedButtonIndex:-1 animated:YES];
        
    });
}

// Processes non-negative button presses. It will get the array of blocks for the given alert view,
// then get the block from the array. Finally it fires the block. Note: each button must have a valid block,
// even if it is a no-op ^{}.

-(void)processButtonPress:(NSInteger)buttonIndex forAlertKey:(FMSAlertID *)key {
    
    // Ignore negative indicies
    if (buttonIndex < 0) return;
    
    NSArray *blocks = [self.blockLists objectForKey:key];
    ResponseBlock block = [blocks objectAtIndex:buttonIndex];
    
    block();
}

// This method is triggered when the app is going into the background. It dismisses any
// auto-closing alert views.
- (void)autoCloseBeforeEnteringBackground {
    
    NSArray *alerts = [self.viewsToAutoClose copy];
    
    for (UIAlertView *alert in alerts) {
        [alert dismissWithClickedButtonIndex:-1 animated:NO];
    }
    
    [self.viewsToAutoClose removeAllObjects];
}

#pragma mark - UIAlertViewDelegate Methods

// This method is called whenver a button is pressed on one of the FMSAlertManager's alert views. Currently, we always perform actions
// after the alert view is dismissed. If you want to trigger actions to start before the alert view is dismissed, you would need to
// modify this library (e.g. modify the AddButtonBlock so that it took blocks for both pre- and post- dismiss actions.

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    FMSAlertID *key = [self keyForAlertView:alertView];
    [self processButtonPress:buttonIndex forAlertKey:key];

    // Now remove the alert and it's blocks -- deleting them from memory
    [self.alerts removeObjectForKey:key];
    [self.blockLists removeObjectForKey:key];
    [self.viewsToAutoClose removeObject:alertView];
    
}

@end
