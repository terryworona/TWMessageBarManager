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
    MessageBarMessageTypeInfo,
    MessageBarMessageTypeLogo
} MessageBarMessageType;

@interface MessageBarManager : NSObject

+ (MessageBarManager *)sharedInstance;
+ (CGFloat)durationForMessageType:(MessageBarMessageType)messageType;

- (void)showGenericServerError;
- (void)showSaveErrorWithResourceName:(NSString*)resource;

- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type;
- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type callback:(void (^)())callback;

- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type forDuration:(CGFloat)duration;
- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type forDuration:(CGFloat)duration callback:(void (^)())callback;

- (void)showAppUpgradeAvailableWithCallback:(void (^)())buttonCallback;
- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type withButtonCallback:(void (^)())buttonCallback;
- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type withButtonCallback:(void (^)())buttonCallback callback:(void (^)())callback;

@end