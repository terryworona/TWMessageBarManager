//
//  TWMessageBarDemoControllerV2ViewController.m
//  MessageBarManagerDemo
//
//  Created by Simon on 28/07/14.
//  Copyright (c) 2014 Terry Worona. All rights reserved.
//

#import "TWMessageBarDemoViewController.h"

@interface TWMessageBarDemoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelTitleLength;
@property (weak, nonatomic) IBOutlet UILabel *labelSubtitleLength;
@property (weak, nonatomic) IBOutlet UILabel *labelDisplayLength;

@property (nonatomic) NSInteger titleLength;
@property (nonatomic) NSInteger subtitleLength;
@property (nonatomic) CGFloat displayLength;
@property (nonatomic) BOOL hidesStatusBar;
@property (nonatomic) UIStatusBarStyle statusBarStyle;

@property (strong, nonatomic) NSNumberFormatter *numberFormatter;

@end

@implementation TWMessageBarDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _titleLength = 1;
        _subtitleLength = 1;
        _displayLength = 3.0f;
        _statusBarStyle = UIStatusBarStyleDefault;
        _hidesStatusBar = NO;
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_numberFormatter setMinimumFractionDigits:2];
        [_numberFormatter setMaximumFractionDigits:2];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchedButtonHideAll:(id)sender {
    [[TWMessageBarManager sharedInstance] hideAllAnimated:YES];
}

- (IBAction)touchedButtonError:(id)sender {
    if (self.hidesStatusBar) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:[self titleMessage] description:[self subtitleMessage] type:TWMessageBarMessageTypeError duration:self.displayLength statusBarHidden:self.hidesStatusBar callback:nil];
    }
    else {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:[self titleMessage] description:[self subtitleMessage] type:TWMessageBarMessageTypeError duration:self.displayLength statusBarStyle:self.statusBarStyle callback:nil];
    }
}

- (IBAction)touchedButtonInformation:(id)sender {
    if (self.hidesStatusBar) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:[self titleMessage] description:[self subtitleMessage] type:TWMessageBarMessageTypeInfo duration:self.displayLength statusBarHidden:self.hidesStatusBar callback:nil];
    }
    else {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:[self titleMessage] description:[self subtitleMessage] type:TWMessageBarMessageTypeInfo duration:self.displayLength statusBarStyle:self.statusBarStyle callback:nil];
    }
}

- (IBAction)touchedButtonSuccess:(id)sender {
    if (self.hidesStatusBar) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:[self titleMessage] description:[self subtitleMessage] type:TWMessageBarMessageTypeSuccess duration:self.displayLength statusBarHidden:self.hidesStatusBar callback:nil];
    }
    else {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:[self titleMessage] description:[self subtitleMessage] type:TWMessageBarMessageTypeSuccess duration:self.displayLength statusBarStyle:self.statusBarStyle callback:nil];
    }
}

- (IBAction)changedDisplayLength:(UISlider *)sender {
    self.displayLength = [[self.numberFormatter stringFromNumber:@(sender.value)] floatValue];
}

- (IBAction)changedSubtitleLength:(UISlider *)sender {
    self.subtitleLength = roundf(sender.value);
    [sender setValue:self.subtitleLength animated:NO];
}

- (IBAction)changedTitleLength:(UISlider *)sender {
    self.titleLength = roundf(sender.value);
    [sender setValue:self.titleLength animated:NO];
}

- (IBAction)changedStatusBarStyle:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 2) {
        self.hidesStatusBar = YES;
    }
    else {
        self.statusBarStyle = sender.selectedSegmentIndex;
    }
}

- (void)setTitleLength:(NSInteger)titleLength {
    _titleLength = titleLength;
    
    self.labelTitleLength.text = [NSString stringWithFormat:@"Title length: %ld line(s)", (long)titleLength];
}

- (void)setSubtitleLength:(NSInteger)subtitleLength {
    _subtitleLength = subtitleLength;
    
    self.labelSubtitleLength.text = [NSString stringWithFormat:@"Subtitle length: %ld line(s)", (long)subtitleLength];
}

- (void)setDisplayLength:(CGFloat)displayLength {
    _displayLength = displayLength;
    
    self.labelDisplayLength.text = [NSString stringWithFormat:@"Display for: %@ second(s)", [self.numberFormatter stringFromNumber:@(displayLength)]];
}

- (NSString *)titleMessage {
    CGFloat availableWidth = [UIApplication sharedApplication].statusBarFrame.size.width - 66.0f;
    
    return [self textWithNumberOfLines:self.titleLength maxWidth:availableWidth font:[UIFont boldSystemFontOfSize:16.0f]];
}

- (NSString *)subtitleMessage {
    CGFloat availableWidth = [UIApplication sharedApplication].statusBarFrame.size.width - 66.0f;
    
    return [self textWithNumberOfLines:self.subtitleLength maxWidth:availableWidth font:[UIFont systemFontOfSize:14.0f]];
}

- (NSString *)textWithNumberOfLines:(NSInteger)lines maxWidth:(CGFloat)width font:(UIFont *)font {
    NSString *sourceString = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris malesuada nulla ut nibh vulputate ornare. Duis suscipit dignissim justo, eu sagittis velit tincidunt vitae. Quisque odio nisi, condimentum vitae libero in, facilisis fringilla libero. Integer vitae tincidunt massa. Nulla facilisi. Morbi mattis lacinia sem sed egestas. Aliquam facilisis leo fringilla enim mollis vulputate. Interdum et malesuada fames ac ante ipsum primis in faucibus. Cras id scelerisque orci, non blandit velit. Sed scelerisque diam et nibh consequat, aliquam viverra nibh eleifend. Proin et lectus quis odio sodales vulputate vel id magna. Quisque ac ligula dapibus, blandit risus at, posuere velit. Aenean dictum, lorem vitae tincidunt scelerisque, nibh elit volutpat elit, venenatis aliquam mi orci vitae leo. In facilisis congue nisl eget rutrum.";
    
    NSMutableArray *arrayOfLines = [[NSMutableArray alloc] init];
    NSInteger startIndex = 0;
    for (NSInteger line = 0; line < lines; line++) {
        NSMutableString *string = [[NSMutableString alloc] init];
        for (; startIndex < [sourceString length]; startIndex++) {
            
            [string appendString:[sourceString substringWithRange:NSMakeRange(startIndex, 1)]];
            
            if ([string sizeWithFont:font].width > width) {
                
                if ([string length] == 1)
                    return nil;
                
                [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
                
                break;
            }
        }
        
        [arrayOfLines addObject:string];
    }
    
    NSString *combinedString = [[arrayOfLines componentsJoinedByString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return [combinedString length] > 0 ? combinedString : nil;
}



@end
