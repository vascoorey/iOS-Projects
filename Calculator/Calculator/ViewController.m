//
//  ViewController.m
//  Calculator
//
//  Created by Vasco Orey on 11/28/12.
//  Copyright (c) 2012 Delta Dog Studios. All rights reserved.
//

#import "ViewController.h"
#import "CalculatorBrain.h"

@interface ViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary* testVariableValues;
@end

@implementation ViewController

@synthesize brain = _brain;
@synthesize display = _display;
@synthesize variablesDisplay = _variablesDisplay;
@synthesize testVariableValues = _testVariableValues;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;

- (CalculatorBrain *) brain {
    if(!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

- (void) updateHistory {
    self.history.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    self.variablesDisplay.text = @"";
    NSSet *variablesUsed = [CalculatorBrain variablesUsedInProgram:self.brain.program];
    for(id variable in variablesUsed) {
        if([variable isKindOfClass:[NSString class]] && [self.testVariableValues objectForKey:variable]) {
            self.variablesDisplay.text = [self.variablesDisplay.text stringByAppendingFormat:@"%@%@: %g", (self.variablesDisplay.text.length ? @", " : @""), variable, [[self.testVariableValues objectForKey:variable] doubleValue]];
        }
    }
}

- (IBAction)variablePressed:(UIButton *)sender {
    if(self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    [self.brain pushVariable:sender.currentTitle];
    [self updateHistory];
}

- (IBAction)testVariablesPressed:(UIButton *)sender {
    NSLog(@"Setting test variables...");
    if([sender.currentTitle isEqualToString:@"Test 1"]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:2.0], @"a", [NSNumber numberWithDouble:11.34], @"b", [NSNumber numberWithDouble:0.5], @"x", [NSNumber numberWithDouble:-5.8], @"y", nil];
    } else if([sender.currentTitle isEqualToString:@"Test 2"]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:5.0], @"a", [NSNumber numberWithDouble:1.9], @"b", [NSNumber numberWithDouble:-69], @"x", nil];
    } else if([sender.currentTitle isEqualToString:@"Test 3"]) {
        self.testVariableValues = nil;
    }
    NSLog(@"Variables: %@", self.testVariableValues);
    [self updateHistory];
}

- (IBAction)floatingPointPressed {
    if([self.display.text rangeOfString:@"."].location == NSNotFound ||
       !self.userIsInTheMiddleOfEnteringANumber) {
        if(!self.userIsInTheMiddleOfEnteringANumber) {
            self.display.text = @"0.";
            self.userIsInTheMiddleOfEnteringANumber = YES;
        } else {
            self.display.text = [self.display.text stringByAppendingString:@"."];
        }
        [self updateHistory];
    }
}

- (IBAction)clearPressed {
    self.display.text = @"0";
    self.testVariableValues = nil;
    [self.brain clear];
    [self updateHistory];
}

- (IBAction)digitPressed:(UIButton *)sender {
    if(self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:sender.currentTitle];
    } else {
        self.display.text = sender.currentTitle;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    [self updateHistory];
}

- (IBAction)operationPressed:(UIButton *)sender {
    if(self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    double result = [self.brain performOperation:sender.currentTitle usingVariableValues:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    [self updateHistory];
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self updateHistory];
}

@end
