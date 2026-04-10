//
//  Panel.m
//  SpriteWalkthrough
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import "Panel.h"
#import "constants.h"
#import "Game.h"

#define NUM_SCORE_SPRITES 6
#define NUM_ENEMIES_DESTROYED_SRITES 2
#define NUM_NUM_FIGHTER_SRITES 2
#define NUM_BONUS_SPRITES 8

@implementation Panel{
    NSMutableArray *fontArray;
    SKSpriteNode *panelNode;
    SKTextureAtlas *panelAtlas;
    SKSpriteNode *radarLeft;
    SKSpriteNode *radarCenter;
    SKSpriteNode *radarRight;

    SKSpriteNode *radarAlarmLeft;
    SKSpriteNode *radarAlarmCenter;
    SKSpriteNode *radarAlarmRight;

    SKSpriteNode *timeSprite;
    
    SKAction *actionRadar;
    int radarCounter;
    NSMutableArray *scoreSprites;
    NSMutableArray *highScoreSprites;
    NSMutableArray *enemiesDestroyedSprites;
    NSMutableArray *numFighterSpites;
    NSMutableArray *bonusTextures;
    SKTexture* emptyBonusTexture;

    uint _highScore;
    uint _score;
    uint _energy;
    int _bigShipAlarm;
    
    SKSpriteNode* emptyEnergySprite;
    SKSpriteNode* energyMask;
    
    SKSpriteNode* speedLeft;
    SKSpriteNode* speedRight;
    SKSpriteNode* speedMask;
    
    SKSpriteNode* alarmSprite;
    SKSpriteNode* alarmMask;

    SKSpriteNode* highScorePosition;
    SKSpriteNode* highScorePositionMask;
    
    uint _speed;
    uint _alarmLevel;
    uint _level;
    bool _bonusFlag;
    uint _positionInHighScore;

    SKSpriteNode* levelBigSprites[3];
    SKSpriteNode* levelSmallSprites[6];
    SKSpriteNode* bonusSprite;
    
    SKAction* bonusAnim;
    uint _numFighters;
    uint _numEnemiesDestroyed;
}

@synthesize size;

#define NUM_CHARS_IN_FONT 128
#define NUMBER_INDEX_IN_FONT 48         // beid diesem Index beginnen die Ziffern


-(id)init
{
    self = [super init];
    if (self) {
        
        panelAtlas = [SKTextureAtlas atlasNamed:@"Panel"];
        

        // MainPanel
        panelNode = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"panel.png"]];
        panelNode.zPosition = Z_POSITION_PANEL;
        panelNode.anchorPoint = CGPointMake(0,0);
        panelNode.name = @"Panel";
        size.height = panelNode.size.height;
        size.width = panelNode.size.width;
        
        
        // RadardSprites
        radarLeft = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"PanelBall.png"]];
        radarLeft.zPosition = Z_POSITION_PANEL_ELEMENTS;
        radarLeft.name = @"Radar left";
        [panelNode addChild:radarLeft];

 
        radarCenter = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"PanelBall.png"]];
        radarCenter.zPosition = Z_POSITION_PANEL_ELEMENTS;
        radarCenter.name = @"Radar center";
        [panelNode addChild:radarCenter];
        
        radarRight = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"PanelBall.png"]];
        radarRight.zPosition = Z_POSITION_PANEL_ELEMENTS;
        radarRight.name = @"Radar right";
        [panelNode addChild:radarRight];
        
        
        actionRadar = [SKAction sequence:@[
                                                        [SKAction moveByX:9 y:0 duration:0.3],
                                                        [SKAction moveByX:-18 y:0 duration:0.6],
                                                        [SKAction moveByX:18 y:0 duration:0.6],
                                                        [SKAction moveByX:-18 y:0 duration:0.6],
                                                        [SKAction moveByX:9 y:0 duration:0.3]
                                                        ]];
        
        [self setRadarStartPositions];
        [self radarHandler];
        
        
        // orange Radar Sprites

        radarAlarmLeft = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"alarm.png"]];
        radarAlarmLeft.zPosition = Z_POSITION_PANEL_ALARM;
        radarAlarmLeft.position = CGPointMake(80, 69);
        radarAlarmLeft.hidden = YES;
        radarAlarmLeft.name = @"Radar left orange";
        [panelNode addChild:radarAlarmLeft];
        
        
        radarAlarmCenter = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"alarm.png"]];
        radarAlarmCenter.zPosition = Z_POSITION_PANEL_ALARM;
        radarAlarmCenter.position = CGPointMake(160, 69);
        radarAlarmCenter.hidden = YES;
        radarAlarmCenter.name = @"Radar center orange";
        [panelNode addChild:radarAlarmCenter];
        
        radarAlarmRight = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"alarm.png"]];
        radarAlarmRight.zPosition = Z_POSITION_PANEL_ALARM;
        radarAlarmRight.position = CGPointMake(240, 69);
        radarAlarmRight.hidden = YES;
        radarAlarmRight.name = @"Radar right orange";
        [panelNode addChild:radarAlarmRight];

        
        
        
        
        
        
        // ScoreFont
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"font"];
        
        // Font laden
        fontArray = [[NSMutableArray alloc] init];
        SKTexture* texture;
        for(int i = 0; i < NUM_CHARS_IN_FONT; i++)
        {
            texture = [atlas textureNamed: [NSString stringWithFormat:@"font_%d.PNG", i]];
            
            [fontArray addObject:texture];
        }
        
        // ScoreSprites
        
        int scoreX = 140;
        int scoreY = 39;
        scoreSprites = [NSMutableArray new];
        for(int i = 0; i < NUM_SCORE_SPRITES; i++)
        {
            SKColor *color = [Game colorFromHexString:@"#22cc11"];
            SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:fontArray[NUMBER_INDEX_IN_FONT]];
            node.position = CGPointMake(scoreX, scoreY);
            node.zPosition = Z_POSITION_PANEL_ELEMENTS;
            node.size = CGSizeMake(8, 8);
            node.color = color;
            node.colorBlendFactor = 1.0;
            [panelNode addChild:node];
            [scoreSprites addObject:node];
            scoreX += 8;
            
        }
        [self showScore:0];
        
        // HighScoreSprites
        
        int highScoreX = 140;
        int highScoreY = 39 - 15;
        highScoreSprites = [NSMutableArray new];
        for(int i = 0; i < NUM_SCORE_SPRITES; i++)
        {
            SKColor *color = [Game   colorFromHexString:@"#22cc11"];
            SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:fontArray[NUMBER_INDEX_IN_FONT]];
            node.position = CGPointMake(highScoreX, highScoreY);
            node.zPosition = Z_POSITION_PANEL_ELEMENTS;
            node.size = CGSizeMake(8, 8);
            node.color = color;
            node.colorBlendFactor = 1.0;
            [panelNode addChild:node];
            [highScoreSprites addObject:node];
            highScoreX += 8;
        }
        
        [self showHighScore:0];
        
        
        // EnemiesDestroyedSprites
        
        float enemiesDestroyedX = 268.5;
        int enemiesDestroyedY = 20;
        enemiesDestroyedSprites = [NSMutableArray new];
        for(int i = 0; i < NUM_ENEMIES_DESTROYED_SRITES; i++)
        {
            SKColor *color = [Game colorFromHexString:@"#ff6000"];
            SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:fontArray[NUMBER_INDEX_IN_FONT]];
            node.position = CGPointMake(enemiesDestroyedX, enemiesDestroyedY);
            node.zPosition = Z_POSITION_PANEL_ELEMENTS;
            node.size = CGSizeMake(8, 8);
            node.color = color;
            node.colorBlendFactor = 1.0;
            [panelNode addChild:node];
            [enemiesDestroyedSprites addObject:node];
            enemiesDestroyedX += 8;
        }
        

        [self showNumEnemiesDestroyed: 0];
        
        
        // num Fighters available
        
        float numFightersX = 268.5;
        int numFightersY = 39;
        numFighterSpites = [NSMutableArray new];
        for(int i = 0; i < NUM_NUM_FIGHTER_SRITES; i++)
        {
            SKColor *color = [Game colorFromHexString:@"#ff6000"];
            SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:fontArray[NUMBER_INDEX_IN_FONT]];
            node.position = CGPointMake(numFightersX, numFightersY);
            node.zPosition = Z_POSITION_PANEL_ELEMENTS;
            node.size = CGSizeMake(8, 8);
            node.color = color;
            node.colorBlendFactor = 1.0;
            [panelNode addChild:node];
            [numFighterSpites addObject:node];
            numFightersX += 8;
        }
        
        [self showNumFighters:0];
        
        
        
        // Energy
        
        emptyEnergySprite = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"energy_empty"]];
        
        emptyEnergySprite.anchorPoint = CGPointMake(0, 0.5);
        emptyEnergySprite.position = CGPointMake(68, 11.5);
        emptyEnergySprite.zPosition = Z_POSITION_PANEL_ELEMENTS;
        
        
        
        SKCropNode *cropEnergyNode = [SKCropNode new];
        cropEnergyNode.position = CGPointMake(0, 0);
        
        energyMask = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(self.size.width, self.size.height)];
        energyMask.anchorPoint = CGPointMake(0, 0);

        energyMask.position =  CGPointMake(71 + INITIAL_ENERGY_LEVEL/4, energyMask.position.y);
        [self showEnergy:INITIAL_ENERGY_LEVEL];
        
        [cropEnergyNode setMaskNode:energyMask];
        
        [cropEnergyNode addChild:emptyEnergySprite];
        [panelNode addChild:cropEnergyNode];
        
        
        // Time
        timeSprite = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"timepixel.png"]];
        timeSprite.zPosition = Z_POSITION_PANEL_ELEMENTS;
        timeSprite.position = CGPointMake(self.size.width/2, 50);
        [panelNode addChild:timeSprite];
        
        
        // Speed
        
        speedLeft = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"fullspeed.png"]];
        speedLeft.zPosition = Z_POSITION_PANEL_ELEMENTS;
        speedLeft.position = CGPointMake(0, 0);
        speedLeft.anchorPoint = CGPointMake(0, 0);
        
        speedRight = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"fullspeed.png"]];
        speedRight.zPosition = Z_POSITION_PANEL_ELEMENTS;
        speedRight.position = CGPointMake(320-26, 0);
        speedRight.anchorPoint = CGPointMake(0, 0);
        
        
        SKCropNode *cropSpeedNode = [SKCropNode new];
        cropSpeedNode.position = CGPointMake(8, 7);
        speedMask = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(self.size.width, self.size.height)];
        speedMask.anchorPoint = CGPointMake(0, 0);
        
        speedMask.position  = CGPointMake(0, 0);
        
        self.speed = 1;
        
        [cropSpeedNode setMaskNode:speedMask];
        [cropSpeedNode addChild:speedLeft];
        [cropSpeedNode addChild:speedRight];
        
        
        [panelNode addChild:cropSpeedNode];
        
        
        
        
        // alarm
        
        alarmSprite = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"empty_alarm.png"]];
        alarmSprite.zPosition = Z_POSITION_PANEL_ELEMENTS;
        alarmSprite.position = CGPointMake(0, 0);
        alarmSprite.anchorPoint = CGPointMake(0, 0);
        
        
        SKCropNode *cropAlarmNode = [SKCropNode new];
        cropAlarmNode.position = CGPointMake(68, 19);
        alarmMask = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(self.size.width, self.size.height)];
        alarmMask.anchorPoint = CGPointMake(0, 0);
        
        alarmMask.position  = CGPointMake(0, 0);
        [self startAlarmAnim:0];
        [cropAlarmNode setMaskNode:alarmMask];
        [cropAlarmNode addChild:alarmSprite];
        [panelNode addChild:cropAlarmNode];

        
        // level
        
        for(int i = 0; i < 3; i++)
        {
            levelBigSprites[i] = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"level_big.png"]];
            levelBigSprites[i].zPosition = Z_POSITION_PANEL_ELEMENTS;
            levelBigSprites[i].position = CGPointMake(216, 21.5 + i * 6);
            [panelNode addChild:levelBigSprites[i]];
        }

        for(int i = 0; i < 6; i++)
        {
            levelSmallSprites[i] = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"level_small.png"]];
            levelSmallSprites[i].zPosition = Z_POSITION_PANEL_ELEMENTS;
            levelSmallSprites[i].position = CGPointMake(237, 21.5 + i * 6);
            [panelNode addChild:levelSmallSprites[i]];
        }
        _level = 999999;
        self.level = 1;
        
        // Bonus
        

        bonusTextures = [[NSMutableArray alloc] init];
        for(int i = 0; i < NUM_BONUS_SPRITES; i++)
        {
            texture = [panelAtlas textureNamed: [NSString stringWithFormat:@"bonus_%d.PNG", i]];
            [bonusTextures addObject:texture];
        }
        
        emptyBonusTexture = [panelAtlas textureNamed: @"bonus_8.PNG"];
        
        bonusSprite = [SKSpriteNode spriteNodeWithTexture:emptyBonusTexture];
        bonusSprite.zPosition = Z_POSITION_PANEL_ELEMENTS;
        bonusSprite.position = CGPointMake(112, 33);
        //bonusSprite.hidden = YES;
        [panelNode addChild:bonusSprite];
        
        SKAction* bonus = [SKAction animateWithTextures:bonusTextures timePerFrame:0.1];
        
        bonusAnim = [SKAction sequence:@[
                                                      bonus,
                                                      [bonus reversedAction],
                                                       ]];
        
        
        self.bonusFlag = NO;

        
        
        // HighScorePosition
        
        highScorePosition = [SKSpriteNode spriteNodeWithTexture:[panelAtlas textureNamed:@"highscore-position.png"]];
        highScorePosition.zPosition = Z_POSITION_PANEL_ELEMENTS;
        highScorePosition.position = CGPointMake(30, 10);
        highScorePosition.anchorPoint = CGPointMake(0, 0);
        
        SKCropNode *cropHighScorePositionNode = [SKCropNode new];
        cropHighScorePositionNode.position = CGPointMake(6, 6);
        highScorePositionMask = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(self.size.width, self.size.height)];
        highScorePositionMask.anchorPoint = CGPointMake(0, 0);
        highScorePositionMask.position  = CGPointMake(0, 0);
        [cropHighScorePositionNode setMaskNode:highScorePositionMask];
        [cropHighScorePositionNode addChild:highScorePosition];
        [panelNode addChild:cropHighScorePositionNode];
        
        self.positionInHighScore = 1;
        self.positionInHighScore = 0;
        
    }
    return self;
}

-(void) startAlarmAnim:(uint) level{
    alarmMask.position  = CGPointMake(0, 0 + 0);
    [alarmMask removeAllActions];
    
    if(level != 0)
    {
        int distance = level * 5;
        SKAction* alarmSequence = [SKAction sequence:@[
                                                       [SKAction moveByX:0 y:distance duration:0.5],
                                                       [SKAction moveByX:0 y:distance * -1 duration:0.5],
                                                       ]];
        
        SKAction* repeatAction = [SKAction repeatActionForever:alarmSequence];
        [alarmMask runAction:repeatAction];
    }
    
}

-(void) startTimer
{
    timeSprite.xScale = 1;
    SKAction *timeAction = [SKAction scaleXTo:120 duration:TIME_PER_LEVEL];
    [timeSprite runAction:timeAction];
    NSLog(@"Panel startTimer");
}



-(void) setRadarStartPositions{
    radarLeft.position = CGPointMake(79, 69);
    radarCenter.position = CGPointMake(159, 69);
    radarRight.position = CGPointMake(239, 69);
}



-(void) radarHandler{
    
    switch (radarCounter) {
        case 0:
        {
            [radarLeft runAction:actionRadar completion:^{[self radarHandler];}];
        }
        break;
            
        case 1:
        {
            [radarCenter runAction:actionRadar completion:^{[self radarHandler];}];
        }
        break;
            
        case 2:
        {
            [radarRight runAction:actionRadar completion:^{[self radarHandler];}];
        }
        break;
        
        }
    
    radarCounter++;
    if(radarCounter == 3)
        radarCounter = 0;
    
}

-(void) addPanelToNode:(SKNode*) sceneNode{
    [sceneNode addChild:panelNode];
}


-(void) showScore:(uint) score{
            for(int i = 0; i < NUM_SCORE_SPRITES; i++)
            {
                int modulo = score % 10 + NUMBER_INDEX_IN_FONT;
                SKSpriteNode *n = (SKSpriteNode*)scoreSprites[(NUM_SCORE_SPRITES-1)-i];
                n.texture = fontArray[modulo];
                n.size = CGSizeMake(8, 8);
                score = score / 10;
            }
}

-(void) showHighScore:(uint) highScore{
        for(int i = 0; i < NUM_SCORE_SPRITES; i++)
        {
            int modulo = highScore % 10 + NUMBER_INDEX_IN_FONT;
            SKSpriteNode *n = (SKSpriteNode*)highScoreSprites[(NUM_SCORE_SPRITES-1)-i];
            n.texture = fontArray[modulo];
            n.size = CGSizeMake(8, 8);
            highScore = highScore / 10;
        }
}


-(void) showNumEnemiesDestroyed:(uint) numEnemiesDestroyed{
        for(int i = 0; i < NUM_ENEMIES_DESTROYED_SRITES; i++)
        {
            int modulo = numEnemiesDestroyed % 10 + NUMBER_INDEX_IN_FONT;
            SKSpriteNode *n = (SKSpriteNode*)enemiesDestroyedSprites[(NUM_ENEMIES_DESTROYED_SRITES-1)-i];
            n.texture = fontArray[modulo];
            n.size = CGSizeMake(8, 8);
            numEnemiesDestroyed = numEnemiesDestroyed / 10;
        }
}

-(void) showNumFighters:(uint) numFighters{
        for(int i = 0; i < NUM_NUM_FIGHTER_SRITES; i++)
        {
            int modulo = numFighters % 10 + NUMBER_INDEX_IN_FONT;
            SKSpriteNode *n = (SKSpriteNode*)numFighterSpites[(NUM_NUM_FIGHTER_SRITES-1)-i];
            n.texture = fontArray[modulo];
            n.size = CGSizeMake(8, 8);
            numFighters = numFighters / 10;
        }
}

-(void) showEnergy:(int)energy{
    SKAction *action = [SKAction moveTo: CGPointMake(71 + energy/4, energyMask.position.y) duration:0.5];
    [energyMask runAction:action];
}

// 1 = links, 2 = mitte, 3 = rechts
-(void) setBigShipAlarm:(int)bigShipAlarm{
    _bigShipAlarm = bigShipAlarm;
    [radarLeft removeAllActions];
    [radarCenter removeAllActions];
    [radarRight removeAllActions];
    
    if(_bigShipAlarm > 0)
    {
        SKSpriteNode *alarmNode;

        
        switch (_bigShipAlarm) {
            case 1:
                alarmNode = radarLeft;
                break;
                
            case 2:
                alarmNode = radarCenter;
                break;
                
            case 3:
                alarmNode = radarRight;
                break;
                
            default:
                break;
        }
        
        SKAction *action = [SKAction repeatActionForever:actionRadar];
        [alarmNode runAction:action];
        radarAlarmLeft.hidden = NO;
        radarAlarmCenter.hidden = NO;
        radarAlarmRight.hidden = NO;
        
    }
    else
    {
        [self setRadarStartPositions];
        radarCounter = 0;
        [self radarHandler];
        radarAlarmLeft.hidden = YES;
        radarAlarmCenter.hidden = YES;
        radarAlarmRight.hidden = YES;
    }
}

-(int) bigShipAlarm{
    return _bigShipAlarm;
}


-(void) setSpeed: (uint) speed{
    if(speed > 10)
        speed = 10;
    
    _speed = speed;
    int yOffset = speed * 6;                            // 6 Pixel Abstand von Element zu Element
    speedMask.position  = CGPointMake(0, -72 + yOffset);
}


-(uint) speed{
    return _speed;
}

-(void) setAlarmLevel: (uint) alarmLevel{
    if(alarmLevel > 7)
        alarmLevel = 7;
    
    _alarmLevel = alarmLevel;
    [self startAlarmAnim:alarmLevel];
    NSLog(@"new AlarmLevel: %d", alarmLevel);

}


-(uint) alarmLevel{
    return _alarmLevel;
}


-(void) setLevel:(uint)level{
    if(level > NUM_LEVELS)
        level = NUM_LEVELS;
    
    if(_level != level)
    {
        _level = level;
        NSLog(@"new GameLevel: %d", level);
        
        int modulo = (level - 1) % 6;
        modulo ++;
        for(int i = 0; i < 6; i++)
        {
            if(modulo <= i)
            {
                levelSmallSprites[i].hidden = YES;
            }
            else
            {
                levelSmallSprites[i].hidden = NO;
            }
        }
        
        int value = (level + 6) / 6;
        for(int i = 0; i < 3; i++)
        {
            if(value <= i)
            {
                levelBigSprites[i].hidden = YES;
            }
            else
            {
                levelBigSprites[i].hidden = NO;
            }
        }
    }
}


-(uint) level{
    return _level;
}

-(void) setBonusFlag:(bool)bonusFlag{
   
    _bonusFlag = bonusFlag;
    NSLog(@"new BonusFlag: %d", bonusFlag);
    
    [bonusSprite removeAllActions];
    if(bonusFlag)
    {
        [bonusSprite runAction:[SKAction repeatActionForever:bonusAnim]];
    }
    else
    {
        [bonusSprite setTexture:emptyBonusTexture];
    }
    
}


-(bool) bonusFlag{
    return _bonusFlag;
}

-(void) setPositionInHighScore:(uint)positionInHighScore{
   
    if(_positionInHighScore != positionInHighScore){
        _positionInHighScore = positionInHighScore;
        NSLog(@"Panel: new positionInHighScore: %d", positionInHighScore);

        
        if(positionInHighScore >= 11)
            positionInHighScore = 11;

        if(positionInHighScore == 0)
            positionInHighScore = 11;
        
        int pos = 11 - positionInHighScore;
        
        int yOffset = pos * 6;                            // 6 Pixel Abstand von Element zu Element
        highScorePositionMask.position  = CGPointMake(0, -72 + yOffset);

    }
}
    
    
-(uint) positionInHighScore{
    return _positionInHighScore;
}


-(void) setNumFighters:(uint)numFighters{
    if(_numFighters != numFighters){
        _numFighters = numFighters;
        NSLog(@"new numFighters: %d", numFighters);
        [self showNumFighters:numFighters];
    }
}
    
    
-(uint) numFighters{
    return _numFighters;
}

-(void) setNumEnemiesDestroyed:(uint)numEnemiesDestroyed{
    if(_numEnemiesDestroyed != numEnemiesDestroyed){
        _numEnemiesDestroyed = numEnemiesDestroyed;
        NSLog(@"new numFighters: %d", numEnemiesDestroyed);
        [self showNumEnemiesDestroyed: numEnemiesDestroyed];
    }
}
    
    
-(uint) numEnemiesDestroyed{
    return _numEnemiesDestroyed;
}

-(void) setEnergy:(uint)energy{
    if(_energy != energy){
        _energy = energy;
        NSLog(@"new energy: %d", energy);
        [self showEnergy: energy];
    }
}
    
    
-(uint) energy{
    return _energy;
}

-(void) setHighScore:(uint)highScore{
    if(_highScore != highScore){
        _highScore = highScore;
        NSLog(@"new highScore: %d", highScore);
        [self showHighScore: highScore];
    }
}
    
    
-(uint) highScore{
    return _highScore;
}

-(void) setScore:(uint)score{
    if(_score != score){
        _score = score;
        NSLog(@"new score: %d", score);
        [self showScore: score];
    }
}
    
    
-(uint) score{
    return _score;
}

    
@end
