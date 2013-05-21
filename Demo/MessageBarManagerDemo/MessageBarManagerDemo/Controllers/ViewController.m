//
//  ViewController.m
//  MessageBarManagerDemo
//
//  Created by Terry Worona on 5/13/13.
//  Copyright (c) 2013 Terry Worona. All rights reserved.
//

#import "ViewController.h"

// Managers
#import "MessageBarManager.h"

// Constants
#import "StringConstants.h"

#define kViewControllerButtonPadding 10
#define kViewControllerButtonHeight 50

@interface ViewController ()

@property (nonatomic, strong) UIButton *errorButton;
@property (nonatomic, strong) UIButton *successButton;
@property (nonatomic, strong) UIButton *infoButton;

// Button presses
- (void)errorButtonPressed:(id)sender;
- (void)successButtonPressed:(id)sender;
- (void)infoButtonPressed:(id)sender;

@end

@implementation ViewController

@synthesize errorButton = _errorButton;
@synthesize successButton = _successButton;
@synthesize infoButton = _infoButton;

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat xOffset = kViewControllerButtonPadding;
    CGFloat yOffset = ceil(self.view.bounds.size.height * 0.5) - ceil(kViewControllerButtonHeight * 0.5);
    
    _errorButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_errorButton setTitle:kStringButtonLabelErrorMessage forState:UIControlStateNormal];
    _errorButton.frame = CGRectMake(xOffset, yOffset, self.view.bounds.size.width - (xOffset*2), kViewControllerButtonHeight);
    [_errorButton addTarget:self action:@selector(errorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_errorButton];

    yOffset = ceil(self.view.bounds.size.height * 0.5) - ceil(kViewControllerButtonHeight * 0.5) - kViewControllerButtonHeight - kViewControllerButtonPadding;
    
    _successButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_successButton setTitle:kStringButtonLabelSuccessMessage forState:UIControlStateNormal];
    _successButton.frame = CGRectMake(xOffset, yOffset, self.view.bounds.size.width - (xOffset*2), kViewControllerButtonHeight);
    [_successButton addTarget:self action:@selector(successButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_successButton];

    yOffset = ceil(self.view.bounds.size.height * 0.5) - ceil(kViewControllerButtonHeight * 0.5) + kViewControllerButtonHeight + kViewControllerButtonPadding;

    _infoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_infoButton setTitle:kStringButtonLabelInfoMessage forState:UIControlStateNormal];
    _infoButton.frame = CGRectMake(xOffset, yOffset, self.view.bounds.size.width - (xOffset*2), kViewControllerButtonHeight);
    [_infoButton addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_infoButton];
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

@end
