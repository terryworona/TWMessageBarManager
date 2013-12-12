//
//  ViewController.m
//  MessageBarManagerDemo
//
//  Created by Terry Worona on 5/13/13.
//  Copyright (c) 2013 Terry Worona. All rights reserved.
//

#import "ViewController.h"

// Constants
#import "StringConstants.h"

// Messages
#import "MessageBarManager.h"

#define kViewControllerButtonPadding 10
#define kViewControllerButtonHeight 50

@interface ViewController ()

@property (nonatomic, strong) UIButton *errorButton;
@property (nonatomic, strong) UIButton *successButton;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *hideAllButton;

// Button presses
- (void)errorButtonPressed:(id)sender;
- (void)successButtonPressed:(id)sender;
- (void)infoButtonPressed:(id)sender;
- (void)hideAllButtonPressed:(id)sender;

@end

@implementation ViewController

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat xOffset = kViewControllerButtonPadding;
    CGFloat totalheight = (kViewControllerButtonHeight * 4) + (kViewControllerButtonPadding * 3);
    CGFloat yOffset = ceil(self.view.bounds.size.height * 0.5) - ceil(totalheight * 0.5);
    
    self.errorButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.errorButton setTitle:kStringButtonLabelErrorMessage forState:UIControlStateNormal];
    self.errorButton.frame = CGRectMake(xOffset, yOffset, self.view.bounds.size.width - (xOffset * 2), kViewControllerButtonHeight);
    [self.errorButton addTarget:self action:@selector(errorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.errorButton];

    yOffset += kViewControllerButtonHeight + kViewControllerButtonPadding;
    
    self.successButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.successButton setTitle:kStringButtonLabelSuccessMessage forState:UIControlStateNormal];
    self.successButton.frame = CGRectMake(xOffset, yOffset, self.view.bounds.size.width - (xOffset * 2), kViewControllerButtonHeight);
    [self.successButton addTarget:self action:@selector(successButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.successButton];

    yOffset += kViewControllerButtonHeight + kViewControllerButtonPadding;

    self.infoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.infoButton setTitle:kStringButtonLabelInfoMessage forState:UIControlStateNormal];
    self.infoButton.frame = CGRectMake(xOffset, yOffset, self.view.bounds.size.width - (xOffset * 2), kViewControllerButtonHeight);
    [self.infoButton addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.infoButton];
    
    yOffset += kViewControllerButtonHeight + kViewControllerButtonPadding;

    self.hideAllButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.hideAllButton setTitle:kStringButtonLabelHideAll forState:UIControlStateNormal];
    self.hideAllButton.frame = CGRectMake(xOffset, yOffset, self.view.bounds.size.width - (xOffset * 2), kViewControllerButtonHeight);
    [self.hideAllButton addTarget:self action:@selector(hideAllButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hideAllButton];
}

#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait); // pre-iOS 6 support
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Button Presses

- (void)errorButtonPressed:(id)sender
{
    [[MessageBarManager sharedInstance] showMessageWithTitle:kStringMessageBarErrorTitle
                                                 description:kStringMessageBarErrorMessage
                                                        type:MessageBarMessageTypeError];
}

- (void)successButtonPressed:(id)sender
{
    [[MessageBarManager sharedInstance] showMessageWithTitle:kStringMessageBarSuccessTitle
                                                 description:kStringMessageBarSuccessMessage
                                                        type:MessageBarMessageTypeSuccess];
}

- (void)infoButtonPressed:(id)sender
{
    [[MessageBarManager sharedInstance] showMessageWithTitle:kStringMessageBarInfoTitle
                                                 description:kStringMessageBarInfoMessage
                                                        type:MessageBarMessageTypeInfo];
}

- (void)hideAllButtonPressed:(id)sender
{
    [[MessageBarManager sharedInstance] hideAll];
}

@end
