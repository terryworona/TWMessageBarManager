//
//  MessageBarManager.m
//
//  Created by Terry Worona on 5/13/13.
//  Copyright (c) 2013 Terry Worona. All rights reserved.
//

#import "GAMessageBarManager.h"

// Constants
#import "GAConstants.h"

// quartz
#import <QuartzCore/QuartzCore.h>

// Delegate
#import "AppDelegate.h"

// Drawing
#import "GADrawUtils.h"

#define kGAMessageBarAlpha 0.96
#define kGAMessageBarPadding 10
#define kGAMessageBarButtonWidth 60
#define kGAMessageBarButtonHeight 30
#define kGAMessageBarMaxDescriptionHeight 250
#define kGAMessageBarIconSize 36
#define kGAMessageBarRegularDisplayDelay 3.0
#define kGAMessageBarErrorDisplayDelay 5.0
#define kGAMessageBarTextOffset 2.0

typedef enum {
    GAMessageViewTypeVirgin = 1,
    GAMessageViewTypeHit
} GAMessageViewType;

@class GAMessageView;

@interface GAMessageView : UIView

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *descriptionString;
@property (nonatomic, assign) GAMessageBarMessageType messageType;
@property (nonatomic, strong) UIImageView *shadowView;

@property (nonatomic, assign) BOOL hasCallback;
@property (nonatomic, strong) NSArray *callbacks;

@property (nonatomic, assign) BOOL hasButtonCallback;
@property (nonatomic, strong) NSArray *buttonCallbacks;

@property (nonatomic, assign, getter = isHit) BOOL hit;

@property (nonatomic, assign, readonly) CGFloat height;
@property (nonatomic, assign, readonly) CGFloat width;

@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, strong) UIButton *button;

- (id)initWithTitle:(NSString*)title description:(NSString*)description type:(GAMessageBarMessageType)type;
- (id)initWithTitle:(NSString*)title description:(NSString*)description type:(GAMessageBarMessageType)type buttonText:(NSString*)buttonText;

- (void)buttonPressed:(id)sender;

@end

@interface GAMessageBarManager ()

@property (nonatomic, strong) NSMutableArray *messageBarQueue;
@property (nonatomic, assign, getter = isMessageVisible) BOOL messageVisible;
@property (nonatomic, assign) CGFloat messageBarOffset;

- (void)showNextMessage;
- (void)itemSelected:(UITapGestureRecognizer*)recognizer;

@end

@implementation GAMessageBarManager

@synthesize messageBarQueue = _messageBarQueue;
@synthesize messageVisible = _messageVisible;
@synthesize messageBarOffset = _messageBarOffset;

#pragma mark - Singleton

+ (GAMessageBarManager *)sharedInstance
{
    static dispatch_once_t pred;
    static GAMessageBarManager *instance = nil;
    dispatch_once(&pred, ^{ instance = [[self alloc] init]; });
	return instance;
}

#pragma mark - Static

+ (CGFloat)durationForMessageType:(GAMessageBarMessageType)messageType
{
    switch (messageType) {
        case GAMessageBarMessageTypeError:
            return kGAMessageBarErrorDisplayDelay;
            break;
        case GAMessageBarMessageTypeSuccess:
            return kGAMessageBarRegularDisplayDelay;
            break;
        case GAMessageBarMessageTypeInfo:
            return kGAMessageBarRegularDisplayDelay;
            break;
        case GAMessageBarMessageTypeLogo:
            return kGAMessageBarRegularDisplayDelay;
            break;
        default:
            break;
    }
    return kGAMessageBarRegularDisplayDelay;
}

#pragma mark - Alloc/Init

-(id)init
{
    if(self = [super init]) {
        _messageBarQueue = [[NSMutableArray alloc] init];        
        _messageVisible = NO;
        _messageBarOffset = [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    return self;
}

#pragma mark - Public

- (void)showGenericServerError
{
    [self showMessageWithTitle:kGAStringMessageUnexpectedErrorTitle description:kGAStringMessageUnexpectedErrorMessage type:GAMessageBarMessageTypeError];
}

- (void)showSaveErrorWithResourceName:(NSString*)resource
{
    [self showMessageWithTitle:kGAStringMessageResourceSaveErrorTitle description:[NSString stringWithFormat:kGAStringMessageResourceSaveErrorMessage, [resource lowercaseString]] type:GAMessageBarMessageTypeError];
}

- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(GAMessageBarMessageType)type
{
    [self showMessageWithTitle:title description:description type:type forDuration:[GAMessageBarManager durationForMessageType:type] callback:nil];
}

- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(GAMessageBarMessageType)type callback:(void (^)())callback
{
    [self showMessageWithTitle:title description:description type:type forDuration:[GAMessageBarManager durationForMessageType:type] callback:callback];
}

- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(GAMessageBarMessageType)type forDuration:(CGFloat)duration
{
    [self showMessageWithTitle:title description:description type:type forDuration:duration callback:nil];
}

- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(GAMessageBarMessageType)type forDuration:(CGFloat)duration callback:(void (^)())callback
{
    GAMessageView *messageView = [[GAMessageView alloc] initWithTitle:title description:description type:type];

    messageView.callbacks = callback ? [NSArray arrayWithObject:callback] : [NSArray array];
    messageView.hasCallback = callback ? YES : NO;
    
    messageView.duration = duration;
    messageView.hidden = YES;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window insertSubview:messageView atIndex:1];
    [_messageBarQueue addObject:messageView];
    
    if (!_messageVisible){
        [self showNextMessage];
    }
}

- (void)showAppUpgradeAvailableWithCallback:(void (^)())buttonCallback
{
    GAMessageView *messageView = [[GAMessageView alloc] initWithTitle:kGAStringMessageUpdateMessageTitle description:kGAStringMessageUpdateMessage type:GAMessageBarMessageTypeLogo buttonText:kGAStringLabelView];

    messageView.hasButtonCallback = buttonCallback ? YES : NO;
    messageView.buttonCallbacks = buttonCallback ? [NSArray arrayWithObject:buttonCallback] : [NSArray array];
    
    messageView.duration = [GAMessageBarManager durationForMessageType:GAMessageBarMessageTypeLogo];
    messageView.hidden = YES;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window insertSubview:messageView atIndex:1];
    [_messageBarQueue addObject:messageView];
    
    if (!_messageVisible){
        [self showNextMessage];
    }
}

- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(GAMessageBarMessageType)type withButtonCallback:(void (^)())buttonCallback
{
    [self showMessageWithTitle:title description:description type:type withButtonCallback:buttonCallback callback:nil];
}

- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(GAMessageBarMessageType)type withButtonCallback:(void (^)())buttonCallback callback:(void (^)())callback
{
    GAMessageView *messageView = [[GAMessageView alloc] initWithTitle:title description:description type:type buttonText:kGAStringLabelView];
    
    messageView.hasButtonCallback = buttonCallback ? YES : NO;
    messageView.buttonCallbacks = buttonCallback ? [NSArray arrayWithObject:buttonCallback] : [NSArray array];
    
    messageView.callbacks = callback ? [NSArray arrayWithObject:callback] : [NSArray array];
    messageView.hasCallback = callback ? YES : NO;
    
    messageView.duration = [GAMessageBarManager durationForMessageType:type];
    messageView.hidden = YES;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window insertSubview:messageView atIndex:1];
    [_messageBarQueue addObject:messageView];
    
    if (!_messageVisible){
        [self showNextMessage];
    }
}

#pragma mark - Private

- (void)showNextMessage
{
    if ([_messageBarQueue count] > 0){
        _messageVisible = YES;
        
        GAMessageView *messageView = [_messageBarQueue objectAtIndex:0];
        messageView.frame = CGRectMake(0, -[messageView height], [messageView width], [messageView height]);
        messageView.hidden = NO;
        [messageView setNeedsDisplay];

        UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(itemSelected:)];
        [messageView addGestureRecognizer:gest];

        if (messageView){
            [_messageBarQueue removeObject:messageView];
            [UIView animateWithDuration:kGANumericDefaultAnimationDuration animations:^{
                [messageView setFrame:CGRectMake(messageView.frame.origin.x, _messageBarOffset + messageView.frame.origin.y + [messageView height], [messageView width], [messageView height])]; // slide down
            }];
            
            [self performSelector:@selector(itemSelected:) withObject:messageView afterDelay:messageView.duration];
        }
    }
}

#pragma mark - Gestures

- (void)itemSelected:(id)sender
{
    GAMessageView *messageView = nil;
    BOOL itemHit = NO;
    if ([sender isKindOfClass:[UIGestureRecognizer class]]){
        messageView = (GAMessageView*)((UIGestureRecognizer*)sender).view;
        itemHit = YES;
    }
    else if ([sender isKindOfClass:[GAMessageView class]]){
        messageView = (GAMessageView*)sender;
    }
    
    if (messageView && ![messageView isHit]){
        messageView.hit = YES;
        [UIView animateWithDuration:kGANumericDefaultAnimationDuration animations:^{
            [messageView setFrame:CGRectMake(messageView.frame.origin.x, messageView.frame.origin.y - [messageView height] - _messageBarOffset, [messageView width], [messageView height])]; // slide back up
        } completion:^(BOOL finished) {
            _messageVisible = NO;
            [messageView removeFromSuperview];
            
            if (itemHit){
                if ([messageView.callbacks count] > 0){
                    id obj = [messageView.callbacks objectAtIndex:0];
                    if (![obj isEqual:[NSNull null]]) {
                        ((void (^)())obj)();
                    }
                }
            }
            
            if([_messageBarQueue count] > 0) {
                [self showNextMessage];
            }
        }];
    }
}

@end

static UIFont *titleFont = nil;
static UIColor *titleColor = nil;

static UIFont *descriptionFont = nil;
static UIColor *descriptionColor = nil;

static UIColor *shadowColor = nil;

@implementation GAMessageView

@synthesize titleString = _titleString;
@synthesize descriptionString = _descriptionString;
@synthesize messageType = _messageType;
@synthesize shadowView = _shadowView;

@synthesize hasCallback = _hasCallback;
@synthesize callbacks = _callbacks;

@synthesize hasButtonCallback = _hasButtonCallback;
@synthesize buttonCallbacks = _buttonCallbacks;

@synthesize hit = _hit;

@synthesize width = _width;
@synthesize height = _height;

@synthesize duration = _duration;
@synthesize button = _button;

#pragma mark - Alloc/Init

- (id)initWithTitle:(NSString*)title description:(NSString*)description type:(GAMessageBarMessageType)type
{
    return [self initWithTitle:title description:description type:type buttonText:nil];
}

- (id)initWithTitle:(NSString*)title description:(NSString*)description type:(GAMessageBarMessageType)type buttonText:(NSString*)buttonText
{
    self = [super initWithFrame:CGRectZero];
    if (self){
        
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.userInteractionEnabled = YES;
        
        _shadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kGAImageBarShadowTop]];
        [self addSubview:_shadowView];
        
        _titleString = title;
        _descriptionString = description;
        _messageType = type;
        
        titleFont = kGAFontMessageBarTitle;
        titleColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        
        descriptionFont = kGAFontMessageBarMessage;
        descriptionColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        
        shadowColor = [UIColor colorWithWhite:0.2 alpha:0.25];
        
        _height = 0.0;
        _width = 0.0;
        
        _hasCallback = NO;
        _hit = NO;
        
        if (buttonText){
            _button = [UIButton buttonWithType:UIButtonTypeCustom];
            [_button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            _button.titleLabel.font = [UIFont fontWithName:kGAFontSommetRoundedBlack size:14.0];
            _button.titleLabel.adjustsFontSizeToFitWidth = YES;
            _button.titleLabel.shadowOffset = CGSizeMake(0, -1);
            _button.titleLabel.textAlignment = UITextAlignmentCenter;
            [_button setTitleShadowColor:kGAColorDarkGray forState:UIControlStateNormal];
            [_button setTitleShadowColor:kGAColorDarkGray forState:UIControlStateDisabled];
            [_button setTitleShadowColor:kGAColorDarkGray forState:UIControlStateSelected];
            [_button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [_button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateHighlighted | UIControlStateSelected];
            
            [_button setTitle:buttonText forState:UIControlStateNormal];
            [_button setTitle:buttonText forState:UIControlStateDisabled];
            [_button setTitle:buttonText forState:UIControlStateSelected];
            [_button setTitle:buttonText forState:UIControlStateHighlighted];
            [_button setTitle:buttonText forState:UIControlStateHighlighted | UIControlStateSelected];
            
            UIImage *buttonBackgroundImage = [UIImage imageNamed:kGAImageButtonNotification];
            buttonBackgroundImage = [buttonBackgroundImage stretchableImageWithLeftCapWidth:ceil(buttonBackgroundImage.size.width/2) topCapHeight:ceil(buttonBackgroundImage.size.height/2)];
            
            UIImage *buttonBackgroundDepressedImage = [UIImage imageNamed:kGAImageButtonNotificationDepressed];
            buttonBackgroundDepressedImage = [buttonBackgroundDepressedImage stretchableImageWithLeftCapWidth:ceil(buttonBackgroundDepressedImage.size.width/2) topCapHeight:ceil(buttonBackgroundDepressedImage.size.height/2)];
            
            [_button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
            [_button setBackgroundImage:buttonBackgroundImage forState:UIControlStateDisabled];
            [_button setBackgroundImage:buttonBackgroundDepressedImage forState:UIControlStateSelected];
            [_button setBackgroundImage:buttonBackgroundDepressedImage forState:UIControlStateHighlighted];
            [_button setBackgroundImage:buttonBackgroundDepressedImage forState:UIControlStateHighlighted | UIControlStateSelected];

            [_button setNeedsDisplay];
            
            [self addSubview:_button];
        }
    }
    return self;
}

#pragma mark - Button Presses

- (void)buttonPressed:(id)sender
{
    if ([_buttonCallbacks count] > 0){
        id obj = [_buttonCallbacks objectAtIndex:0];
        if (![obj isEqual:[NSNull null]]) {
            ((void (^)())obj)();
            
            [[GAMessageBarManager sharedInstance] performSelector:@selector(itemSelected:) withObject:self afterDelay:0];
        }
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// bg gradient
	CGRect gradientRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    CGContextSaveGState(context);
    {
        switch (_messageType) {
            case GAMessageBarMessageTypeError:
                drawVerticalLinearGradient(context, gradientRect,
                                           [UIColor colorWithRed:0.858 green:0.329 blue:0.309 alpha:kGAMessageBarAlpha].CGColor, // light red
                                           [UIColor colorWithRed:0.756 green:0.019 blue:0.0 alpha:kGAMessageBarAlpha].CGColor); // dark red
                break;
            case GAMessageBarMessageTypeSuccess:
                drawVerticalLinearGradient(context, gradientRect,
                                           [UIColor colorWithRed:0.149 green:0.749 blue:0.149 alpha:kGAMessageBarAlpha].CGColor, // light green
                                           [UIColor colorWithRed:0.0 green:0.549 blue:0.0 alpha:kGAMessageBarAlpha].CGColor); // dark green
                break;
            case GAMessageBarMessageTypeInfo:
                drawVerticalLinearGradient(context, gradientRect,
                                           [UIColor colorWithRed:0.0 green:0.776 blue:0.831 alpha:kGAMessageBarAlpha].CGColor, // light teal
                                           [UIColor colorWithRed:0.0 green:0.560 blue:0.6 alpha:kGAMessageBarAlpha].CGColor); // dark teal
                break;
            case GAMessageBarMessageTypeLogo:
                drawVerticalLinearGradient(context, gradientRect,
                                           [UIColor colorWithRed:0.0 green:0.776 blue:0.831 alpha:kGAMessageBarAlpha].CGColor, // light teal
                                           [UIColor colorWithRed:0.0 green:0.560 blue:0.6 alpha:kGAMessageBarAlpha].CGColor); // dark teal
                break;                
            default:
                break;
        }
    }
    CGContextRestoreGState(context);

    // bottom stroke
    CGContextSaveGState(context);
    {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, rect.size.height);
        switch (_messageType) {
            case GAMessageBarMessageTypeError:
                CGContextSetRGBStrokeColor(context, 0.984f, 0.0f, 0.0f, 1.0f); // red
                break;
            case GAMessageBarMessageTypeSuccess:
                CGContextSetRGBStrokeColor(context, 0.074f, 0.749f, 0.074f, 1.0f); // green
                break;
            case GAMessageBarMessageTypeInfo:
                CGContextSetRGBStrokeColor(context, 0.007f, 0.686f, 0.737f, 1.0f); // teal
                break;
            case GAMessageBarMessageTypeLogo:
                CGContextSetRGBStrokeColor(context, 0.007f, 0.686f, 0.737f, 1.0f); // teal
                break;
            default:
                break;
        }
        CGContextSetLineWidth(context, 1.0);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);

    CGFloat xOffset = kGAMessageBarPadding;
    CGFloat yOffset = kGAMessageBarPadding;
    
    // icon
    CGContextSaveGState(context);
    {
        switch (_messageType) {
            case GAMessageBarMessageTypeError:
                [[UIImage imageNamed:kGAImageIconNotificationWarning] drawInRect:CGRectMake(xOffset, yOffset, kGAMessageBarIconSize, kGAMessageBarIconSize)];
                break;
            case GAMessageBarMessageTypeSuccess:
                [[UIImage imageNamed:kGAImageIconNotificationCheckmark] drawInRect:CGRectMake(xOffset, yOffset, kGAMessageBarIconSize, kGAMessageBarIconSize)];
                break;
            case GAMessageBarMessageTypeInfo:
                [[UIImage imageNamed:kGAImageIconNotificationInfo] drawInRect:CGRectMake(xOffset, yOffset, kGAMessageBarIconSize, kGAMessageBarIconSize)];
                break;
            case GAMessageBarMessageTypeLogo:
                [[UIImage imageNamed:kGAImageIconNotificationLogo] drawInRect:CGRectMake(xOffset, yOffset, kGAMessageBarIconSize, kGAMessageBarIconSize)];
                break;
            default:
                break;
        }
    }
    CGContextRestoreGState(context);
    
    yOffset -= kGAMessageBarTextOffset;
    xOffset += kGAMessageBarIconSize + kGAMessageBarPadding;

    CGFloat maxWith = _button ? (rect.size.width - (kGAMessageBarPadding * 3) - ceil(kGAMessageBarPadding * 0.5) - kGAMessageBarIconSize) - kGAMessageBarButtonWidth : (rect.size.width - (kGAMessageBarPadding * 3) - kGAMessageBarIconSize);
    
    CGSize titleLabelSize = [_titleString sizeWithFont:titleFont forWidth:maxWith lineBreakMode:UILineBreakModeTailTruncation];
    if (_titleString && !_descriptionString){
        yOffset = ceil(rect.size.height * 0.5) - ceil(titleLabelSize.height * 0.5) - kGAMessageBarTextOffset;
    }
    [shadowColor set];
    [_titleString drawInRect:CGRectMake(xOffset, yOffset-1, titleLabelSize.width, titleLabelSize.height) withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    [titleColor set];
	[_titleString drawInRect:CGRectMake(xOffset, yOffset, titleLabelSize.width, titleLabelSize.height) withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];

    yOffset += titleLabelSize.height;
    
    CGSize descriptionLabelSize = [_descriptionString sizeWithFont:descriptionFont constrainedToSize:CGSizeMake(maxWith, kGAMessageBarMaxDescriptionHeight) lineBreakMode:UILineBreakModeTailTruncation];
    [shadowColor set];
	[_descriptionString drawInRect:CGRectMake(xOffset, yOffset-1, descriptionLabelSize.width, descriptionLabelSize.height) withFont:descriptionFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    [descriptionColor set];
	[_descriptionString drawInRect:CGRectMake(xOffset, yOffset, descriptionLabelSize.width, descriptionLabelSize.height) withFont:descriptionFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    _shadowView.frame = CGRectMake(0, [self height], [self width], _shadowView.image.size.height);
    _button.frame = CGRectMake(self.frame.size.width - kGAMessageBarButtonWidth - kGAMessageBarPadding, ceil(self.frame.size.height * 0.5) - ceil(kGAMessageBarButtonHeight * 0.5), kGAMessageBarButtonWidth, kGAMessageBarButtonHeight);
}

#pragma mark - Getters

- (CGFloat)height
{
    if (_height == 0){
        CGFloat maxWith = _button ? ([self width] - (kGAMessageBarPadding * 3) - ceil(kGAMessageBarPadding * 0.5) - kGAMessageBarIconSize) - kGAMessageBarButtonWidth : ([self width] - (kGAMessageBarPadding * 3) - kGAMessageBarIconSize);
        CGSize titleLabelSize = [_titleString sizeWithFont:titleFont forWidth:maxWith lineBreakMode:UILineBreakModeTailTruncation];
        CGSize descriptionLabelSize = [_descriptionString sizeWithFont:descriptionFont constrainedToSize:CGSizeMake(maxWith, 10000) lineBreakMode:UILineBreakModeTailTruncation];
        _height = MAX((kGAMessageBarPadding*2) + titleLabelSize.height + descriptionLabelSize.height, (kGAMessageBarPadding*2) + kGAMessageBarIconSize);
    }
    return _height;
}

- (CGFloat)width
{
    if (_width == 0){
        _width = [UIScreen mainScreen].bounds.size.width;
    }
    return _width;
}

@end