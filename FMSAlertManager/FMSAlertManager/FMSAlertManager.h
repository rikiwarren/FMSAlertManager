//
//  FMSAlertManager.h
//  FMSAlert
//
//  Created by Rich Warren on 5/27/12.
//  Copyright (c) 2012 Freelance Mad Science Labs. All rights reserved.

/**
 * @file FMSAlertManager.h
 * The public interface for FMSAlertManager.
 */


#import <UIKit/UIKit.h>

/**
 * @var typedef ResponseBlock
 * @brief A block that is called when the alert view's button is pressed.
 *
 * `ResponseBlock`s are simply blocks that don't take any arguments and don't return any values. 
 * `FMSAlertManager` uses `ResponseBlock`'s to define the actions that will be triggered when the
 * corresponding `UIAlertView` button is pressed.
 */

typedef void (^ResponseBlock) (void);

/**
 * @var typedef AddButtonBlock
 * @brief A block used to add buttons to a `UIAlertView`.
 *
 * @param title An `NSString` containing the button's title.
 * @param response A `ResponseBlock` defining the action that will be triggered when the button is pressed. This can be `nil`.
 *
 * `AddButtonBlock`s are passed to the `showAlertWithTitle:message:autoClose:configurationBlock:`'s configuration block.
 * You can call this block to add buttons to the alert view. 
 */
typedef void (^AddButtonBlock) (NSString *title, ResponseBlock response);

/**
 * @class FMSAlertManager
 * @brief Instantiates, displays and manages a set of `UIAlertViews`
 *
 * `FMSAlertManager` is a singleton class. It is used to instantiate, configure
 * and display `UIAlertView`s. It can also auto-close alert views when the
 * application goes to the background.
 *
 * `FMSAlertManager` lets us replace the normal delegate-based API for alerts with
 * a more conveniant block-based API. This lets us easily create a `UIAlertView`, and define
 * both the buttons and the actions that will be triggered in one place.
 */

@interface FMSAlertManager : NSObject <UIAlertViewDelegate>

/**
 * @brief Accessor for `FMSAlertManager` singleton method.
 * @return a reference to the `FMSAlertManager` singleton.
 *
 * This gives us access to the shared `FMSAlertManager` instance. We can then use this instance to 
 * create, configure, display and manage our alert views.
 */

+ (id)sharedAlertManager;

/**
 * @brief A one-stop method to create a `UIAlertView` instance, 
 * configure its buttons and button actions, and then display the 
 * alert view.
 *
 * @param title An `NSString` containing the `UIAlertView`'s title
 * @param message An `NSString` containing the `UIAlertView`'s message
 * @param autoClose A `BOOL`. If `YES` the `FMSAlertManager` will automatically dismiss the view if the app goes into the background.
 * @param config A block used to configure the `UIAlertView`'s buttons. This block takes a single argument, which is also an `AddButtonBlock` block. We can call this block to add buttons to our `UIAlertView`. Buttons are added in order. The first button added is at index 0. The second at index 1, etc.
 *
 * @return a reference to the UIAlertView. We can, optionally, store a reference to this view, letting us programatically trigger buttons. Alternatively, we can dismiss the view without triggering any button actions by calling `dismissWithClickedButtonIndex:animated:` and passing in `-1` for the button index.
 *
 * This method lets us instantiate, configure and display a `UIAlertView.` Inside the configuration block, we call the `AddButtonBlock` zero or more times to
 * add buttons to our alert. The AddButtonBlock takes two arguments: An `NSString` containing the button's title, and a `ResponseBlock` containing the action
 * to be performed if the button is pressed.
 *
 * If you do not add any buttons to the alert view, it will be displayed and then automatically dismissed after 2 seconds.
 */

- (id)showAlertWithTitle:(NSString *)title
                 message:(NSString *)message
               autoClose:(BOOL)autoClose
      configurationBlock:(void (^) (AddButtonBlock addButton)) config;

@end
