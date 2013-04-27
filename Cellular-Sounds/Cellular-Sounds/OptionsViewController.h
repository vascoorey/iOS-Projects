//
//  OptionsViewController.h
//  Cellular-Sounds
//
//  Created by Vasco Orey on 4/27/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OptionsDelegate <NSObject>
@required
-(void)setVolume:(float)volume forVoice:(NSInteger)voice;
-(float)volumeForVoice:(NSInteger)voice;
@end

@interface OptionsViewController : UIViewController
@property (nonatomic, weak) id <OptionsDelegate> delegate;
@end
