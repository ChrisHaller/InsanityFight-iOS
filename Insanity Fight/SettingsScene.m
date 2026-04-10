//
//  SettingsScene.m
//  Insanity Fight
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import "SettingsScene.h"
#import "Panel.h"
#import "constants.h"


@implementation SettingsScene{
    BOOL contentCreated;
    SKNode* rootNode;
    
    Panel* panel;
    NSTimer *durationTimer;
    SKSpriteNode* panelSteeringClassic;
    SKSpriteNode* panelSteeringAccelerometer;
    SKSpriteNode* panelSteeringTwoFingers;
    UITextField *textFieldCheat;
}

@synthesize game;


- (void)didMoveToView:(SKView *)view
{
    NSLog(@"SettingsScene didMoveToView");
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
        
                
        // Timer
       // durationTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TITLE_DURATION target:self selector:@selector(durationTimerFired:) userInfo:Nil repeats:NO];
        
        panel.highScore = game.highScore;
        panel.score = game.score;
        
        
        // SettingsPanel
        
        SKTextureAtlas* atlasSettings = [SKTextureAtlas atlasNamed:@"Settings"];

        panelSteeringClassic = [SKSpriteNode spriteNodeWithTexture:[atlasSettings textureNamed: @"SettingsPanelClassic.PNG"]];
        panelSteeringClassic.position = CGPointMake(160, 245);
        panelSteeringClassic.zPosition = 10;
        panelSteeringClassic.alpha = 0.9;
        

        panelSteeringTwoFingers= [SKSpriteNode spriteNodeWithTexture:[atlasSettings textureNamed: @"SettingsPanelTwoFingers.PNG"]];
        panelSteeringTwoFingers.position = CGPointMake(160, 245-68);
        panelSteeringTwoFingers.zPosition = 10;
        panelSteeringTwoFingers.alpha = 0.9;

        panelSteeringAccelerometer = [SKSpriteNode spriteNodeWithTexture:[atlasSettings textureNamed: @"SettingsPanelAccelerometer.PNG"]];
        panelSteeringAccelerometer.position = CGPointMake(160, 245-68-68);
        panelSteeringAccelerometer.zPosition = 10;
        panelSteeringAccelerometer.alpha = 0.9;
        
        
        [rootNode addChild: panelSteeringClassic];
        [rootNode addChild: panelSteeringTwoFingers];
        
        if(game.accelerometerAvailable)
        {
            [rootNode addChild: panelSteeringAccelerometer];
        }
        
        
        // unsichtbares Textfeld für Cheat-Text.
        
        textFieldCheat = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        
        textFieldCheat.borderStyle = UITextBorderStyleRoundedRect;
        textFieldCheat.font = [UIFont systemFontOfSize:12];
        textFieldCheat.placeholder = @"";
        textFieldCheat.autocorrectionType = UITextAutocorrectionTypeNo;
        textFieldCheat.keyboardType = UIKeyboardTypeDefault;
        textFieldCheat.returnKeyType = UIReturnKeyDone;
        textFieldCheat.clearButtonMode = UITextFieldViewModeWhileEditing;
        textFieldCheat.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textFieldCheat.backgroundColor = [SKColor blackColor];
        textFieldCheat.textColor = [SKColor whiteColor];         // unsichtbar
        textFieldCheat.tintColor = [SKColor blackColor];
        textFieldCheat.delegate = self;
        textFieldCheat.textAlignment = NSTextAlignmentLeft;
        
        [self.view addSubview:textFieldCheat];
    }
}

// neuer Cheat-Textwurde eingegeben
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(textField.text.length > 0)
    {
        
        NSString *cheatText = textField.text;
        
        
        if([cheatText hasPrefix: CHEAT_TEXT_PREFIX])
        {
            cheatText = [cheatText substringFromIndex: [CHEAT_TEXT_PREFIX length]];
            
            
            if([cheatText isEqualToString: CHEAT_TEXT_NO_TILE_COLLISION])
            {
                game.cheatNoDangerousTileCollision = YES;
            }
            
            if([cheatText isEqualToString: CHEAT_TEXT_NO_ENEMY_COLLISION])
            {
                game.cheatNoEnemyCollision = YES;
            }
            
            if([cheatText hasPrefix: CHEAT_TEXT_START_LEVEL])
            {
                NSString *cheatLevel = [cheatText substringFromIndex: [CHEAT_TEXT_START_LEVEL length]];
                game.cheatFirstLevel = [cheatLevel intValue];
                if(game.cheatFirstLevel == 0)
                {
                    game.cheatFirstLevel = 1;
                }
            }
        }
        
        [textField resignFirstResponder];
        return YES;
    }
    else
    {
        [textField resignFirstResponder];
        return NO;
    }
}


- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSSet *allTouches = [event allTouches];
    CGPoint touchLocation;
    
        for (UITouch *touch in allTouches)
        {
            touchLocation = [touch locationInView:touch.view];
            touchLocation = [self convertPointFromView: touchLocation];     // null-punkt unten links
            SKSpriteNode* selectedPanel = nil;
            
            SKAction* actionHover = [SKAction sequence:@[
                                                         [SKAction colorizeWithColor:[SKColor whiteColor]
                                                                    colorBlendFactor:1.0 duration:.15],
                                                         [SKAction colorizeWithColor:[SKColor whiteColor]
                                                                    colorBlendFactor:0.0 duration:.15],
                                                         [SKAction runBlock:^{[self exitSettingsScene];}],
                                                         ]];
            
            switch (touch.phase)
            {
                case UITouchPhaseBegan:
                    NSLog(@"UITouchPhaseBegan x:%f, y:%f, touch:%x", touchLocation.x, touchLocation.y,  (int)touch);
                    
                    if([panelSteeringClassic containsPoint:touchLocation])
                    {
                        selectedPanel = panelSteeringClassic;
                        game.steeringMode = SteeringMode_Classic;
                    }

                    if([panelSteeringAccelerometer containsPoint:touchLocation])
                    {
                        if(game.accelerometerAvailable)
                        {
                            selectedPanel = panelSteeringAccelerometer;
                            game.steeringMode = SteeringMode_Accelerometer;
                        }
                    }
                    
                    if([panelSteeringTwoFingers containsPoint:touchLocation])
                    {
                        selectedPanel = panelSteeringTwoFingers;
                        game.steeringMode = SteeringMode_TwoFingers;
                    }
                    
                    [selectedPanel runAction:actionHover];
                    
                    break;
                    
                    default:
                    break;
            }
        }
}



-(void) exitSettingsScene{
    [textFieldCheat resignFirstResponder];
    [textFieldCheat removeFromSuperview];
    
    [game endSettingsScene];
}

// wird z.B. gerufen wenn incoming call oder homebutton event kommt.
-(void) pause{
    NSLog(@"SettingsScene: pause");
}

// wird z.B. gerufen wenn wir aus dem Background geholt werden
-(void) resume{
    
    NSLog(@"SettingsScene: resume");
}

-(void) gameControllerButtonPressed{
    NSLog(@"SettingsScene: gameControllerButtonPressed");   // hierhing dürften wir eigentlich nie kommen.
}


-(void) gameControllerChanged{
    NSLog(@"SettingsScene: gameControllerChanged");
    if(game.mFi.controllerConnected)
    {
        // Gamecontroller wurde verbunden. Somit kann kein SteeringMode mehr gewählt werden --> Scene beenden
        [self exitSettingsScene];
    }
}

@end
