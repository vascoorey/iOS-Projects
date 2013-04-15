/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "AppDelegate.h"
#import "MainMenuSceneViewController.h"

@implementation AppDelegate

-(void) initializationComplete
{
	// seed random function with current time
	srandom((unsigned int)time(NULL));
	
	MainMenuSceneViewController* mainMenuVC = [MainMenuSceneViewController controller];
	[self.gameController presentSceneViewController:mainMenuVC];
}

@end
