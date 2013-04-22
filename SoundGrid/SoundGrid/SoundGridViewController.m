//
//  SoundGridViewController.m
//  SoundGrid
//
//  Created by Vasco Orey on 4/22/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "SoundGridViewController.h"
#import "GridView.h"
#import "PoolOfLife.h"
#import <QuartzCore/QuartzCore.h>

@interface SoundGridViewController () <PoolOfLifeDelegate, GridViewDelegate>
@property (weak, nonatomic) IBOutlet GridView *gridView;
@property (nonatomic, getter = isRunning) BOOL running;
@property (nonatomic, strong) PoolOfLife *pool;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic) NSInteger numRows;
@property (nonatomic) NSInteger numCols;
@property (nonatomic) NSInteger frameInterval;
@property (nonatomic) NSInteger currentSpecies;
@property (weak, nonatomic) IBOutlet UILabel *currentSpeciesLabel;
@end

@implementation SoundGridViewController

-(void)setCurrentSpecies:(NSInteger)currentSpecies
{
    if(currentSpecies > 0 && currentSpecies <= 4)
    {
        _currentSpecies = currentSpecies;
    }
    else
    {
        _currentSpecies = 1;
    }
    switch (_currentSpecies) {
        case 1:
            self.currentSpeciesLabel.text = @"Blue";
            self.currentSpeciesLabel.textColor = [UIColor blueColor];
            break;
        case 2:
            self.currentSpeciesLabel.text = @"Green";
            self.currentSpeciesLabel.textColor = [UIColor greenColor];
            break;
        case 3:
            self.currentSpeciesLabel.text = @"Yellow";
            self.currentSpeciesLabel.textColor = [UIColor yellowColor];
            break;
        case 4:
            self.currentSpeciesLabel.text = @"Red";
            self.currentSpeciesLabel.textColor = [UIColor redColor];
            break;
        default:
            self.currentSpeciesLabel.text = @"None";
            self.currentSpeciesLabel.textColor = [UIColor blackColor];
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.numRows = 24;
    self.numCols = 21;
    self.frameInterval = 6;
    self.pool = [[PoolOfLife alloc] initWithRows:self.numRows cols:self.numCols gameMode:PoolOfLifeGameModeConway];
    self.pool.delegate = self;
    self.view.multipleTouchEnabled = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scheduleUpdate];
    self.gridView.delegate = self;
    self.currentSpecies = 1;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unscheduleUpdate];
    self.gridView.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Updates

-(void)scheduleUpdate
{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [self.displayLink setFrameInterval:self.frameInterval];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)unscheduleUpdate
{
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.displayLink = nil;
}

-(void)update:(CADisplayLink *)link
{
    NSArray *currentState = [self.pool performStep];
    if(currentState)
    {
        NSLog(@"Setting the new grid");
        self.gridView.grid = currentState;
    }
}

#pragma mark - Button Events

- (IBAction)resetPressed {
    [self.pool reset];
}

- (IBAction)startStopPressed:(UIButton *)sender {
}

- (IBAction)speciesButtonPressed:(UIButton *)sender {
    self.currentSpecies = sender.tag;
}

#pragma mark - PoolOfLife Delegate

-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col
{
    [self didActivateCellAtRow:row col:col species:1];
}

-(void)didActivateCellAtRow:(NSInteger)row col:(NSInteger)col species:(NSInteger)species
{
    //Play sound
    //...
    self.gridView.grid = self.pool.state;
}

-(void)didFinishUpdatingRowWithResultingRow:(NSArray *)row
{
    
}

#pragma mark - GridView Delegate

-(void)didDetectTouchAtRow:(NSInteger)row col:(NSInteger)col began:(BOOL)began
{
    [self.pool flipCellAtRow:row col:col started:began species:self.currentSpecies];
}

@end
