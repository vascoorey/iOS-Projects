//
//  MainMenuSceneViewController.m
//  _KoboldTouch-Template_
//
//  Created by Steffen Itterheim on 10.03.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MainMenuSceneViewController.h"
#import "FirstSceneViewController.h"
#import "SecondSceneViewController.h"

@implementation MainMenuSceneViewController

#pragma mark Controller Callbacks

// Executed after controller is first allocated and initialized.
// Add subcontrollers, set createModelBlock and loadViewBlock here.
-(void) initWithDefaults
{
	[self createBackground];
	[self createMenu];
	[self createLabel];
	
	NSLog(@"%@", [self.gameController.debugController objectGraph]);
	NSLog(@"-------");
}

-(void) createBackground
{
	KTColorGradient* colorGradient = [[KTColorGradient alloc] init];
	uint8_t startColor = CCRANDOM_0_1() * 255;
	uint8_t endColor = CCRANDOM_0_1() * 255;
	colorGradient.startColor = ccc4(startColor, startColor, startColor, 255);
	colorGradient.endColor = ccc4(endColor, endColor, endColor, 255);
	
	KTColorGradientViewController* gradientVC = [KTColorGradientViewController colorGradientControllerWithColorGradient:colorGradient];
	[self addSubController:gradientVC];
}

-(void) createMenu
{
	KTTextMenuItem* item1 = [KTTextMenuItem itemWithText:@"Goto Scene #1" executionBlock:^(id sender){
		[self.gameController presentSceneViewController:[FirstSceneViewController controller]
										 transitionType:CCRANDOM_0_1() * KTSceneTransitionType_Count
									 transitionDuration:1.0f];
	}];
	item1.color = ccRED;
	
	KTTextMenuItem* item2 = [KTTextMenuItem itemWithText:@"Goto Scene #2" executionBlock:^(id sender){
		[self.gameController presentSceneViewController:[SecondSceneViewController controller]
										 transitionType:CCRANDOM_0_1() * KTSceneTransitionType_Count
									 transitionDuration:1.0f];
	}];
	item2.color = ccRED;
	
	// set menu options
	KTTextMenu* textMenu = [KTTextMenu menuWithTextMenuItems:[NSArray arrayWithObjects:item1, item2, nil]];
	textMenu.fontName = @"Helvetica";
	textMenu.padding = 24;
	textMenu.fontSize = 36;
	
	KTMenuViewController* menuViewController = [KTMenuViewController menuControllerWithTextMenu:textMenu];
	[self addSubController:menuViewController];
}

-(void) createLabel
{
	KTTrueTypeFontLabel* ttfLabel = [KTTrueTypeFontLabel trueTypeFontLabelWithText:@"Main Menu"];
	ttfLabel.color = ccBLACK;
	ttfLabel.fontName = @"Marker Felt";
	ttfLabel.fontSize = 72;
	
	KTLabelViewController* labelVC = [KTLabelViewController labelControllerWithFontLabel:ttfLabel];
	labelVC.loadViewBlock = ^(CCNode* rootNode){
		CGSize winSize = [CCDirector sharedDirector].winSize;
		rootNode.position = CGPointMake(winSize.width / 2, winSize.height / 6);
		((CCLabelTTF*)rootNode).color = ccc3(CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255);
	};
	
	[self addSubController:labelVC];
}

/*
// At this point the model is already initialized. Update the controller based on model.
-(void) load
{
}
*/

/* 
// Unload controller (private) resources here. The view and model are unloaded automatically.
// The controller's unload method is executed after the model's unload method.
-(void) unload
{
}
*/

/*
// Runs just before the sceneViewController is replaced with a new one. 
// The self.sceneViewController property still points to the previous sceneViewController.
// Mainly used by game controllers to perform cleanup when the scene is about to change.
-(void) sceneWillChange
{
}
*/

/*
// Runs just after the previous sceneViewController has been replaced with a new one.
// The self.sceneViewController property already points to the new sceneViewController.
-(void) sceneDidChange
{
}
*/

#pragma mark View Controller Callbacks

/*
// Executed before loadView, self.rootNode is still nil at this point.
-(void) viewWillLoad
{
}
*/

/*
// Loads the view. Create a custom view by creating an instance of a CCNode class or subclass,
// then assign this view to self.rootNode. After loadView the loadViewBlock is run and the
// self.rootNode is passed into the block as the rootNode parameter.
// The default implementation simply creates a CCNode instance as rootNode, as seen below.
-(void) loadView
{
	self.rootNode = [CCNode node];
}
*/

/*
// Executed after loadView and after the loadViewBlock was executed. The view hierarchy is
// fully set up by this point. You can make final adjustments to the view here, or update the
// view with model data or vice versa.
-(void) viewDidLoad
{
}
*/

/*
// Executed when a new scene is being presented and the current scene will soon disappear.
// If the scene uses a scene transition, then viewWillDisappear is executed when the transition begins.
-(void) viewWillDisappear
{
}
*/

/*
// Executed when the current scene has been removed from the view. self.rootNode is already nil at this point.
// Executed just before controller's unload method is executed.
-(void) viewDidDisappear
{
}
*/

#pragma mark Step

/*
// Executed before step and afterStep
-(void) beforeStep:(KTStepInfo *)stepInfo
{
}
*/

/*
// Executed every frame, unless self.nextStep is set greater than stepInfo.currentStep
-(void) step:(KTStepInfo *)stepInfo
{
	// example: this pauses step methods for 200 steps, effentively creating a 200-step interval
	self.nextStep = stepInfo.currentStep + 200;
}
*/

/*
// Executed after the step method
-(void) afterStep:(KTStepInfo *)stepInfo
{
}
*/

@end
