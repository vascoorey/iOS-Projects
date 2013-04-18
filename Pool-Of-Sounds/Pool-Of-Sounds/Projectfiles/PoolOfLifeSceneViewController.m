//
//  MainMenuSceneViewController.m
//  _KoboldTouch-Template_
//
//  Created by Steffen Itterheim on 10.03.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PoolOfLifeSceneViewController.h"
#import "FirstSceneViewController.h"
#import "SecondSceneViewController.h"
#import "GameOfLifeView.h"
#import "PoolOfLife.h"
#import "SoundManager.h"
#import "PDSoundManager.h"

@interface PoolOfLifeSceneViewController () <PoolOfLifeDelegate>
@property (nonatomic, strong) PoolOfLife *game;
@property (nonatomic) ccColor4F toggleButtonColor;
@property (nonatomic) ccColor4F resetButtonColor;
@property (nonatomic, weak) CCLabelTTF *toggleLabel;
@property (nonatomic, strong) PDSoundManager *soundManager;
@property (nonatomic) float currentIntensity;
@property (nonatomic) float lastYAcceleration;
//Window properties
@property (nonatomic) CGFloat widthWindow;
@property (nonatomic) CGFloat heightWindow;
@property (nonatomic) CGFloat gameOffset;
@property (nonatomic) CGFloat widthGame;
@property (nonatomic) CGFloat heightGame;
//Cells
@property (nonatomic) CGFloat cellWidth;
@property (nonatomic) CGFloat yOffset;
@property (nonatomic) CGFloat xOffset;
@property (nonatomic) NSInteger numRows;
@property (nonatomic) NSInteger numCols;
@property (nonatomic) float delayInSeconds;
@property (nonatomic) CGFloat fontSize;
//Game properties
@property (nonatomic) PoolOfLifeGameMode gameMode;
@property (nonatomic) NSInteger currentBeatDelta;
@property (nonatomic) NSInteger currentRowBeingPlayed;
@property (nonatomic) BOOL running;
//View
@property (nonatomic, strong) GameOfLifeView *view;
@end

@implementation PoolOfLifeSceneViewController

#pragma mark Controller Callbacks

// Executed after controller is first allocated and initialized.
// Add subcontrollers, set createModelBlock and loadViewBlock here.
-(void) initWithDefaults
{
	//Properties
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    self.heightWindow = winSize.height;
    self.widthWindow = winSize.width;
    self.gameOffset = (self.heightWindow * .10f); //Top 10% of the screen is for the buttons
    //Row/Col
    self.numRows = 24; //Time steps
    self.numCols = 21; //Tones - 3 octaves
    self.heightGame = self.heightWindow - self.gameOffset;
    self.widthGame = self.widthWindow;
    //Cells
    CGFloat cellWidth = self.widthGame / (CGFloat)self.numCols;
    CGFloat cellHeight = self.heightGame / (CGFloat)self.numRows;
    //Other
    self.delayInSeconds = 0.17f;
    self.fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 34.0f : 26.0f);
    self.gameMode = PoolOfLifeGameModeConway;
    self.currentBeatDelta = 8; //Frames
    self.running = YES;
    
    //Natural Major scale
    //self.soundManager = [[SoundManager alloc] initWithScale:kSoundManagerScaleIonian];
    //self.soundManager.numCols = self.numCols;
    self.soundManager = [[PDSoundManager alloc] initWithPatches:self.numCols];
    self.game.delegate = self;
    self.currentIntensity = 1.0f;
    
    //Multitouch
    self.multiTouchController.enabled = YES;
	self.multiTouchController.multipleTouchEnabled = YES;
    [self.multiTouchController addDelegate:self];
    
    [self reset];
    
    [self createButtons];
    
    CGRect viewRect;
    //Figure out which cell size to use
    if(cellWidth <= cellHeight)
    {
        //Figure out the deltas
        CGFloat deltaY = (self.heightGame - (self.numRows * cellWidth)) / 2.0f;
        viewRect = CGRectMake(0, deltaY, self.widthGame, self.heightGame - deltaY);
        self.cellWidth = cellWidth;
        self.yOffset = deltaY;
        self.xOffset = 0.0f;
    }
    else
    {
        CGFloat deltaX = (self.widthGame - (self.numCols * cellHeight)) / 2.0f;
        viewRect = CGRectMake(deltaX, 0, self.widthGame - deltaX, self.heightGame);
        self.cellWidth = cellHeight;
        self.xOffset = deltaX;
        self.yOffset = 0.0f;
    }
    NSLog(@"Creating view with rect: (%g, %g), (%g, %g), cell: %g", viewRect.origin.x, viewRect.origin.y, viewRect.size.width, viewRect.size.height, self.cellWidth);
    GameOfLifeView *view = [[GameOfLifeView alloc] initWithRect:viewRect rows:self.numRows cols:self.numCols cellWidth:self.cellWidth];
    self.view = view;
    self.loadViewBlock = ^(CCNode *rootNode){
        [rootNode addChild:view];
    };
	
	//NSLog(@"%@", [self.gameController.debugController objectGraph]);
	//NSLog(@"-------");
}

-(void)createButtons
{
    KTTextMenuItem *leftButton = [KTTextMenuItem itemWithText:@"Reset" executionBlock:^(id sender){
        [self reset];
    }];
    leftButton.color = ccRED;
    KTTextMenuItem *rightButton = [KTTextMenuItem itemWithText:@"Pause" executionBlock:^(id sender) {
        self.running = !self.running;
        [self.soundManager stopPlaying];
    }];
    rightButton.color = ccBLUE;
    KTTextMenu *menu = [KTTextMenu menuWithTextMenuItems:@[leftButton, rightButton]];
    menu.fontName = @"Helvetica";
    menu.fontSize = self.fontSize;
    menu.padding = self.widthWindow / 4;
    menu.alignHorizontally = YES;
    KTMenuViewController *menuVC = [KTMenuViewController menuControllerWithTextMenu:menu];
    menuVC.loadViewBlock = ^(CCNode *rootNode){
        rootNode.position = CGPointMake(self.widthWindow / 2.0f, self.heightGame + self.gameOffset / 3);
    };
    [self addSubController:menuVC];
}

#pragma mark - Touch

-(void)touchesEvent:(KTMultiTouchEvent *)multiTouchEvent
{
    for(KTTouchEvent *touch in multiTouchEvent.touchEvents)
    {
        CGPoint touchLocation = [touch locationInGLView];
        if(touchLocation.x > 0 || touchLocation.y > 0)
        {
            NSInteger row = touchLocation.y / self.cellWidth;
            NSInteger col = touchLocation.x / self.cellWidth;
            if(self.yOffset > self.xOffset)
            {
                row = (touchLocation.y - self.yOffset) / self.cellWidth;
            }
            else
            {
                col = (touchLocation.x - self.xOffset) / self.cellWidth;
            }
            if(row >= 0 && row < self.numRows && col >= 0 && col < self.numCols)
            {
                [self.game flipCellAtRow:row col:col started:(touch.phase == KTTouchPhaseBegan)];
            }
        }

    }
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

// Loads the view. Create a custom view by creating an instance of a CCNode class or subclass,
// then assign this view to self.rootNode. After loadView the loadViewBlock is run and the
// self.rootNode is passed into the block as the rootNode parameter.
// The default implementation simply creates a CCNode instance as rootNode, as seen below.
//-(void) loadView
//{
//    self.rootNode = [CCNode node];
//}

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

// Executed before step and afterStep
//-(void) beforeStep:(KTStepInfo *)stepInfo
//{
//}

// Executed every frame, unless self.nextStep is set greater than stepInfo.currentStep
-(void) step:(KTStepInfo *)stepInfo
{
    if(self.running)
    {
        //Update model state
        NSArray *newGrid = [self.game performStep];
        if(newGrid)
        {
            self.currentRowBeingPlayed = 0;
            self.view.rows = newGrid;
        }
        else
        {
            self.currentRowBeingPlayed ++;
        }
        self.view.rowToHighlight = self.currentRowBeingPlayed;
    }
    self.nextStep = stepInfo.currentStep + self.currentBeatDelta;
}

/*
// Executed after the step method
-(void) afterStep:(KTStepInfo *)stepInfo
{
}
*/

#pragma mark Stuff to organize

#pragma mark -

-(PoolOfLife *)game
{
    if(!_game)
    {
        _game = [[PoolOfLife alloc] initWithRows:self.numRows cols:self.numCols gameMode:self.gameMode];
    }
    return _game;
}

#pragma mark Lifecycle

-(void)reset
{
    [self.game reset];
    self.view.rows = nil;
    self.currentRowBeingPlayed = 0;
}

#pragma mark -

//-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col numActive:(NSInteger)numActive
//{
//    //Float32 pitch = ((440.0f / NUM_COLS) * (col + 1)) / 440.0f; //Based on column
//    Float32 gain = ((row + 1.0f) / (4 * NUM_ROWS)) * (1.0f / numActive); //Based on row
//    //NSLog(@"pitch: %g, gain: %g, active: %d", pitch, gain, self.cellsCurrentlyActive);
//    //[self.audioEngine playEffect:@"a-sound.WAV" pitch:pitch pan:0 gain:gain];
//    [self.audioEngine playEffect:[SOUNDS objectAtIndex:(col % [SOUNDS count])] pitch:1.0f pan:0.0f gain:gain];
//}
-(void)updateIntensity
{
//    if(self.acceleration)
//    {
//        //NSLog(@"x: %g, y: %g, z: %g", self.rotationRate.x, self.rotationRate.y, self.rotationRate.z);
//        //intensity += self.rotationRate.x * intensityStep;
//        //NSLog(@"x: %g, y: %g, z: %g", self.acceleration.smoothedX, self.acceleration.smoothedY, self.acceleration.smoothedZ);
//        float currentAcceleration = self.acceleration.smoothedY;
//        float deltaY = self.lastYAcceleration - currentAcceleration;
//        //NSLog(@"y: %g, deltaY: %g", self.acceleration.smoothedY, deltaY);
//        self.lastYAcceleration = currentAcceleration;
//        self.currentIntensity += deltaY;
//        if(self.currentIntensity > 1.0f)
//        {
//            self.currentIntensity = 1.0f;
//        }
//        else if(self.currentIntensity < 0.0f)
//        {
//            self.currentIntensity = 0.0f;
//        }
//        //NSLog(@"current intensity: %g", self.currentIntensity);
//    }
}

-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col
{
    if(!self.soundManager.isPlaying)
    {
        self.soundManager.playing = YES;
    }
    [self updateIntensity];
    //[self.soundManager playNoteForCol:col intensity:self.currentIntensity];
}

-(void)didFinishUpdatingRowWithResultingRow:(NSArray *)row
{
    if(!self.soundManager.isPlaying)
    {
        self.soundManager.playing = YES;
    }
    [self updateIntensity];
    [self.soundManager pushRow:row intensity:self.currentIntensity];
}

@end
