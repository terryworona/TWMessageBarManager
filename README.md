# MessageBarManager

A singleton-manager for presenting system-wide notifications via a dropdown message bar. 

<img src="Screenshot.png">

## Author

<p>
	Terry Worona
</p>

<p>
	Tweet me <a href="http://www.twitter.com/terryworona">@terryworona</a>
</p>

<p>
	Email me at <a href="mailto:terryworona@gmail.com">terryworona@gmail.com</a>
</p>

## Installation

To install, drag the ***/Classes*** folder into your project and import ***MessageBarManager.h** anywhere you would like to present a message:

	#import "MessageBarManager.h"

You will also need to enable ***ARC*** in your project. 

## Usage

### Calling the manager

As a singleton class, the manager can be accessed from anywhere within your app via the ***+ sharedInstance*** function:

	[MessageBarManager sharedInstance]
	
### Presenting a basic message

All messages can be preseted via ***showMessageWithTitle:description:type:***. Additional arguments include duration and callback blocks to be notified of a user tap. 

Basic message:

    [[MessageBarManager sharedInstance] showMessageWithTitle:@"Account Updated!"
                                                 description:@"Your account was successfully updated."
                                                        type:MessageBarMessageTypeSuccess];


The default display duration is ***3 seconds***. You can override this value by supplying an additional argument:

    [[MessageBarManager sharedInstance] showMessageWithTitle:@"Account Updated!"
                                                 description:@"Your account was successfully updated."
                                                        type:MessageBarMessageTypeSuccess
                                                 forDuration:6.0];

### Callbacks

By default, if a user ***taps*** on a message while it is presented, it will automatically dismiss. To be notified of the touch, simply supply a callback block:


    [[MessageBarManager sharedInstance] showMessageWithTitle:@"Account Updated!"
                                                 description:@"Your account was successfully updated."
                                                        type:MessageBarMessageTypeSuccess callback:^{
                                                            NSLog(@"Message bar tapped!");
    }];
	
### Queue

The manager is backed by a queue that can handle an infinite number of sequential requests. You can stack as many messages you want on the stack and they will be presetented one after another:

    [[MessageBarManager sharedInstance] showMessageWithTitle:@"Message 1"
                                                 description:@"Description 1"
                                                        type:MessageBarMessageTypeSuccess];

    [[MessageBarManager sharedInstance] showMessageWithTitle:@"Message 2"
                                                 description:@"Description 2"
                                                        type:MessageBarMessageTypeError];

    [[MessageBarManager sharedInstance] showMessageWithTitle:@"Message 3"
                                                 description:@"Description 3"
                                                        type:MessageBarMessageTypeInfo];

### Customization

The ***MessageBarStyleSheet*** has functions pertaining to background and stroke color as well as icon images. All of these functions may be subclassed and/or directly modified to customize the look and feel of the message bar. 

	+ (UIColor*)backgroundColorForMessageType:(MessageBarMessageType)type;
	+ (UIColor*)strokeColorForMessageType:(MessageBarMessageType)type;
	+ (UIImage*)iconImageForMessageType:(MessageBarMessageType)type;

### New Types
	
Add the new type to the typedef found in ***MessageBarManager.h***. 

	typedef enum {
    	MessageBarMessageTypeError,
	    MessageBarMessageTypeSuccess,
    	MessageBarMessageTypeInfo,
	    MessageBarMessageTypeWarning // new type for warnings
	} MessageBarMessageType;
	
Add new colors and icons to the stylesheet:

	+ (UIColor*)backgroundColorForMessageType:(MessageBarMessageType)type
	{
    	UIColor *backgroundColor = nil;
	    switch (type) {
        
    	    …
		
			case MessageBarMessageTypeWarning:
            	backgroundColor = [UIColor grayColor]; // warnings to be gray background
	            break;
    	    default:
        	    break;
	    }
	    return backgroundColor;
	}
	
	+ (UIColor*)strokeColorForMessageType:(MessageBarMessageType)type
	{
    	UIColor *strokeColor = nil;
	    switch (type) {
        
    	    …
		
			case MessageBarMessageTypeWarning:
            	strokeColor = [UIColor darkGrayColor];
	            break;
    	    default:
        	    break;
	    }
	    return strokeColor;
	}
	
	+ (UIImage*)iconImageForMessageType:(MessageBarMessageType)type
	{
	    UIImage *iconImage = nil;
    	switch (type) {
    	
    		…
    	
	        case MessageBarMessageTypeWarning:
    	        iconImage = [UIImage imageNamed:@"icon-warning.png"]; // warning icon
        	    break;
	        default:
    	        break;
    	}
    	return iconImage;
	}

Displaying a new message with the message type:

    [[MessageBarManager sharedInstance] showMessageWithTitle:@"Account Warning!"
                                                 description:@"Your account has expired!"
                                                        type:MessageBarMessageTypeWarning];

## License

Copyright (C) 2013 Terry Worona

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software" ), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.