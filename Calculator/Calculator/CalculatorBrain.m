//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Vasco Orey on 11/29/12.
//  Copyright (c) 2012 Delta Dog Studios. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
+ (bool) isOperation:(NSString *)operation;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *) programStack {
    if(!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (id) program {
    return [self.programStack copy];
}

- (void) pushOperand:(double)operand {
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void) clear {
    [self.programStack removeAllObjects];
}

- (double) performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variableValues {
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program usingVariableValues:variableValues];
}

- (void) pushVariable:(NSString *)variable {
    if(![[self class] isOperation:variable]) {
        [self.programStack addObject:variable];
    }
}

+ (bool) isOperation:(NSString *)operation {
    return [self isDoubleOperandOperation:operation] || [self isSingleOperandOperation:operation] || [self isZeroOperandOperation:operation];
}

+ (bool) isDoubleOperandOperation:(NSString *)operation {
    return [operation isEqualToString:@"+"] || [operation isEqualToString:@"-"] || [operation isEqualToString:@"*"] || [operation isEqualToString:@"/"];
}

+ (bool) isSingleOperandOperation:(NSString *)operation {
    return [operation isEqualToString:@"cos"] || [operation isEqualToString:@"sin"] || [operation isEqualToString:@"sqrt"];
}

+ (bool) isZeroOperandOperation:(NSString *)operation {
    return [operation isEqualToString:@"π"];
}

+ (NSString *) descriptionOfStack:(NSMutableArray *)stack isInitialDescription:(bool)isInitial {
    id topOfStack = [stack lastObject];
    if(topOfStack) {
        [stack removeLastObject];
    }
    
    if([topOfStack isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%g", [topOfStack doubleValue]];
    } else if([topOfStack isKindOfClass:[NSString class]]) {
        if([self isOperation:topOfStack]) {
            if([self isDoubleOperandOperation:topOfStack]) {
                NSString *firstDescription = [self descriptionOfStack:stack isInitialDescription:NO];
                return [NSString stringWithFormat:@"%@%@ %@ %@%@", (isInitial || [topOfStack isEqualToString:@"*"]) ? @"" : @"(", [self descriptionOfStack:stack isInitialDescription:NO], topOfStack, firstDescription, (isInitial || [topOfStack isEqualToString:@"*"]) ? @"" : @")"];
            } else if([self isSingleOperandOperation:topOfStack]) {
                return [NSString stringWithFormat:@"%@(%@)", topOfStack, [self descriptionOfStack:stack isInitialDescription:YES]];
            }
        }
        return [NSString stringWithFormat:@"%@", topOfStack];
    }
    return @"";
}

+ (NSString *) descriptionOfProgram:(id)program {
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    NSString *description = [self descriptionOfStack:stack isInitialDescription:YES];
    while([stack count]) {
        description = [NSString stringWithFormat:@"%@, %@", description, [self descriptionOfStack:stack isInitialDescription:YES]];
    }
    
    return description;
}

+ (double) popOperandOffProgramStack:(NSMutableArray *)stack usingVariableValues:(NSDictionary *)variableValues {
    double result = 0;
    id value;
    
    id topOfStack = [stack lastObject];
    if(topOfStack) {
        [stack removeLastObject];
    }
    
    if([topOfStack isKindOfClass:[NSNumber class]]) {
        return [topOfStack doubleValue];
    } else if([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack usingVariableValues:variableValues] + [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
        } else if([operation isEqualToString:@"*"]) {
            result = [self popOperandOffProgramStack:stack usingVariableValues:variableValues] * [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
        } else if([operation isEqualToString:@"-"]) {
            double toSubtract = [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
            result = [self popOperandOffProgramStack:stack usingVariableValues:variableValues] - toSubtract;
        } else if([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
            if(divisor) {
                result = [self popOperandOffProgramStack:stack usingVariableValues:variableValues] / divisor;
            }
        } else if([operation isEqualToString:@"π"]) {
            result = M_PI;
        } else if([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffProgramStack:stack usingVariableValues:variableValues]);
        } else if([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffProgramStack:stack usingVariableValues:variableValues]);
        } else if([operation isEqualToString:@"sqrt"]) {
            result = sqrt([self popOperandOffProgramStack:stack usingVariableValues:variableValues]);
        } else if((value = [variableValues objectForKey:operation])){
            if(value && [value isKindOfClass:[NSNumber class]]) {
                result = [value doubleValue];
            }
        }
    }
    
    return result;
}

+ (NSSet *) variablesUsedInProgram:(id)program {
    NSMutableSet *variablesUsed;
    if([program isKindOfClass:[NSArray class]]) {
        for (id variable in program) {
            if([variable isKindOfClass:[NSString class]] && ![self isOperation:variable]) {
                if(!variablesUsed) {
                    variablesUsed = [[NSMutableSet alloc] init];
                }
                [variablesUsed addObject:variable];
            }
        }
    }
    return [variablesUsed copy];
}

+ (double) runProgram:(id)program {
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack usingVariableValues:nil];
}

+ (double) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
}

@end
