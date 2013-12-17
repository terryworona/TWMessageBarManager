//
//  TWMesssageBarDemoController.m
//  MessageBarManagerDemo
//
//  Created by Terry Worona on 5/13/13.
//  Copyright (c) 2013 Terry Worona. All rights reserved.
//

#import "TWMesssageBarDemoController.h"

// Constants
#import "StringConstants.h"

// Messages
#import "TWMessageBarManager.h"

// Numerics
CGFloat const kTWMesssageBarDemoControllerButtonPadding = 10.0f;
CGFloat const kTWMesssageBarDemoControllerButtonHeight = 50.0f;

// Colors
static UIColor *kTWMesssageBarDemoControllerButtonColor = nil;

// Strings
NSString * const kTWMessageBarDemoStyleSheetImageIconError = @"icon-error.png";
NSString * const kTWMessageBarDemoStyleSheetImageIconSuccess = @"icon-success.png";
NSString * const kTWMessageBarDemoStyleSheetImageIconInfo = @"icon-info.png";

@interface TWMessageBarDemoStyleSheet : NSObject <TWMessageBarStyleSheet>

// Demo style sheet

@end

@interface TWMesssageBarDemoController ()

@property (nonatomic, strong) UIButton *errorButton;
@property (nonatomic, strong) UIButton *successButton;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *hideAllButton;

// Button presses
- (void)errorButtonPressed:(id)sender;
- (void)successButtonPressed:(id)sender;
- (void)infoButtonPressed:(id)sender;
- (void)hideAllButtonPressed:(id)sender;

// Generators
- (UIButton *)buttonWithTitle:(NSString *)title;

@end

@implementation TWMesssageBarDemoController

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [TWMesssageBarDemoController class])
	{
        kTWMesssageBarDemoControllerButtonColor = [UIColor colorWithWhite:0.0 alpha:0.25];
	}
}

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [TWMessageBarManager sharedInstance].styleSheet = [[TWMessageBarDemoStyleSheet alloc] init];
    
    CGFloat xOffset = kTWMesssageBarDemoControllerButtonPadding;
    CGFloat totalheight = (kTWMesssageBarDemoControllerButtonHeight * 4) + (kTWMesssageBarDemoControllerButtonPadding * 3);
    CGFloat yOffset = ceil(self.view.bounds.size.height * 0.5) - ceil(totalheight * 0.5);
    
    self.errorButton = [self buttonWithTitle:kStringButtonLabelErrorMessage];
    self.errorButton.frame = CGRectMake(xOffset, yOffset, self.view.bounds.size.width - (xOffset * 2), kTWMesssageBarDemoControllerButtonHeight);
    [self.errorButton addTarget:self action:@selector(errorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.errorButton];

    yOffset += kTWMesssageBarDemoControllerButtonHeight + kTWMesssageBarDemoControllerButtonPadding;
    
    self.successButton = [self buttonWithTitle:kStringButtonLabelSuccessMessage];
    self.successButton.frame = CGRectMake(xOffset, yOffset, self.view.bounds.size.width - (xOffset * 2), kTWMesssageBarDemoControllerButtonHeight);
    [self.successButton addTarget:self action:@selector(successButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.successButton];

    yOffset += kTWMesssageBarDemoControllerButtonHeight + kTWMesssageBarDemoControllerButtonPadding;

    self.infoButton = [self buttonWithTitle:kStringButtonLabelInfoMessage];
    self.infoButton.frame = CGRectMake(xOffset, yOffset, self.view.bounds.size.width - (xOffset * 2), kTWMesssageBarDemoControllerButtonHeight);
    [self.infoButton addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.infoButton];
    
    yOffset += kTWMesssageBarDemoControllerButtonHeight + kTWMesssageBarDemoControllerButtonPadding;

    self.hideAllButton = [self buttonWithTitle:kStringButtonLabelHideAll];
    self.hideAllButton.frame = CGRectMake(xOffset, yOffset, self.view.bounds.size.width - (xOffset * 2), kTWMesssageBarDemoControllerButtonHeight);
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

- (NSUInteger)supportedInterfaceOrientations
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
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:kStringMessageBarErrorTitle
                                                   description:kStringMessageBarErrorMessage
                                                          type:TWMessageBarMessageTypeError];
}

- (void)successButtonPressed:(id)sender
{
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:kStringMessageBarSuccessTitle
                                                   description:kStringMessageBarSuccessMessage
                                                          type:TWMessageBarMessageTypeSuccess];
}

- (void)infoButtonPressed:(id)sender
{
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:kStringMessageBarInfoTitle
                                                   description:kStringMessageBarInfoMessage
                                                          type:TWMessageBarMessageTypeInfo];
}

- (void)hideAllButtonPressed:(id)sender
{
    [[TWMessageBarManager sharedInstance] hideAll];
}

#pragma mark - Generators

- (UIButton *)buttonWithTitle:(NSString *)title
{
    UIButton *button = [[UIButton alloc] init];

    // Background color
    button.backgroundColor = kTWMesssageBarDemoControllerButtonColor;
    
    // Title text
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateDisabled];
    [button setTitle:title forState:UIControlStateSelected];
    [button setTitle:title forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateHighlighted | UIControlStateSelected];
    
    // Title color
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted | UIControlStateSelected];
    
    return button;
}

@end

@implementation TWMessageBarDemoStyleSheet

- (UIColor *)backgroundColorForMessageType:(TWMessageBarMessageType)type
{
    UIColor *backgroundColor = nil;
    switch (type)
    {
        case TWMessageBarMessageTypeError:
            backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.75];
            break;
        case TWMessageBarMessageTypeSuccess:
            backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.75];
            break;
        case TWMessageBarMessageTypeInfo:
            backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.75];
            break;
        default:
            break;
    }
    return backgroundColor;
}

- (UIColor *)strokeColorForMessageType:(TWMessageBarMessageType)type
{
    UIColor *strokeColor = nil;
    switch (type)
    {
        case TWMessageBarMessageTypeError:
            strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
            break;
        case TWMessageBarMessageTypeSuccess:
            strokeColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
            break;
        case TWMessageBarMessageTypeInfo:
            strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
            break;
        default:
            break;
    }
    return strokeColor;
}

- (UIImage *)iconImageForMessageType:(TWMessageBarMessageType)type
{
    UIImage *iconImage = nil;
    switch (type)
    {
        case TWMessageBarMessageTypeError:
            iconImage = [UIImage imageNamed:kTWMessageBarDemoStyleSheetImageIconError];
            break;
        case TWMessageBarMessageTypeSuccess:
            iconImage = [UIImage imageNamed:kTWMessageBarDemoStyleSheetImageIconSuccess];
            break;
        case TWMessageBarMessageTypeInfo:
            iconImage = [UIImage imageNamed:kTWMessageBarDemoStyleSheetImageIconInfo];
            break;
        default:
            break;
    }
    return iconImage;
}

@end
