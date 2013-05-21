//
//  MessageBarManager.h
//
//  Created by Terry Worona on 5/13/13.
//  Copyright (c) 2013 Terry Worona. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MessageBarMessageTypeError,
    MessageBarMessageTypeSuccess,
    MessageBarMessageTypeInfo
} MessageBarMessageType;

@interface MessageBarManager : NSObject

+ (MessageBarManager *)sharedInstance;

- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type;
- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type callback:(void (^)())callback;

- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type forDuration:(CGFloat)duration;
- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type forDuration:(CGFloat)duration callback:(void (^)())callback;

@end

@interface MessageBarStyleSheet : NSObject

// Colors (override for customization)
+ (UIColor*)backgroundColorForMessageType:(MessageBarMessageType)type;
+ (UIColor*)strokeColorForMessageType:(MessageBarMessageType)type;

// Icon images (override for customization)
+ (UIImage*)iconImageForMessageType:(MessageBarMessageType)type;

@end