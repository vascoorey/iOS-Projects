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
//Individual voices
-(void)setVolume:(float)volume forVoice:(NSInteger)voice;
-(float)volumeForVoice:(NSInteger)voice;
-(void)setPan:(float)pan forVoice:(NSInteger)voice;
-(float)panForVoice:(NSInteger)voice;
//General
-(NSInteger)rootNote;
-(void)setRootNote:(NSInteger)note;
-(NSString *)scale;
-(void)setScale:(NSString *)scale;
//Audio setup
-(void)killAudio;
-(void)startAudio;
-(NSString *)instrumentForVoice:(NSInteger)voice;
-(void)setInstrument:(NSString *)instrument forVoice:(NSInteger)voice;
@end

@interface OptionsViewController : UIViewController
@property (nonatomic, weak) id <OptionsDelegate> delegate;
@property (nonatomic) NSInteger voices;
@property (nonatomic) NSInteger currentVoice;
@end
