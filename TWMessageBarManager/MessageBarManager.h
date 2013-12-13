//
//  MessageBarManager.h
//
//  Created by Terry Worona on 5/13/13.
//  Copyright (c) 2013 Terry Worona. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Three base message bar types. Their look & feel is defined within the MessageBarStyleSheet.
 */
typedef enum {
    MessageBarMessageTypeError,
    MessageBarMessageTypeSuccess,
    MessageBarMessageTypeInfo
} MessageBarMessageType;

@interface MessageBarManager : NSObject

/**
 *  Singleton instance through which all presentation is managed.
 *
 *  @return MessageBarManager instance (singleton).
 */
+ (MessageBarManager *)sharedInstance;

/**
 *  Shows a message with the supplied title, description and type (dictates color, stroke and icon).
 *
 *  @param title        Header text in the message view.
 *  @param description  Description text in the message view.
 *  @param type         Type dictates color, stroke and icon shown in the message view.
 */
- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type;

/**
 *  Shows a message with the supplied title, description, type (dictates color, stroke and icon) & callback block.
 *
 *  @param title        Header text in the message view.
 *  @param description  Description text in the message view.
 *  @param type         Type dictates color, stroke and icon shown in the message view.
 *  @param callback     Callback block to be executed if a message is tapped.
 */
- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type callback:(void (^)())callback;

/**
 *  Shows a message with the supplied title, description, type (dictates color, stroke and icon) & duration.
 *
 *  @param title        Header text in the message view.
 *  @param description  Description text in the message view.
 *  @param type         Type dictates color, stroke and icon shown in the message view.
 *  @param duration     Default duration is 3 seconds, this can be overridden by supplying an optional duration parameter.
 */
- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type duration:(CGFloat)duration;

/**
 *  Shows a message with the supplied title, description, type (dictates color, stroke and icon), callback block & duration.
 *
 *  @param title        Header text in the message view.
 *  @param description  Description text in the message view.
 *  @param type         Type dictates color, stroke and icon shown in the message view.
 *  @param duration     Default duration is 3 seconds, this can be overridden by supplying an optional duration parameter.
 *  @param callback     Callback block to be executed if a message is tapped.
 */
- (void)showMessageWithTitle:(NSString*)title description:(NSString*)description type:(MessageBarMessageType)type duration:(CGFloat)duration callback:(void (^)())callback;

/**
 *  Hides the topmost message from view and removes all remaining messages in the queue (not animated).
 */
- (void)hideAll;

@end

@interface MessageBarStyleSheet : NSObject

/**
 *  Background color of message view.
 *
 *  @param type A MessageBarMessageType (error, information, success, etc).
 *
 *  @return UIColor istance representing the message view's background color.
 */
+ (UIColor *)backgroundColorForMessageType:(MessageBarMessageType)type;

/**
 *  Bottom stroke color of message view.
 *
 *  @param type A MessageBarMessageType (error, information, success, etc).
 *
 *  @return UIColor istance representing the message view's bottom stroke color.
 */
+ (UIColor *)strokeColorForMessageType:(MessageBarMessageType)type;

/**
 *  Icon image of the message view.
 *
 *  @param type A MessageBarMessageType (error, information, success, etc)
 *
 *  @return UIImage istance representing the message view's icon.
 */
+ (UIImage *)iconImageForMessageType:(MessageBarMessageType)type;

@end
