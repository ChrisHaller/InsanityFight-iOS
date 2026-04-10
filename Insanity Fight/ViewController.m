//
//  ViewController.m
//  Insanity Fight
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//


#import "ViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "SpaceshipScene.h"
#import "AppDelegate.h"

#import "Game.h"

@interface ViewController (){
    
}

@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
}

-(void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    NSLog(@"viewWillLayoutSubviews");
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.game  setNewHeightFactor:[self heightFactor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.game startGame:self heightFactor:[self heightFactor]];
    
}


-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.subtype == UIEventSubtypeMotionShake) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.game.gamePaused = !delegate.game.gamePaused;
    }
}



-(float) heightFactor
{
    float height = self.view.frame.size.height;
    float width = self.view.frame.size.width;
    
    
    UIDeviceOrientation orientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    
    
    if (UIDeviceOrientationIsLandscape(orientation))
    {
        int oldHeight = height;
        height = width;
        width = oldHeight;
        
        height -= -50;          // ein wenig schummeln. sonst pass das aspect-ratio nicht ins Amiga Format
    }
    
    float heightFactor = height / width;
    return heightFactor;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
}

@end
