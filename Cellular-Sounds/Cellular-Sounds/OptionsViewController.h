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
-(void)setPan:(float)pan forVoice:(NSInteger)voice;
-(float)panForVoice:(NSInteger)voice;
-(NSInteger)rootNoteForVoice:(NSInteger)voice;
-(void)setRootNote:(NSInteger)note forVoice:(NSInteger)voice;
-(NSString *)scaleForVoice:(NSInteger)voice;
-(void)setScale:(NSString *)scale forVoice:(NSInteger)voice;
@end

@interface OptionsViewController : UIViewController
@property (nonatomic, weak) id <OptionsDelegate> delegate;
@property (nonatomic) NSInteger voices;
@end
