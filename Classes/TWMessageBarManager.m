//
//  TWMessageBarManager.m
//
//  Created by Terry Worona on 5/13/13.
//  Copyright (c) 2013 Terry Worona. All rights reserved.
//

#import "TWMessageBarManager.h"

// Quartz
#import <QuartzCore/QuartzCore.h>

// Numerics (TWMessageBarStyleSheet)
CGFloat const kTWMessageBarStyleSheetMessageBarAlpha = 0.96f;

// Numerics (TWMessageView)
CGFloat const kTWMessageViewBarPadding = 10.0f;
CGFloat const kTWMessageViewIconSize = 36.0f;
CGFloat const kTWMessageViewTextOffset = 2.0f;
NSUInteger const kTWMessageViewiOS7Identifier = 7;

// Numerics (TWMessageBarManager)
CGFloat const kTWMessageBarManagerDisplayDelay = 3.0f;
CGFloat const kTWMessageBarManagerDismissAnimationDuration = 0.25f;
CGFloat const kTWMessageBarManagerPanVelocity = 0.2f;
CGFloat const kTWMessageBarManagerPanAnimationDuration = 0.0002f;

// Strings (TWMessageBarStyleSheet)
NSString * const kTWMessageBarStyleSheetImageIconError = @"icon-error.png";
NSString * const kTWMessageBarStyleSheetImageIconSuccess = @"icon-success.png";
NSString * const kTWMessageBarStyleSheetImageIconInfo = @"icon-info.png";

// Fonts (TWMessageView)
static UIFont *kTWMessageViewTitleFont = nil;
static UIFont *kTWMessageViewDescriptionFont = nil;

// Colors (TWMessageView)
static UIColor *kTWMessageViewTitleColor = nil;
static UIColor *kTWMessageViewDescriptionColor = nil;

// Colors (TWDefaultMessageBarStyleSheet)
static UIColor *kTWDefaultMessageBarStyleSheetErrorBackgroundColor = nil;
static UIColor *kTWDefaultMessageBarStyleSheetSuccessBackgroundColor = nil;
static UIColor *kTWDefaultMessageBarStyleSheetInfoBackgroundColor = nil;
static UIColor *kTWDefaultMessageBarStyleSheetErrorStrokeColor = nil;
static UIColor *kTWDefaultMessageBarStyleSheetSuccessStrokeColor = nil;
static UIColor *kTWDefaultMessageBarStyleSheetInfoStrokeColor = nil;

@protocol TWMessageViewDelegate;

@interface TWDefaultMessageBarStyleSheet : NSObject <TWMessageBarStyleSheet>

+ (TWDefaultMessageBarStyleSheet *)styleSheet;

@end

@interface TWMessageView : UIView

@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *descriptionString;

@property (nonatomic, assign) TWMessageBarMessageType messageType;

@property (nonatomic, assign) BOOL hasCallback;
@property (nonatomic, strong) NSArray *callbacks;

@property (nonatomic, assign, getter = isHit) BOOL hit;

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, weak) id <TWMessageViewDelegate> delegate;

// Initializers
- (id)initWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type;

// Getters
- (CGFloat)height;
- (CGFloat)width;
- (CGFloat)availableWidth;
- (CGSize)titleSize;
- (CGSize)descriptionSize;

// Helpers
- (BOOL)isRunningiOS7OrLater;

@end

@protocol TWMessageViewDelegate <NSObject>

- (NSObject<TWMessageBarStyleSheet> *)styleSheetForMessageView:(TWMessageView *)messageView;

@end

@interface TWMessageBarManager () <TWMessageViewDelegate>

@property (nonatomic, strong) NSMutableArray *messageBarQueue;
@property (nonatomic, assign, getter = isMessageVisible) BOOL messageVisible;
@property (nonatomic, assign) CGFloat messageBarOffset;

// Static
+ (CGFloat)durationForMessageType:(TWMessageBarMessageType)messageType;

// Helpers
- (void)showNextMessage;

// Gestures
- (void)itemSelected:(UITapGestureRecognizer *)recognizer;

@end

@implementation TWMessageBarManager

#pragma mark - Singleton

+ (TWMessageBarManager *)sharedInstance
{
    static dispatch_once_t pred;
    static TWMessageBarManager *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
    });
	return instance;
}

#pragma mark - Static

+ (CGFloat)durationForMessageType:(TWMessageBarMessageType)messageType
{
    return kTWMessageBarManagerDisplayDelay;
}

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    if (self)
    {
        _messageBarQueue = [[NSMutableArray alloc] init];
        _messageVisible = NO;
        _messageBarOffset = [[UIApplication sharedApplication] statusBarFrame].size.height;
        _styleSheet = [TWDefaultMessageBarStyleSheet styleSheet];
    }
    return self;
}

#pragma mark - Public

- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type
{
    [self showMessageWithTitle:title description:description type:type duration:[TWMessageBarManager durationForMessageType:type] callback:nil];
}

- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type callback:(void (^)())callback
{
    [self showMessageWithTitle:title description:description type:type duration:[TWMessageBarManager durationForMessageType:type] callback:callback];
}

- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type duration:(CGFloat)duration
{
    [self showMessageWithTitle:title description:description type:type duration:duration callback:nil];
}

- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type duration:(CGFloat)duration callback:(void (^)())callback
{
    TWMessageView *messageView = [[TWMessageView alloc] initWithTitle:title description:description type:type];
    messageView.delegate = self;
    
    messageView.callbacks = callback ? [NSArray arrayWithObject:callback] : [NSArray array];
    messageView.hasCallback = callback ? YES : NO;
    
    messageView.duration = duration;
    messageView.hidden = YES;
    
    [[[UIApplication sharedApplication] keyWindow] insertSubview:messageView atIndex:1];
    [self.messageBarQueue addObject:messageView];
    
    if (!self.messageVisible)
    {
        [self showNextMessage];
    }
}

- (void)hideAll
{
    TWMessageView *currentMessageView = nil;
    
    for (UIView *subview in [[[UIApplication sharedApplication] keyWindow] subviews])
    {
        if ([subview isKindOfClass:[TWMessageView class]])
        {
            currentMessageView = (TWMessageView *)subview;
            [currentMessageView removeFromSuperview];
        }
    }
    
    self.messageVisible = NO;
    [self.messageBarQueue removeAllObjects];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - Helpers

- (void)showNextMessage
{
    if ([self.messageBarQueue count] > 0)
    {
        self.messageVisible = YES;
        
        TWMessageView *messageView = [self.messageBarQueue objectAtIndex:0];
        messageView.frame = CGRectMake(0, -[messageView height], [messageView width], [messageView height]);
        messageView.hidden = NO;
        [messageView setNeedsDisplay];
        
        UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemSelected:)];
        [messageView addGestureRecognizer:gest];
        
        if (messageView)
        {
            [self.messageBarQueue removeObject:messageView];
            
            [UIView animateWithDuration:kTWMessageBarManagerDismissAnimationDuration animations:^{
                [messageView setFrame:CGRectMake(messageView.frame.origin.x, self.messageBarOffset + messageView.frame.origin.y + [messageView height], [messageView width], [messageView height])]; // slide down
            }];
            [self performSelector:@selector(itemSelected:) withObject:messageView afterDelay:messageView.duration];
        }
    }
}

#pragma mark - Gestures

- (void)itemSelected:(id)sender
{
    TWMessageView *messageView = nil;
    BOOL itemHit = NO;
    if ([sender isKindOfClass:[UIGestureRecognizer class]])
    {
        messageView = (TWMessageView *)((UIGestureRecognizer *)sender).view;
        itemHit = YES;
    }
    else if ([sender isKindOfClass:[TWMessageView class]])
    {
        messageView = (TWMessageView *)sender;
    }
    
    if (messageView && ![messageView isHit])
    {
        messageView.hit = YES;
        
        [UIView animateWithDuration:kTWMessageBarManagerDismissAnimationDuration animations:^{
            [messageView setFrame:CGRectMake(messageView.frame.origin.x, messageView.frame.origin.y - [messageView height] - self.messageBarOffset, [messageView width], [messageView height])]; // slide back up
        } completion:^(BOOL finished) {
            self.messageVisible = NO;
            [messageView removeFromSuperview];
            
            if (itemHit)
            {
                if ([messageView.callbacks count] > 0)
                {
                    id obj = [messageView.callbacks objectAtIndex:0];
                    if (![obj isEqual:[NSNull null]])
                    {
                        ((void (^)())obj)();
                    }
                }
            }
            
            if([self.messageBarQueue count] > 0)
            {
                [self showNextMessage];
            }
        }];
    }
}

#pragma mark - Setters

- (void)setStyleSheet:(NSObject<TWMessageBarStyleSheet> *)styleSheet
{
    if (styleSheet != nil)
    {
        _styleSheet = styleSheet;
    }
}

#pragma mark - TWMessageViewDelegate

- (NSObject<TWMessageBarStyleSheet> *)styleSheetForMessageView:(TWMessageView *)messageView
{
    return self.styleSheet;
}

@end

@implementation TWMessageView

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [TWMessageView class])
	{
        // Fonts
        kTWMessageViewTitleFont = [UIFont boldSystemFontOfSize:16.0];
        kTWMessageViewDescriptionFont = [UIFont systemFontOfSize:14.0];
        
        // Colors
        kTWMessageViewTitleColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        kTWMessageViewDescriptionColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	}
}

- (id)initWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.userInteractionEnabled = YES;
        
        _titleString = title;
        _descriptionString = description;
        _messageType = type;
        
        _height = 0.0;
        _width = 0.0;
        
        _hasCallback = NO;
        _hit = NO;
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ([self.delegate respondsToSelector:@selector(styleSheetForMessageView:)])
    {
        id<TWMessageBarStyleSheet> styleSheet = [self.delegate styleSheetForMessageView:self];

        // background fill
        CGContextSaveGState(context);
        {
            if ([styleSheet respondsToSelector:@selector(backgroundColorForMessageType:)])
            {
                [[styleSheet backgroundColorForMessageType:self.messageType] set];
                CGContextFillRect(context, rect);
            }
        }
        CGContextRestoreGState(context);
        
        // bottom stroke
        CGContextSaveGState(context);
        {
            if ([styleSheet respondsToSelector:@selector(strokeColorForMessageType:)])
            {
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, 0, rect.size.height);
                CGContextSetStrokeColorWithColor(context, [styleSheet strokeColorForMessageType:self.messageType].CGColor);
                CGContextSetLineWidth(context, 1.0);
                CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
                CGContextStrokePath(context);
            }
        }
        CGContextRestoreGState(context);
        
        CGFloat xOffset = kTWMessageViewBarPadding;
        CGFloat yOffset = kTWMessageViewBarPadding;
        
        // icon
        CGContextSaveGState(context);
        {
            if ([styleSheet respondsToSelector:@selector(iconImageForMessageType:)])
            {
                [[styleSheet iconImageForMessageType:self.messageType] drawInRect:CGRectMake(xOffset, yOffset, kTWMessageViewIconSize, kTWMessageViewIconSize)];
            }
        }
        CGContextRestoreGState(context);
        
        yOffset -= kTWMessageViewTextOffset;
        xOffset += kTWMessageViewIconSize + kTWMessageViewBarPadding;
        
        CGSize titleLabelSize = [self titleSize];
        if (self.titleString && !self.descriptionString)
        {
            yOffset = ceil(rect.size.height * 0.5) - ceil(titleLabelSize.height * 0.5) - kTWMessageViewTextOffset;
        }
        [kTWMessageViewTitleColor set];
        [self.titleString drawInRect:CGRectMake(xOffset, yOffset, titleLabelSize.width, titleLabelSize.height) withFont:kTWMessageViewTitleFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
        
        yOffset += titleLabelSize.height;
        
        CGSize descriptionLabelSize = [self descriptionSize];
        [kTWMessageViewDescriptionColor set];
        [self.descriptionString drawInRect:CGRectMake(xOffset, yOffset, descriptionLabelSize.width, descriptionLabelSize.height) withFont:kTWMessageViewDescriptionFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    }
}

#pragma mark - Getters

- (CGFloat)height
{
    if (_height == 0)
    {
        CGSize titleLabelSize = [self titleSize];
        CGSize descriptionLabelSize = [self descriptionSize];
        _height = MAX((kTWMessageViewBarPadding * 2) + titleLabelSize.height + descriptionLabelSize.height, (kTWMessageViewBarPadding * 2) + kTWMessageViewIconSize);
    }
    return _height;
}

- (CGFloat)width
{
    if (_width == 0)
    {
        _width = [UIScreen mainScreen].bounds.size.width;
    }
    return _width;
}

- (CGFloat)availableWidth
{
    CGFloat maxWidth = ([self width] - (kTWMessageViewBarPadding * 3) - kTWMessageViewIconSize);
    return maxWidth;
}

- (CGSize)titleSize
{
    CGSize boundedSize = CGSizeMake([self availableWidth], CGFLOAT_MAX);
    CGSize titleLabelSize;
    
    if ([self isRunningiOS7OrLater])
    {
        NSDictionary *titleStringAttributes = [NSDictionary dictionaryWithObject:kTWMessageViewTitleFont forKey: NSFontAttributeName];
        titleLabelSize = [self.titleString boundingRectWithSize:boundedSize
                                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:titleStringAttributes
                                                        context:nil].size;
    }
    else
    {
        titleLabelSize = [_titleString sizeWithFont:kTWMessageViewTitleFont constrainedToSize:boundedSize lineBreakMode:NSLineBreakByTruncatingTail];
    }
    
    return titleLabelSize;
}

- (CGSize)descriptionSize
{
    CGSize boundedSize = CGSizeMake([self availableWidth], CGFLOAT_MAX);
    CGSize descriptionLabelSize;
    
    if ([self isRunningiOS7OrLater])
    {
        NSDictionary *descriptionStringAttributes = [NSDictionary dictionaryWithObject:kTWMessageViewDescriptionFont forKey: NSFontAttributeName];
        descriptionLabelSize = [self.descriptionString boundingRectWithSize:boundedSize
                                                                    options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:descriptionStringAttributes
                                                                    context:nil].size;
    }
    else
    {
        descriptionLabelSize = [_descriptionString sizeWithFont:kTWMessageViewDescriptionFont constrainedToSize:boundedSize lineBreakMode:NSLineBreakByTruncatingTail];
    }
    
    return descriptionLabelSize;
}

#pragma mark - Helpers

- (BOOL)isRunningiOS7OrLater
{
	NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    NSUInteger systemInt = [systemVersion intValue];
    return systemInt >= kTWMessageViewiOS7Identifier;
}

@end

@implementation TWDefaultMessageBarStyleSheet

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [TWDefaultMessageBarStyleSheet class])
	{
        // Colors (background)
        kTWDefaultMessageBarStyleSheetErrorBackgroundColor = [UIColor colorWithRed:1.0 green:0.611 blue:0.0 alpha:kTWMessageBarStyleSheetMessageBarAlpha]; // orange
        kTWDefaultMessageBarStyleSheetSuccessBackgroundColor = [UIColor colorWithRed:0.0f green:0.831f blue:0.176f alpha:kTWMessageBarStyleSheetMessageBarAlpha]; // green
        kTWDefaultMessageBarStyleSheetInfoBackgroundColor = [UIColor colorWithRed:0.0 green:0.482 blue:1.0 alpha:kTWMessageBarStyleSheetMessageBarAlpha]; // blue
        
        // Colors (stroke)
        kTWDefaultMessageBarStyleSheetErrorStrokeColor = [UIColor colorWithRed:0.949f green:0.580f blue:0.0f alpha:1.0f]; // orange
        kTWDefaultMessageBarStyleSheetSuccessStrokeColor = [UIColor colorWithRed:0.0f green:0.772f blue:0.164f alpha:1.0f]; // green
        kTWDefaultMessageBarStyleSheetInfoStrokeColor = [UIColor colorWithRed:0.0f green:0.415f blue:0.803f alpha:1.0f]; // blue
    }
}

+ (TWDefaultMessageBarStyleSheet *)styleSheet
{
    return [[TWDefaultMessageBarStyleSheet alloc] init];
}

#pragma mark - TWMessageBarStyleSheet

- (UIColor *)backgroundColorForMessageType:(TWMessageBarMessageType)type
{
    UIColor *backgroundColor = nil;
    switch (type)
    {
        case TWMessageBarMessageTypeError:
            backgroundColor = kTWDefaultMessageBarStyleSheetErrorBackgroundColor;
            break;
        case TWMessageBarMessageTypeSuccess:
            backgroundColor = kTWDefaultMessageBarStyleSheetSuccessBackgroundColor;
            break;
        case TWMessageBarMessageTypeInfo:
            backgroundColor = kTWDefaultMessageBarStyleSheetInfoBackgroundColor;
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
            strokeColor = kTWDefaultMessageBarStyleSheetErrorStrokeColor;
            break;
        case TWMessageBarMessageTypeSuccess:
            strokeColor = kTWDefaultMessageBarStyleSheetSuccessStrokeColor;
            break;
        case TWMessageBarMessageTypeInfo:
            strokeColor = kTWDefaultMessageBarStyleSheetInfoStrokeColor;
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
            iconImage = [UIImage imageNamed:kTWMessageBarStyleSheetImageIconError];
            break;
        case TWMessageBarMessageTypeSuccess:
            iconImage = [UIImage imageNamed:kTWMessageBarStyleSheetImageIconSuccess];
            break;
        case TWMessageBarMessageTypeInfo:
            iconImage = [UIImage imageNamed:kTWMessageBarStyleSheetImageIconInfo];
            break;
        default:
            break;
    }
    return iconImage;
}

@end
