//
//  AttributedStringsViewController.m
//  AttributedStrings
//
//  Created by Vasco Orey on 2/4/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "AttributedStringsViewController.h"

@interface AttributedStringsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *selectedWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIStepper *selectedWordStepper;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation AttributedStringsViewController

-(NSArray *)wordList
{
    NSArray *wordList = [[self.label.attributedText string] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([wordList count])
    {
        return wordList;
    }
    else
    {
        return @[@""];
    }
}

- (IBAction)changedText:(UITextField *)sender {
    NSLog(@"%@", sender.text);
    if(sender.text.length)
    {
        NSMutableAttributedString *mutableAttributedString = [self.label.attributedText mutableCopy];
        NSRange range = NSMakeRange(0, mutableAttributedString.length);
        [mutableAttributedString replaceCharactersInRange:range withString:sender.text];
        self.label.attributedText = mutableAttributedString;
    }
}

-(NSString *)selectedWord
{
    return [self wordList][(int)self.selectedWordStepper.value];
}

-(void)addLabelAttributes:(NSDictionary *)attributes range:(NSRange)range
{
    if(range.location != NSNotFound)
    {
        NSMutableAttributedString *mutableAttributedString = [self.label.attributedText mutableCopy];
        [mutableAttributedString addAttributes:attributes range: range];
        self.label.attributedText = mutableAttributedString;
    }
}

-(void)addSelectedWordAttributes:(NSDictionary *)attributes
{
    NSRange range = [[self.label.attributedText string] rangeOfString:[self selectedWord]];
    [self addLabelAttributes:attributes range:range];
}

- (IBAction)updateSelectedWord {
    self.selectedWordStepper.maximumValue = [[self wordList] count] - 1;
    self.selectedWordLabel.text = [self selectedWord];
}
- (IBAction)underline {
    [self addSelectedWordAttributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
}

- (IBAction)noUnderline {
    [self addSelectedWordAttributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone)}];
}

- (IBAction)changeColor:(UIButton *)sender {
    [self addSelectedWordAttributes:@{NSBackgroundColorAttributeName : sender.backgroundColor}];
}

- (IBAction)changeFont:(UIButton *)sender {
    CGFloat fontSize = [UIFont systemFontSize];
    NSDictionary *attributes = [self.label.attributedText attributesAtIndex:0 effectiveRange:NULL];
    UIFont *existingFont = attributes[NSFontAttributeName];
    if(existingFont)
    {
        fontSize = existingFont.pointSize;
    }
    UIFont *font = [sender.titleLabel.font fontWithSize:fontSize];
    [self addSelectedWordAttributes:@{ NSFontAttributeName : font }];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self updateSelectedWord];
}

@end
