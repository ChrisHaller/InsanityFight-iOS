//
//  TitleScene.m
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import "TitleScene.h"
#import "Panel.h"
#import "Game.h"
#import "constants.h"





@implementation TitleScene{
    BOOL contentCreated;
    SKNode* rootNode;
    Panel* panel;
    NSTimer *durationTimer;
    SKSpriteNode* settingsButton;
    iCadeReaderView* _iCadeReaderView;
}

@synthesize game;



- (void)didChangeSize:(CGSize)oldSize {

    NSLog(@"didChangeSize");
}


- (void)didMoveToView:(SKView *)view
{
    NSLog(@"TitleScene didMoveToView");
    if (!contentCreated)
    {
        self.backgroundColor = [SKColor blackColor];
        self.scaleMode = SKSceneScaleModeAspectFit;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        
        // RootNode an welchem wir ALLES weitere anhängen. Dadurch müssen wir z.B. nur in einem einzigen Node die Grösse ändern wenn wir das mal tun wollen.
        
        rootNode = [[SKNode alloc] init];
        [self addChild:rootNode];
        
        
        // panel hinzufügen
        panel = [Panel new];
        [panel addPanelToNode:rootNode];
        
        
        // Titelbild
        SKSpriteNode *picNode = [SKSpriteNode spriteNodeWithImageNamed:@"TitlePic.png"];
        picNode.anchorPoint = CGPointMake(0,0);
        picNode.position = CGPointMake(0, panel.size.height + 0);
        [rootNode addChild:picNode];
        

        //SettingsButton nur hinzufügen wenn kein Controller connected ist
        if(!game.mFi.controllerConnected)
        {
            [self addSettingsButton];
        }
        
        
        // Timer
        durationTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TITLE_DURATION target:self selector:@selector(durationTimerFired:) userInfo:Nil repeats:NO];

        panel.highScore = game.highScore;
        panel.score = game.score;
     

        
    }
}



-(void)addSettingsButton{
    if(settingsButton == nil) {
        
        settingsButton = [SKSpriteNode spriteNodeWithImageNamed:@"SettingsIcon.png"];
        settingsButton.position = CGPointMake(290, 100);
        settingsButton.zPosition = 10;
        settingsButton.alpha = 0.1;
        //settingsButton.xScale = 0.5;
        //settingsButton.yScale = 0.5;
        [self addChild:settingsButton];
        SKAction* actionHover = [SKAction sequence:@[
                                                     [SKAction fadeAlphaTo:0.9 duration:1.0],
                                                     [SKAction fadeAlphaTo:0.5 duration:1.0]
                                                     ]];
        
        [settingsButton runAction:[SKAction repeatActionForever:actionHover]];
    }
}

-(void)removeSettingsButton
{
    if(settingsButton != nil)
    {
        [settingsButton removeAllActions];
        [settingsButton removeFromParent];
        settingsButton = nil;
    }
}


-(void) durationTimerFired:(NSTimer*) timer{
    NSLog(@"TitleScene: durationTimerFired");
    [self exitTitleScene:Mode_ShowHighScore];
}



// wird gerufen wenn Display berührt wird.
- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event
{
    [durationTimer invalidate];         // timer stoppen. sonst löst dieser bei Ablauf einen Wechsel zur HighScoreScene aus
    [super touchesBegan:touches withEvent:event];
    
    NSSet *allTouches = [event allTouches];
    CGPoint touchLocation;
    
    for (UITouch *touch in allTouches)
    {
        touchLocation = [touch locationInView:touch.view];
        touchLocation = [self convertPointFromView: touchLocation];     // null-punkt unten links
        SKSpriteNode* selectedButton = nil;
        SKAction* actionHover = [SKAction sequence:@[
                                                     [SKAction colorizeWithColor:[SKColor whiteColor]
                                                                colorBlendFactor:1.0 duration:.15],
                                                     [SKAction colorizeWithColor:[SKColor whiteColor]
                                                                colorBlendFactor:0.0 duration:.15],
                                                     [SKAction runBlock:^{[self exitTitleScene:Mode_ShowSettings];}],
                                                     ]];
        
        switch (touch.phase)
        {
            case UITouchPhaseBegan:
                NSLog(@"UITouchPhaseBegan x:%f, y:%f, touch:%x", touchLocation.x, touchLocation.y,  (int)touch);
                
                if([settingsButton containsPoint:touchLocation])
                {
                    selectedButton = settingsButton;
                    [selectedButton runAction:actionHover];
                }
                else
                {
                    [self exitTitleScene:Mode_StartGame];
                }
                break;

            default:
                break;
        }
    }
    
}

-(void) exitTitleScene:(enum TitleExitMode)titleExitMode{
    [rootNode removeAllActions];
    [game endTitleScene:titleExitMode];
}

// wird z.B. gerufen wenn incoming call oder homebutton event kommt. 
-(void) pause{
    
    NSLog(@"TitleScene: pause");
}

// wird z.B. gerufen wenn wir aus dem Background geholt werden
-(void) resume{
    
    NSLog(@"TitleScene: resume");
}

-(void) gameControllerButtonPressed{
    NSLog(@"TitleScene: gameControllerButtonPressed");
    if(game.mFi.rightShoulder | game.mFi.buttonA)
    {
        game.mFi.rightShoulder = NO;
        game.mFi.buttonA = NO;
        [durationTimer invalidate];         // timer stoppen. sonst löst dieser bei Ablauf einen Wechsel zur HighScoreScene aus
        [self exitTitleScene:Mode_StartGame];
    }
}


/*
wird gerufen wenn ein MFi-Controller hinzugefügt oder entfernt wird. Hier stellen wir sicher, dass bei einem Statuswechsel der Settingsbutton (Wahl des SteeringModes) nur angezeigt wird wenn kein Controller vorhanden ist.
*/
-(void) gameControllerChanged{
    NSLog(@"TitleScene: gameControllerChanged");
    
    if(game.mFi.controllerConnected)
    {
        [self removeSettingsButton];
    }
    else
    {
        [self addSettingsButton];
    }
}

@end
