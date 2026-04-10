//
//  SpaceshipScene.m
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

@import CoreMotion;
@import AVFoundation;

#import "constants.h"
#import "SpaceshipScene.h"
#import "Fighter.h"
#import "Panel.h"
#import "BigShip.h"
#import "Enemies.h"
#import "Joystick.h"

//Terrain
const int terrainByteSize = 4096;
const int terrainWidth = 10;
const int terrainHeight = terrainByteSize / terrainWidth;

// TileSet
const int numTiles = 10 *  11;   // Original IFF-Bild war 10 Elemente breit, 11 hoch
const int tileWidth = 32;
const int tileHeight = 20;
const int TILE_LASER_LEFT = 0;
const int TILE_LASER_RIGHT = 1;

//dimensions & positions

int upDownTouchBorder = 145;        // Touchs oberhalb dieser Grenze gelten als "up/down." Unterhalb als "links" bzw. "rechts" Bewegungen des Fighters

int shootTouchBorder = 210;        // Touchs oberhalb dieser Grenze gelten als "Fire." Unterhalb als "links" bzw. "rechts" Bewegungen des Fighters




// collision
static const uint32_t fighterCategory =  0x1 << 0;          // unser "Fighter"
static const uint32_t fighterShootsCategory =  0x1 << 1;    // die Schüsse unseres Fighters
static const uint32_t tileSpecialCategory =  0x1 << 2;       // alle Tiles welche eine Action für unseren Fighter auslösen
static const uint32_t tileShootableForFighter =  0x1 << 3;   // alle Tiles welche Ziele für die Schüsse des Fighters sind
static const uint32_t tileColidableCategory =  0x1 << 4;   // alle Tiles welche mit unserem Fighter kollidieren können
static const uint32_t enemyCategory =  0x1 << 5;            // gegnerische Raumschiffe
static const uint32_t enemyShootsCategory =  0x1 << 6;            // Schüsse der gegnerischen Raumschiffe
static const uint32_t bigShipCategory =  0x1 << 7;            // gegnerisches grosses Raumschiff
static const uint32_t bigShipShootsCategory =  0x1 << 8;            // Schüsse des gegnerischen grossen Raumschiffs

enum BigShipState{
    StateWeitVorne,
    StateKommtBald,
    StateOnScreen,
    StateShooting,
    StateHitByShot,
    StateVorbeiGeflogen
};


enum SpeedChange{
    NoChange,
    Faster,
    Slower
};

enum FighterMove{
    NoMove,
    LeftMove,
    RightMove
};

enum SceneState{
    Running,                    // Spiel läuft normal
    Paused,                     // pausiert (MFi Controller)
    LevelCompleted,             // LevelEnde wurde erreicht
    BonusCounting,              // Levelende wurde erreicht. Nun wird Bonus angezeigt
    FighterExploding,           // Fighter ist am explodieren. Es dürfen keine weiteren Aktionen ausgelöst werden
    FighterExploded,            // Fighter Explosion ist absgeschlossen --> Terrain rausscrollen
    TerrainMovingOut,           // Terrain ist am raussscrollen
    TerrainMovedOutForNextFighter, // Terrain ist rausgescrollt --> GameOver anzeigen
    TerrainMovedOutForNextLevel, // Terrain ist rausgescrollt --> zum nächsten Level
    GameOverShowing,            // GameOver Anzeige läuft
    GameOverFinished,           // fertig
    DoNothing
    
};

enum EnemyState{
    Initialized,
    Waiting,
    Flying
};


// Pro Terrain-Tile kann hier definiert werden ob ein Tile durch den Fighter abschiessbar ist. Der Wert im Array definiert die Tile-Nummer welche nach einem Treffer statdessen angezeigt werden soll.

const char shootableTiles[numTiles] = {
    10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};


// Pro Terrain-Tile kann hier definiert werden ob ein Tile mit dem Fighter eine Kollision auslösen soll.
const bool colidableTiles[numTiles] = {
    1, 1, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

// Pro Terrain-Tile kann hier definiert werden ob ein Tile eine spezielle Funktion hat.
const bool specialTiles[numTiles] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 0, 0, 0
};

const int numLevels = 18;

// für jeden der 18 Levels wird hier angebeben welches der drei Tilessetes geladen werden muss
const int levelAtlases[numLevels] = {
    1,1,2,1,2,3,2,3,3,1,3,2,2,1,3,2,1,3
};



// misc constants
const NSString* USERDATA_TILE_EXPLODED_NUMBER = @"TileExplodedNumber";
const NSString* USERDATA_TILE_NUMBER = @"TileNumber";




@interface SpaceshipScene (){
    bool terrainLineAdded[terrainHeight];           // pro Linie ein bool welches definiert ob die Nodes schon hinzugefügt wurden.

    SKSpriteNode* terrainTileNodes[terrainWidth * terrainHeight];
    SKTexture* tileTextures[numTiles];
    SKTexture* colorCycleTexture;
    SKNode* colorCycleNode;
    SKNode* terrainNode;
    SKNode* rootNode;
    NSData* levelData;
    Game* game;
    Panel* panel;
    int levelNr;
    int fighterYPos;
    enum FighterMove fighterMove;
    enum SpeedChange speedChange;
    Fighter* fighter;
    float scrollSpeed;
    int scrollSpeedDetectCounter;
    AVAudioPlayer *_backgroundAudioPlayer;
    enum SceneState sceneState;
    BigShip *bigShip;
    int bigShipXIndex;              // linker Rand, in der Mitte oder rechter Rand.
    Enemies *enemies;
    enum EnemyState enemyState;
    NSTimer* enemyTimer;
    enum BigShipState bigShipState;
    SKAction *actionPlayTileHitSound;
    NSTimer *leftRightSwappedTimer;
    bool leftRightSwapped;
    CGPoint newFighterPosition;
    NSTimer *turboFighterTimer;
    bool turboFighter;
    NSTimer *invisbleFighterTimer;
    bool invisibleFighter;
    NSTimer* levelTimer;
    NSTimer *superShootTimer;
    bool superShoot;
    bool bonusFlag;
    uint scoreWithBonus;        // auf diesen Wert muss der Score bei Levelende raufgezählt werden (wenn Bonusflag gesetzt
    Joystick* joyStick;
    bool _fireButtonAdded;
    uint _numShoots;
    
    UITouch* joyStickDown;
    UITouch* joyStickUp;


    UITouch* joyStickLeft;
    UITouch* joyStickRight;
    CMMotionManager* _motionManager;
    float _fighterMoveSpeed;
    SKSpriteNode* _pauseModeSprite;
}


@property BOOL contentCreated;
@end


@implementation SpaceshipScene

- (void)startGame:(Game*) pgame withView:(SKView *)view atLevel:(int) level{
    NSLog(@"SpaceshipScene start");
    levelNr = level;
    game = pgame;
    scrollSpeed = INITIAL_SCROLL_SPEED;
    fighterMove = NoMove;
    speedChange = NoChange;
    sceneState = Running;
    game.energyLevel = INITIAL_ENERGY_LEVEL;
    game.enemiesDestroyed = 0;
    _numShoots = 0;
    _motionManager = [CMMotionManager new];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self startMonitoringAcceleration];
}

-(void) willMoveFromView{
    NSLog(@"SpaceshipScene willMoveFromView");
    
}


- (void)didMoveToView:(SKView *)view
{
    
    NSLog(@"SpaceshipScene didMoveToView");
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
        
        panel.alarmLevel = 3;
        bonusFlag = NO;
        panel.bonusFlag = bonusFlag;
        panel.level = levelNr;
        

        view.multipleTouchEnabled = YES;

        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        [self startBackgroundNoise];
        

        newFighterPosition = CGPointMake(-1, -1);
        [panel startTimer];
        levelTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_PER_LEVEL target:self selector:@selector(levelTimerFired:) userInfo:Nil repeats:NO];
    
        if(!game.mFi.controllerConnected){
            [joyStick addFireButton];
            _fireButtonAdded = YES;
        }
        
    }
}

-(void) levelTimerFired:(NSTimer*) timer{
    NSLog(@"Out of time!");
    sceneState = FighterExploding;
    [fighter explode];
    
    
}
- (void)startBackgroundNoise
{
    NSError *err;
    NSURL *file = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Background.wav" ofType:nil]];
    _backgroundAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:&err];
    if (err) {
        NSLog(@"error in audio play %@",[err userInfo]);
        return;
    }
    [_backgroundAudioPlayer prepareToPlay];
    
    // this will play the music infinitely
    _backgroundAudioPlayer.numberOfLoops = -1;
    
    _backgroundAudioPlayer.enableRate = YES;
    [self setNoiseSpeed];
    
    [_backgroundAudioPlayer setVolume:0.3];
    [_backgroundAudioPlayer play];
}

-(void) setNoiseSpeed{
    _backgroundAudioPlayer.rate = scrollSpeed/2 + 1.0;
}


// muss gerufen werden beor Scene entfernt wird
-(void)prepareSceneRemove{
    
    [leftRightSwappedTimer invalidate];
    self.physicsWorld.contactDelegate = nil;
    [_backgroundAudioPlayer stop];

    [levelTimer invalidate];
    [enemyTimer invalidate];
    [leftRightSwappedTimer invalidate];
    [turboFighterTimer invalidate];
    [invisbleFighterTimer invalidate];
    [superShootTimer invalidate];
    [self stopMonitoringAcceleration];
    
}

- (void)startMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable) {
        [_motionManager startAccelerometerUpdates];
        NSLog(@"accelerometer updates on...");
    }
}

- (void)stopMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable && _motionManager.accelerometerActive) {
        [_motionManager stopAccelerometerUpdates];
        NSLog(@"accelerometer updates off...");
    }
}

- (void)updateShipPositionFromMotionManager
{
    CMAccelerometerData* data = _motionManager.accelerometerData;
    
    float dataXAbs;
    float dataX;
    
    UIDeviceOrientation orientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    
    
    if (UIDeviceOrientationIsLandscape(orientation))
    {
        dataXAbs = fabs(data.acceleration.y);
        dataX = data.acceleration.y;
    }
    else
    {
        dataXAbs = fabs(data.acceleration.x);
        dataX = data.acceleration.x;
    }
    
    // wenn der HomeButon auf der rechten Seite ist, muss Steuerung vertauscht werden (BugFix. Fehlte V1.1)
    if(orientation == UIDeviceOrientationLandscapeLeft)
    {
        dataX = dataX * -1;
    }
    
    if (dataXAbs > 0.02) {
        //NSLog(@"acceleration value = %f",dataX);
        _fighterMoveSpeed = dataXAbs * 20.0;
        
        if(dataX > 0.02)
        {
            if(!leftRightSwapped)
            {
                fighterMove = RightMove;
            }
            else
            {
                fighterMove = LeftMove;
            }
        }

        if(dataX < -0.02)
        {
            if(!leftRightSwapped)
            {
                fighterMove = LeftMove;
            }
            else
            {
                fighterMove = RightMove;
            }
        }
    }
    else
    {
        fighterMove = NoMove;
    }
}


- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    SKSpriteNode *s = (SKSpriteNode*)secondBody.node;
    NSLog(@"didBeginContact %@ %@ %x", firstBody.node.name, secondBody.node.name, s.physicsBody.categoryBitMask);
    
    
    
    // auf 0xffffffff prüfen. diese Bitmaske erscheint wenn Schuss ausserhalb des Displays ist. Grund unklar --> todo!
    if(secondBody.categoryBitMask != -1)
    {
        
        SKSpriteNode* s = (SKSpriteNode*)secondBody.node;
        NSLog(@"size %f %f", s.size.width, s.size.width);

         // testen ob Fighter-Shoot irgendetwas getroffen hat
        if ((firstBody.categoryBitMask & fighterShootsCategory) != 0)
        {
            if ((secondBody.categoryBitMask & tileShootableForFighter) != 0)
            {
                // ein relevantes Terrain-Tile wurde getroffen
                [firstBody.node removeFromParent];                      // Schuss entfernen
                game.score += SCORE_EXPLODED_TILE;
                
                SKSpriteNode *tile = (SKSpriteNode*)secondBody.node;
                SKSpriteNode *secondTile = nil;
                
                // prüfen ob ein "Laser"-Tile abgeschossen wurde. Wenn ja, existiert noch ein zweites "Laser"-Teil daneben.
                NSNumber *nsTileNumber = [tile.userData objectForKey: USERDATA_TILE_NUMBER];
                int tileNumber = [nsTileNumber intValue];
                
                [tile runAction:actionPlayTileHitSound];
                
                switch(tileNumber)
                {
                    case TILE_LASER_LEFT:
                        NSLog(@"Laser left");
                        secondTile = [self getTileNodeRalativeTo:tile  withOffset:-1];
                        break;
                        
                    case TILE_LASER_RIGHT:
                        NSLog(@"Laser right");
                        secondTile = [self getTileNodeRalativeTo:tile  withOffset:1];
                        break;
                        
                }
                
                
                
                // Terrain-Tile durch die explodierte Variante ersetzen. Deren Nummer steht im UserDataDictionary
                NSNumber *explodedTileNumber = [tile.userData objectForKey: USERDATA_TILE_EXPLODED_NUMBER];
                if(explodedTileNumber != Nil)
                {
                    tile.texture = tileTextures[[explodedTileNumber charValue]];
                    secondBody.categoryBitMask = 0;             // keine Kollisionserkennung mehr
                    secondBody.contactTestBitMask = 0;
                }
                
                // wenn nötig benachbartes Terrain-Tile durch die explodierte Variante ersetzen. Deren Nummer steht im UserDataDictionary
                if(secondTile != nil)
                {
                    explodedTileNumber = [secondTile.userData objectForKey: USERDATA_TILE_EXPLODED_NUMBER];
                    if(explodedTileNumber != Nil)
                    {
                        secondTile.texture = tileTextures[[explodedTileNumber charValue]];
                        secondTile.physicsBody.categoryBitMask = 0;
                        secondTile.physicsBody.contactTestBitMask = 0;
                    }
                }
                
                
                
            }
            
            // BigShip getroffen?
            if ((secondBody.categoryBitMask & bigShipCategory) != 0)
            {
                NSLog(@"bigship");
                // BigShip wurde getroffen
                if(!bigShip.isExploding){
                    
                    [firstBody.node removeFromParent]; // Schuss removen
                    
                    int distance = (bigShip.position.y - bigShip.size.height / 2) - (terrainNode.position.y * -1);
                    NSLog(@"BigShip distance %d", distance);
                    // dem BigShip mitteilen, dass es getroffen wurde. Je nach Antwort muss es dann explodieren.
                    if (distance < BIG_SHIP_MIN_DISTANCE_TO_HIT) {
                         [bigShip explode];
                        game.score += SCORE_EXPLODED_BIGSHIP;
                        bigShipState = StateHitByShot;
                        panel.bigShipAlarm = NO;
                        panel.alarmLevel = 3;
                        
                    }
                }
            }


            // enemy getroffen?
            if ((secondBody.categoryBitMask & enemyCategory) != 0)
            {
                [firstBody.node removeFromParent];                      // Schuss removen
                [enemies explodeEnemy:(SKSpriteNode*)secondBody.node];
                secondBody.categoryBitMask = 0;                         // keine Kollisionserkennung mehr
                secondBody.contactTestBitMask = 0;
                game.score += SCORE_EXPLODED_ENEMY;
                game.enemiesDestroyed += 1;
                
                // prüfen ob der hunderste Enemy abgeschossen wurde. Wenn ja, Bonusflag aktivieren
                if(!bonusFlag)
                {
                    if(game.enemiesDestroyed == NUM_ENEMIES_FOR_BONUS_MODE)
                    {
                        bonusFlag = YES;
                        panel.bonusFlag = bonusFlag;
                    }
                }
                
            }
        }
        
        // testen ob Fighter mit irgendetwas Kontakt hat
        if ((firstBody.categoryBitMask & fighterCategory) != 0)
        {
         
            // mit Kollisions-Tiles kollidiert?
            if ((secondBody.categoryBitMask & tileColidableCategory) != 0)
            {
                // cheat testen. wenn ja, nicht explodieren
                if(!game.cheatNoDangerousTileCollision)
                {
                    // Fighter explodieren lassen
                    if(sceneState == Running)
                    {
                        sceneState = FighterExploding;
                        [fighter explode];
                    }
                    secondBody.categoryBitMask = 0;             // keine Kollisionserkennung mehr
                    secondBody.contactTestBitMask = 0;
                }
            }
          
            
            // mit Spezial-Tiles kollidiert?
            if ((secondBody.categoryBitMask & tileSpecialCategory) != 0)
            {
                SKSpriteNode *tile = (SKSpriteNode*)secondBody.node;
                NSNumber *nsTileNumber = [tile.userData objectForKey: USERDATA_TILE_NUMBER];
                int tileNumber = [nsTileNumber intValue];
                NSLog(@"Specialtile: %d", tileNumber);
               
                [self tileHandler:tileNumber];
            }
            
            
            
            // Mit BigShip kollidiert?
            if ((secondBody.categoryBitMask & bigShipCategory) != 0)
            {
                // Fighter explodieren lassen
                if(sceneState == Running)
                {
                    sceneState = FighterExploding;
                    [fighter explode];
                }
                
                secondBody.categoryBitMask = 0;             // keine Kollisionserkennung mehr
                secondBody.contactTestBitMask = 0;
            }
            

            // Mit Enemy kollidiert?
            if ((secondBody.categoryBitMask & enemyCategory) != 0)
            {
                // Energy minus
                if(sceneState == Running)
                {
                    if(!game.cheatNoEnemyCollision){
                        game.energyLevel -= ENERGY_LOSS_AT_ENEMY_HIT;
                    }
                    [enemies explodeEnemy:(SKSpriteNode*)secondBody.node];  // Enemy explodieren lassen
                    game.enemiesDestroyed += 1;
                }
                secondBody.categoryBitMask = 0;             // keine Kollisionserkennung mehr
                secondBody.contactTestBitMask = 0;
            }
            
            
            // Mit EnemyShoots kollidiert?
            if ((secondBody.categoryBitMask & enemyShootsCategory) != 0)
            {
                // Fighter Energie abziehen
                if(sceneState == Running)
                {
                    if(!game.cheatNoEnemyCollision){
 
                        game.energyLevel -= ENERGY_LOSS_AT_ENEMY_SHOOT_HIT;
                    }
                }
                secondBody.categoryBitMask = 0;             // keine Kollisionserkennung mehr
                secondBody.contactTestBitMask = 0;
                [secondBody.node removeFromParent];         // Schuss entfernen
            }
            

            // Mit BigShip Shoot kollidiert?
            if ((secondBody.categoryBitMask & bigShipShootsCategory) != 0)
            {
                // Fighter Energie abziehen
                if(sceneState == Running)
                {
                    if(!game.cheatNoEnemyCollision){
                        sceneState = FighterExploding;
                        [fighter explode];
                    }
                }
                secondBody.categoryBitMask = 0;             // keine Kollisionserkennung mehr
                secondBody.contactTestBitMask = 0;
                [secondBody.node removeFromParent];         // Schuss entfernen
            }
            
            
       }
    }
}


// Aktionen der SpecialTiles auslösen (Superspeed, vertauschte Steuerung, etc.)
-(void) tileHandler:(int) tileNumber{

    switch (tileNumber) {
            // Energey hinzufügen, Score reduzieren
        case SPECIAL_TILE_ADD_ENERGY_SUB_SCORE:
            NSLog(@"SpecialTile: SPECIAL_TILE_ADD_ENERGY_SUB_SCORE");
            game.score -= SPECIAL_TILE_ADD_ENERGY_SUB_SCORE_SUB_SCORE;
            game.energyLevel += SPECIAL_TILE_ADD_ENERGY_SUB_SCORE_ADD_ENERGY;
            break;
            
            // Score hinzufügen, Energy reduzieren
        case SPECIAL_TILE_ADD_SCORE_SUB_ENERGY:
            NSLog(@"SpecialTile: SPECIAL_TILE_ADD_SCORE_SUB_ENERGY");
            game.score += SPECIAL_TILE_ADD_SCORE_SUB_ENERGY_ADD_SCORE;
            game.energyLevel -= SPECIAL_TILE_ADD_SCORE_SUB_ENERGY_SUB_ENERGY;
            break;
            
            // eine Zeit lang mit TurboSpeed fliegen
        case SPECIAL_TILE_LEFT_RIGHT_SWAPPED:
            NSLog(@"SpecialTile: SPECIAL_TILE_LEFT_RIGHT_SWAPPED");
            leftRightSwappedTimer = [NSTimer scheduledTimerWithTimeInterval:SPECIAL_TILE_LEFT_RIGHT_SWAPPED_DURATION target:self selector:@selector(leftRightSwappedTimerFired:) userInfo:Nil repeats:NO];
            leftRightSwapped = true;
            break;
            

            // Fighter auf andere Seite spiegeln
        case SPECIAL_TILE_MIRROR_FIGHTER:
            NSLog(@"SpecialTile: SPECIAL_TILE_MIRROR_FIGHTER");
            newFighterPosition = CGPointMake(game.sceneSize.width - fighter.position.x, fighter.position.y);
            break;

            // eine Zeit lang mit TurboSpeed fliegen
        case SPECIAL_TILE_TURBO_FIGHTER:
            NSLog(@"SpecialTile: SPECIAL_TILE_TURBO_FIGHTER");
            turboFighterTimer = [NSTimer scheduledTimerWithTimeInterval:SPECIAL_TILE_TURBO_FIGHTER_DURATION target:self selector:@selector(turboFighterTimerFired:) userInfo:Nil repeats:NO];
            turboFighter = true;
            scrollSpeed = SPECIAL_TILE_TURBO_FIGHTER_FULL_SPEED;
            panel.speed = scrollSpeed;
            break;

            // eine Zeit lang mit unsichtbar fliegen
        case SPECIAL_TILE_INVISIBLE_FIGHTER:
            NSLog(@"SpecialTile: SPECIAL_TILE_INVISIBLE_FIGHTER");
            invisbleFighterTimer  = [NSTimer scheduledTimerWithTimeInterval:SPECIAL_TILE_INVISIBLE_FIGHTER_DURATION target:self selector:@selector(invisibleFighterTimerFired:) userInfo:Nil repeats:NO];
            invisibleFighter = true;
            fighter.fighterSprite.hidden = true;
            break;

        
        // eine Zeit lang super Schuss
        case SPECIAL_TILE_SUPER_SHOOT:
        NSLog(@"SpecialTile: SPECIAL_TILE_SUPER_SHOOT");
        superShootTimer  = [NSTimer scheduledTimerWithTimeInterval:SPECIAL_TILE_SUPER_SHOOT_DURATION target:self selector:@selector(superShootTimerFired:) userInfo:Nil repeats:NO];
        superShoot = true;
        break;
        
        
        default:
            break;
    }
    
}

-(void)superShootTimerFired: (NSTimer*) timer{
    superShoot = false;
    NSLog(@"SpecialTile: SPECIAL_TILE_SUPER_SHOOT timer fired");
}
    
-(void)invisibleFighterTimerFired: (NSTimer*) timer{
    invisibleFighter = false;
    fighter.fighterSprite.hidden = false;
    NSLog(@"SpecialTile: SPECIAL_TILE_INVISIBLE_FIGHTER timer fired");
}

-(void)turboFighterTimerFired: (NSTimer*) timer{
    turboFighter = false;
    scrollSpeed = SPECIAL_TILE_TURBO_FIGHTER_NORMAL_SPEED;
    panel.speed = scrollSpeed;
    NSLog(@"SpecialTile: SPECIAL_TILE_TURBO_FIGHTER timer fired");
}


-(void)leftRightSwappedTimerFired: (NSTimer*) timer{
    leftRightSwapped = false;
            NSLog(@"SpecialTile: SPECIAL_TILE_LEFT_RIGHT_SWAPPED timer fired");
}

-(SKSpriteNode*)getTileNodeRalativeTo:(SKSpriteNode*) node withOffset:(int) offset
{
    SKSpriteNode* resultNode = nil;
    
    // SpriteNode in Array suchen
    int numNodes = terrainWidth * terrainHeight;
    int index = -1;
    for(int i = 0; i < numNodes; i++)
    {
        if(terrainTileNodes[i] == node)
        {
            index = i;
        }
    }
    
    // node gefunden?
    if(index >= 0)
    {
        index += offset;        //relativen offset des gesuchteb tiles addieren
        if(index >= 0)          // index darf nicht negativ sein
        {
            if(index <= numNodes)  // index darf nicht grösser als das Array sein
            {
                resultNode = terrainTileNodes[index];       // Pointer auf benachbarten SpriteNode
            }
        }
        
    }
    return resultNode;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //NSLog(@"touchesEnded");
    NSSet *allTouches = [event allTouches];
    for (UITouch *touch in allTouches)
    {
        switch (touch.phase) {
            case UITouchPhaseCancelled:
            case UITouchPhaseEnded:
                NSLog(@"UITouchPhaseEnded (or cancelled) touch:%x",  (int)touch);
                
                // wurde "up" losgelassen?
                if(touch == joyStickUp)
                {
                    joyStickUp = nil;
                    speedChange = NoChange;
                    [joyStick hoverDownLeft:NO right:NO up:YES down:NO];
                    
                    // ist gleichzeitig "Down" noch gedrückt?
                    if(joyStickDown != nil)
                    {
                        // wenn ja,  Gas wieder weg nehmen
                        speedChange = Slower;
                    }
                    
                }

                // wurde "down" losgelassen?
                if(touch == joyStickDown)
                {
                    joyStickDown = nil;
                    speedChange = NoChange;
                    [joyStick hoverDownLeft:NO right:NO up:NO down:YES];
                    
                    // ist gleichzeitig "up" noch gedrückt?
                    if(joyStickUp != nil)
                    {
                        // wenn ja, wieder Gas geben
                        speedChange = Faster;
                    }
                    
                }

                
                // wurde "left" losgelassen?
                if(touch == joyStickLeft)
                {
                    joyStickLeft = nil;
                    fighterMove = NoMove;
                    [joyStick hoverDownLeft:YES right:NO up:NO down:NO];
                    
                    // ist gleichzeitig "right" noch gedrückt?
                    if(joyStickRight != nil)
                    {
                        // wenn ja, wieder nach rechts steuern
                        fighterMove = RightMove;
                    }
                }

                
                // wurde "right" losgelassen?
                if(touch == joyStickRight)
                {
                    joyStickRight = nil;
                    fighterMove = NoMove;
                    [joyStick hoverDownLeft:NO right:YES up:NO down:NO];
                    
                    // ist gleichzeitig "left" noch gedrückt?
                    if(joyStickLeft != nil)
                    {
                        // wenn ja, wieder nach links steuern
                        fighterMove = LeftMove;
                    }
                }
                
                break;
                
            default:
                break;
        }
    }
    
}


// prüft in welchem Bereich geklickt wurde (Classc Stearing)

// unser Fighter soll schiessen
-(void)fighterShoot{
    [fighter shoot:superShoot];  // schiessen (ja nach Status von "superShoot" normal oder super)
    game.energyLevel -= ENERGY_LOSS_AT_SHOOT;
    _numShoots++;
    if(_fireButtonAdded)
    {
        if(_numShoots >= FIRE_BUTTON_REMOVE)        // nach 10 Schüssen wird Firebutton komplett ausgeblendet
        {
            [joyStick removeFireButton];
            _fireButtonAdded = 0;
        }
    }
}

- (void)touchesBeganClassic:(UITouch *)touch touchLocation:(CGPoint)touchLocation
{
    // testen ob im "FireButton" - Bereich getouched wurde
    
    if(touchLocation.y > shootTouchBorder)
    {
        [self fighterShoot];
    }
    
    // testen ob im "Up / Down" - Breich getouched wurde
    
    else if(touchLocation.y > upDownTouchBorder)
    {
        // links oder rechts bzw. down oder up
        if(touchLocation.x < 320/2)
        {
            NSLog(@"slower");
            speedChange = Slower;
            [joyStick hoverUpLeft:NO right:NO up:NO down:YES];
            joyStickDown = touch;
        }
        else
        {
            NSLog(@"faster");
            speedChange = Faster;
            [joyStick hoverUpLeft:NO right:NO up:YES down:NO];
            joyStickUp = touch;
        }
    }
    
    // testen ob im "Left / Right" - Bereich getouched wurde
    
    
    // wenn SpecialTile "LeftRightSwapped" aktiv ist, wird X-Steuerung vertauscht
    int x = touchLocation.x;
    if(leftRightSwapped){
        x = game.sceneSize.width - x;
    }
    
    
    if(touchLocation.y < upDownTouchBorder)
    {
        // links oder rechts bzw. down oder up
        if(x < 320/2)
        {
            NSLog(@"left");
            fighterMove = LeftMove;
            _fighterMoveSpeed = 5;
            [joyStick hoverUpLeft:YES right:NO up:NO down:NO];
            joyStickLeft = touch;
        }
        else
        {
            NSLog(@"right");
            fighterMove = RightMove;
            _fighterMoveSpeed = 5;
            [joyStick hoverUpLeft:NO right:YES up:NO down:NO];
            joyStickRight = touch;
        }
    }
}

// prüft in welchem Bereich geklickt wurde (Accelerometer Stearing)
- (void)touchesBeganWithAccelerometer:(UITouch *)touch touchLocation:(CGPoint)touchLocation
{
    
    if([joyStick.arrowUp containsPoint:touchLocation])
    {
        speedChange = Faster;
        [joyStick hoverUpLeft:NO right:NO up:YES down:NO];
        joyStickUp = touch;
    }

    else if([joyStick.arrowDown containsPoint:touchLocation])
    {
        speedChange = Slower;
        [joyStick hoverUpLeft:NO right:NO up:NO down:YES];
        joyStickDown = touch;
    }
    else
    {
        [fighter shoot:superShoot];  // schiessen (ja nach Status von "superShoot" normal oder super)
        game.energyLevel -= ENERGY_LOSS_AT_SHOOT;
        _numShoots++;
        
    }
}

// prüft in welchem Bereich geklickt wurde (TwoFinger Stearing)
- (void)touchesBeganWithTwoFinger:(UITouch *)touch touchLocation:(CGPoint)touchLocation
{
    
    if([joyStick.arrowUp containsPoint:touchLocation])
    {
        speedChange = Faster;
        [joyStick hoverUpLeft:NO right:NO up:YES down:NO];
        joyStickUp = touch;
    }
    
    else if([joyStick.arrowDown containsPoint:touchLocation])
    {
        speedChange = Slower;
        [joyStick hoverUpLeft:NO right:NO up:NO down:YES];
        joyStickDown = touch;
    }
    
    else if([joyStick.arrowLeft containsPoint:touchLocation])
    {
        NSLog(@"left");
        
        if(!leftRightSwapped)
        {
            fighterMove = LeftMove;
        }
        else
        {
            fighterMove = RightMove;
        }
        
        _fighterMoveSpeed = 5;
        [joyStick hoverUpLeft:YES right:NO up:NO down:NO];
        joyStickLeft = touch;
    }
    else if([joyStick.arrowRight containsPoint:touchLocation])
    {
        NSLog(@"right");
        
        if(!leftRightSwapped)
        {
            fighterMove = RightMove;
        }
        else
        {
            fighterMove = LeftMove;
        }
        
        
        _fighterMoveSpeed = 5;
        [joyStick hoverUpLeft:NO right:YES up:NO down:NO];
        joyStickRight = touch;
    }

    
    else
    {
        [fighter shoot:superShoot];  // schiessen (ja nach Status von "superShoot" normal oder super)
        game.energyLevel -= ENERGY_LOSS_AT_SHOOT;
        _numShoots++;
        
    }
}

// wird gerufen wenn Display berührt wird. n Z.B. zum Schiessen oder beim "Joystick" bedienen
- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSSet *allTouches = [event allTouches];
    CGPoint touchLocation;
    
    if(sceneState == Running)       // nur schiessen wenn Scene im normalen Zustand ist
    {
        for (UITouch *touch in allTouches)
        {
            touchLocation = [touch locationInView:touch.view];
            touchLocation = [self convertPointFromView: touchLocation];     // null-punkt unten links
            
            
            switch (touch.phase)
            {
                case UITouchPhaseBegan:
                    NSLog(@"UITouchPhaseBegan x:%f, y:%f, touch:%x", touchLocation.x, touchLocation.y,  (int)touch);
                    
                    switch(game.steeringMode)
                    {
                        case SteeringMode_Classic:
                            [self touchesBeganClassic:touch touchLocation:touchLocation];
                            break;
                        
                        case SteeringMode_Accelerometer:
                            [self touchesBeganWithAccelerometer:touch touchLocation:touchLocation];
                            break;
                        
                        case SteeringMode_TwoFingers:
                            [self touchesBeganWithTwoFinger:touch touchLocation:touchLocation];
                            break;
                            
                        default:    // jeden anderen Steeringmode (z.B MFi ignorieren)
                            break;
                            
                    }
                    break;
                    
                default:
                    break;
            }
            
            
          //  NSLog(@"touchesBegan %f, %f, %x %x %d", touchLocation.x, touchLocation.y, (int)event, (int)touch, (int) touch.phase);
            
            

        }
    }
    else
    {
        // Pausenmodus --> prüfen ob dieser aufgehoben werden soll
        if(sceneState == Paused){
            game.gamePaused = NO;
            
        }
    }
}





- (void)addTerrainLine:(int) terrainDataOffset terrainY:(int) terrainY
{
  //  NSLog(@"addTerrainLine y: %d", terrainY);
    
    
    int levelOffset = (levelNr - 1) * terrainByteSize;
    
    
    for(int terrainX = 0; terrainX < terrainWidth; terrainX++)
    {
        uint8_t *t = (uint8_t*)levelData.bytes + 1;     // Das "+1" ist unlogisch. Aber die Daten sind wirklich um ein Byte verschoben :-(. Wenn sie so gezeichnet werden wie sie im File sind, ist das ganze Bild um ein Element gegenüber dem Original-Game verschoben.
        
        unsigned char c = t[terrainDataOffset + levelOffset];
        int terrainXMirrored = 9 - terrainX;
        SKSpriteNode *tile = [SKSpriteNode spriteNodeWithTexture:tileTextures[c]];
        tile.name = @"normal tile";
        terrainTileNodes[terrainDataOffset] = tile;
        
        
        
        // X-Positionierung ist aus folgenden zwei Gründes etwas speziell: 1. Im Original-TerrainFile sind die X-Koordinaten gespiegelt (who knows why!) und der Null-Punkt ist beim SpriteKit in der Mitte des Sprites
        tile.position = CGPointMake(terrainXMirrored * tileWidth + tileWidth/2, (terrainY * tileHeight) + panel.size.height);
        [terrainNode addChild:tile];
        
        // ist es ein spezielles Tile? (abschiessbar oder Hinderniss für Fighter)
        if(shootableTiles[c] != 0 | colidableTiles[c] != NO | specialTiles[c] != NO)
        {

            NSNumber* cWrapped = [NSNumber numberWithInt:c];
            tile.userData = [NSMutableDictionary dictionary];
            [tile.userData setObject:cWrapped forKey:USERDATA_TILE_NUMBER];     // im UserData-Dictionary wird die TileNummer des Tiles eingtragen
            
            if(shootableTiles[c] != 0)  // shootable Tile?
            {
                tile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:tile.size];
                tile.name = @"TileShootable ";
                
                tile.physicsBody.categoryBitMask = tileShootableForFighter;
                tile.physicsBody.contactTestBitMask = fighterShootsCategory;
                tile.physicsBody.collisionBitMask = 0;
                tile.physicsBody.affectedByGravity = NO;
                tile.physicsBody.usesPreciseCollisionDetection = NO;
                tile.physicsBody.dynamic = YES;
                cWrapped = [NSNumber numberWithInt:shootableTiles[c]];
                [tile.userData setObject:cWrapped forKey:USERDATA_TILE_EXPLODED_NUMBER];     // im UserData-Dictionary wird die TileNummer des getroffenen Tiles eingtragen

            }
            
            
            if(colidableTiles[c] != NO)
            {
                tile.name = @"TileColidable";
                if(tile.physicsBody == Nil)
                {
                    tile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(tile.size.width-5, tile.size.height/4)];   // Kollision nur im inneren Bereich
                    tile.physicsBody.categoryBitMask = 0;
                    tile.physicsBody.contactTestBitMask = 0;
                }
                tile.physicsBody.categoryBitMask = tile.physicsBody.categoryBitMask | tileColidableCategory;
                tile.physicsBody.contactTestBitMask = fighterCategory | tile.physicsBody.contactTestBitMask;
                tile.physicsBody.collisionBitMask = 0;
                tile.physicsBody.affectedByGravity = NO;
                tile.physicsBody.usesPreciseCollisionDetection = NO;
                tile.physicsBody.dynamic = YES;
            }

            
            if(specialTiles[c] != NO)
            {
                tile.name = @"TileSpecial";
                if(tile.physicsBody == Nil)
                {
                    tile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:tile.size];
                    tile.physicsBody.categoryBitMask = 0;
                    tile.physicsBody.contactTestBitMask = 0;
                }
                tile.physicsBody.categoryBitMask = tile.physicsBody.categoryBitMask | tileSpecialCategory;
                tile.physicsBody.contactTestBitMask = fighterCategory | tile.physicsBody.contactTestBitMask;
                tile.physicsBody.collisionBitMask = 0;
                tile.physicsBody.affectedByGravity = NO;
                tile.physicsBody.usesPreciseCollisionDetection = YES;
                tile.physicsBody.dynamic = YES;
            }
        }
        else
        {
            tile.name = @"TileNormal";
        }
        terrainDataOffset++;
    }
}



- (void)addCycleSprites:(SKNode*) node
{
    colorCycleNode = [SKNode new];
    
    for(int terrainY = 0; terrainY < 9; terrainY++)
    {
        SKSpriteNode *tile = [SKSpriteNode spriteNodeWithTexture:colorCycleTexture];
        tile.zPosition = Z_POSITION_COLOR_CYCLE;
        tile.position = CGPointMake(0, (terrainY * 61));
        tile.size = CGSizeMake(320, 61);
        tile.anchorPoint = CGPointMake(0, 0);
        [colorCycleNode addChild:tile];
    }
    
    [node addChild:colorCycleNode];
    
    SKAction *moveDown = [SKAction moveByX:0 y:61 duration:1];
    SKAction *moveUp = [SKAction moveByX:0 y:-61 duration:0];
    SKAction *seq = [SKAction sequence:@[
                         moveDown,
                         moveUp
                         ]
     ] ;;
    
    [colorCycleNode runAction:[SKAction repeatAction:seq count:-1]];
}




- (void)prepareTerrain:(SKNode*) node
{
    terrainNode = [[SKNode alloc] init];
    terrainNode.name = @"TerrainNode";
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"levels" ofType:@"bin"];
    levelData = [NSData dataWithContentsOfFile:filePath];
    
    // zum Testen der Special Tiles (muss für produktive Version entfernt werden)
   // unsigned char* p = (unsigned char*)levelData.bytes;
   // p[55] = SPECIAL_TILE_LEFT_RIGHT_SWAPPED;
    
    int terrainDataOffset = 0;
    
    for(int terrainY = 0; terrainY < 30; terrainY++)
    {
        [self addTerrainLine:terrainDataOffset terrainY:terrainY];
        terrainLineAdded[terrainY] = YES;
        terrainDataOffset += terrainWidth;
    }
    [node addChild:terrainNode];
    

}


- (void)createTileTextures
{
    NSString *atlasName = [NSString stringWithFormat:@"elem%d", levelAtlases[levelNr-1]];
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:atlasName];
    for(int i = 0; i < numTiles; i++)
    {

        tileTextures[i] = [atlas textureNamed: [NSString stringWithFormat:@"elem%d_%d.PNG", levelAtlases[levelNr-1], i]];
    }
    
    colorCycleTexture = [SKTexture textureWithImageNamed:@"elem_transp.png"];

}

// Orientation hat geweschelt. Zur Sicherheit müssen wir alle Zeilen neu zeichnen. Sonst kann es vorkommen, dass einzelnen Zeilen verloren gehen
-(void) orientationChanged{
    NSLog(@"orientationChanged");
    
    
    int yScrollPosition = terrainNode.position.y;
    yScrollPosition = yScrollPosition * -1;     // von negativ zu positiv umwandeln
    int linePosition = yScrollPosition + game.sceneSize.height + tileHeight;   // Berechnen wo die Zeile gezeichnet werden muss (eine Zeile oberhalb des sichtbaren Bereichs)
    linePosition = linePosition / tileHeight;   // Pixelposition in Tile-Zeilenposition umwandeln
    if(linePosition < terrainHeight)
    {
        for(int i = 0; i < 30; i++)              // nur die obersten 30 Zeilen prüfen
        {
            if(!terrainLineAdded[linePosition - i])          // Wurde Zeile schon hinzugefügt?
            {
                if(linePosition -i >= 0)
                {
                    NSLog(@"add index %d", i);
                    [self addTerrainLine:(linePosition - i) * terrainWidth  terrainY:linePosition-i]; // Zeile hinzufügen
                    terrainLineAdded[(linePosition - i)] = YES;           // Zeile als hinzugefügt markieren
                }
            }
        }
    }
}

- (void)createSceneContents
{
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    //self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];

    self.name = @"self (SpaceshipScene)";

    
    // RootNode an welchem wir ALLES weitere anhängen. Dadurch müssen wir z.B. nur in einem einzigen Node die Grösse ändern wenn wir das mal tun wollen.
    
    rootNode = [[SKNode alloc] init];
    [self addChild:rootNode];
    rootNode.name = @"RootNode";

    
    // panel hinzufügen
    
    panel = [Panel new];
    [panel addPanelToNode:rootNode];

    
    // TerrainTiles aus Texture Atlas erstellen und Terrain zusammenstellen
    [self createTileTextures];
    

    
    [self prepareTerrain:rootNode];
    [self addCycleSprites:rootNode];
    

    // Fighter hinzufügen
    
    fighter = [Fighter new];
    NSLog(@"Fighter added %lx", (unsigned long)fighter);
    
    [fighter addFighterToNode:rootNode];

    fighterYPos = panel.size.height +  (fighter.size.height/2) + 5;      // 5 Pixel oberhalb des Panels

    
    fighter.position =  CGPointMake(self.size.width/2, fighterYPos);               // in der Mitte des Display und leicht oberhalb des Panels

    
    fighter.categoryBitMask = fighterCategory;
    fighter.contactTestBitMask = tileSpecialCategory | bigShipCategory |bigShipShootsCategory |enemyCategory | enemyShootsCategory | tileColidableCategory;
    
    
    
    fighter.shootContactTestBitMask = tileShootableForFighter | bigShipCategory | enemyCategory;
    fighter.shootCategoryBitMask = fighterShootsCategory;
    
    bigShip = [BigShip new];
    bigShip.contactTestBitMask = fighterShootsCategory;
    bigShip.categoryBitMask = bigShipCategory;
    bigShip.shootCategoryBitMask = bigShipShootsCategory;
    bigShip.shootContactTestBitMask = fighterCategory;
    
    // wo soll bigship kommen? linker rand, mitte oder rechter rand?
    bigShipXIndex = arc4random() % 3;
    int bigShipX;
    
    
    switch (bigShipXIndex) {
        case 0:
            // linker Rand
            bigShipX = bigShip.size.width/2 + 20;
            break;
            
        case 1:
            // Mitte
            bigShipX = self.size.width / 2;
            break;
            
        default:
            //rechter Rand
            bigShipX = self.size.width - (bigShip.size.width/2) - 20;
            break;
    }
    
    
    int bigShipY = [self getRandomNumberBetween:BIG_SHIP_INITIAL_Y_MIN to:BIG_SHIP_INITIAL_Y_MAX];
    NSLog(@"BigShipY = %d", bigShipY);
    
    //bigShipY = 1000;
    
    bigShip.position = CGPointMake(bigShipX, bigShipY);
    [bigShip addShipToNode:terrainNode];

    bigShipState = StateWeitVorne;
    
    // Enemies
    

    enemies = [Enemies new];
    enemies.shootContactTestBitMask = fighterCategory;
    enemies.shootCategoryBitMask = enemyShootsCategory;
    
    enemyTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(enemyTimerFired:) userInfo:Nil repeats:NO];
    enemyState = Initialized;
    
    
    // Sounds
    actionPlayTileHitSound = [SKAction playSoundFileNamed:@"TileHit.wav" waitForCompletion:NO];
 
    
    // Joystick
    if(game.steeringMode != SteeringMode_MFi){
        joyStick = [Joystick new];
        [joyStick addToNode:rootNode];
    }
    
}


- (void)enemyTimerFired:(NSTimer *)timer
{
    [self enemyController];
    int wait = [self getRandomNumberBetween:ENEMY_WAIT_MIN to:ENEMY_WAIT_MAX];
    enemyTimer = [NSTimer scheduledTimerWithTimeInterval:wait target:self selector:@selector(enemyTimerFired:) userInfo:Nil repeats:NO];
    NSLog(@"new enemy timer %d, state %d", wait, enemyState);
    
}


// Terrain scrollen. Wird aus "update" gerufen
-(void) scrollTerrain{


    
    // Terrain vertikal scrollen
    if(terrainNode != nil)
    {
    
        // cheat testen: gleich zu Beginn ans Ende des Levels springen
        if(game.cheatShortLevel)
        {
            if(terrainNode.position.y > -500)
            {
                terrainNode.position = CGPointMake(terrainNode.position.x, -7000);
            }
        }
        
        
        // terrain scrollen
        int  yCor = game.sceneSize.height - 60;
        if(terrainNode.position.y > ((terrainHeight*tileHeight)-yCor)*-1)            // Levelende?
        {
            
            terrainNode.position = CGPointMake(terrainNode.position.x, terrainNode.position.y - scrollSpeed);   // nein --> scrollen
             
        }
        else
        {
            // Ende des Levels erreicht
            NSLog(@"Levelende");
            
            // prüfen ob kurz vor Ende des Levels der Fighter verlorenging (explodiert)
            if(sceneState == Running)
            {
                sceneState = LevelCompleted;        // Level erfolgreich beendet!
            }
        }
    }
    
    // prüfen ob eine neue Terrain-Zeile hinzugefügt werden muss
    
    
    int yScrollPosition = terrainNode.position.y;
    
    yScrollPosition = yScrollPosition * -1;     // von negativ zu positiv umwandeln
    

    int linePosition = yScrollPosition + game.sceneSize.height + tileHeight;   // Berechnen wo die Zeile gezeichnet werden muss (eine Zeile oberhalb des sichtbaren Bereichs)
    
    linePosition = linePosition / tileHeight;   // Pixelposition in Tile-Zeilenposition umwandeln
    
    if(linePosition < terrainHeight)
    {
        if(!terrainLineAdded[linePosition])          // Wurde Zeile schon hinzugefügt?
        {
            
            [self addTerrainLine:linePosition * terrainWidth  terrainY:linePosition]; // Zeile hinzufügen
            terrainLineAdded[linePosition] = YES;           // Zeile als hinzugefügt markieren
        }
        
        // prüfen Terrain-Zeilen unten raus gescrollt sind. Wenn ja, removen
        yScrollPosition = terrainNode.position.y;
        yScrollPosition = yScrollPosition * -1;     // von negativ zu positiv umwandeln
        linePosition = yScrollPosition - tileHeight;
        linePosition = linePosition / tileHeight;   // Pixelposition in Tile-Zeilenposition umwandeln
        
        linePosition--;     // eine Zeile unterhalb der sichtbaren Scene
        
        if(linePosition >= 0)
        {
            int lineOffset = linePosition * terrainWidth;
            if(terrainTileNodes[lineOffset] != Nil)
            {
               // NSLog(@"removeTerrainLine y: %d", linePosition);
                for (int i = 0; i < terrainWidth; i++) {
                    [terrainTileNodes[lineOffset + i] removeFromParent];
                    terrainTileNodes[lineOffset + i] = nil;
                }
            }
        }
    }
}

-(void)enemyController{
  

    switch(enemyState){
        case Initialized:
              enemyState = Waiting;
            break;
            
        case Flying:
            if(enemies.numEnemiesFlying == 0)
            {
                enemyState = Waiting;
            }
            break;
            
        case Waiting:
            enemyState = Flying;
            if(sceneState == Running)
            {
                [enemies addEnemiesToNode:rootNode];
            }
            enemies.contactTestBitMask = fighterCategory | fighterShootsCategory;
            enemies.categoryBitMask = enemyCategory;
            NSLog(@"new enemies added");
            break;
            
    }
    
    NSLog(@"numEnemiesFlying %d", enemies.numEnemiesFlying);
    
}

-(void)update:(NSTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    switch (sceneState) {

        case Paused:
            // prüfen ob Pausen-Mopdus deaktiviert wurde (MFi)
            if(game.mFi.rightShoulder)
            {
                game.mFi.rightShoulder = NO;
                game.gamePaused = NO;
            }
            
            
            if(!game.gamePaused)    // Achtung: gamePaused wird an verschiedenen Stellen verändert. Nicht nur in den oberen Zeilen
            {
                [self removePauseSymbol];
                sceneState = Running;
                [enemies resume];
            }
            break;
            
        
        
        case Running:
          // prüfen ob Pausen-Mopdus aktiviert wurde (MFi)
            if(game.gamePaused)
            {
                sceneState = Paused;
                [enemies pause];
                [self addPauseSymbol];
            }
            
            // Im Turbomodus (SpecialTile) bekommen wir pro Update 10 Zusatzpunkte
            if(turboFighter) {
                game.score += SPECIAL_TILE_TURBO_FIGHTER_EXTRA_SCORE;
            }
            
            
            [self updateShipAndScrollSpeedFromMotionManager];
            [self scrollTerrain];
            [self moveBigShip];
            [enemies updateShoots];
            
            if(game.energyLevel == 0)
            {
                sceneState = FighterExploding;
                [fighter explode];
                NSLog(@"out of energy!");
            }
            
            // prüfen ob es aus dem collisionhandler eine neue fighter-poistion gibt. Wenn die Position direkt im Collisionhandler gesetzt wird, wird sie ignoriert. Bug?
            
            if(newFighterPosition.y != -1 | newFighterPosition.x != -1){
                fighter.position = newFighterPosition;
                newFighterPosition = CGPointMake(-1, -1);
            }
        
            // prüfen ob wir einen BonusFighter erhalten
            if(game.score >= game.nextBonusFighterAtScore)
            {
                // yep!
                game.numFighters++;
                game.nextBonusFighterAtScore += SCORE_FOR_BONUS_FIGHTER;
                NSLog(@"Bonus Fighter. %d / Next Bonusfighter at %d", game.numFighters, game.nextBonusFighterAtScore);
            }
        
            break;
     
        case BonusCounting:
            {
                // Levelenede wurde erreicht und BonusFlag ist gesetzt
                if(game.score >= scoreWithBonus)
                {
                    game.score = scoreWithBonus;        // falls mit ungeraden Werten nach oben gezählt wurde, setzen wir den Score wieder auf den richtigen Wert;
                    sceneState = LevelCompleted;
                    bonusFlag = NO;
                }
                else
                {
                    game.score += 2;    // score raufzählen
                }
            }
            break;
        
        case LevelCompleted:
            {
                if(bonusFlag)
                {
                    scoreWithBonus = game.score +  game.enemiesDestroyed * SCORE_EXPLODED_ENEMY_WITH_BONUS_FLAG;
                    sceneState = BonusCounting;
                }
                else
                {
                    SKAction *actionTerrainMoveOutLevelCompleted = [SKAction sequence:@[
                                                                                        [SKAction moveByX:320 y:0 duration:0.8],
                                                                                        [SKAction runBlock:^{sceneState = TerrainMovedOutForNextLevel;}]
                                                                                        ]
                                                                    ] ;;
                    
                    [terrainNode runAction:actionTerrainMoveOutLevelCompleted];
                    [colorCycleNode removeFromParent];
                    sceneState = TerrainMovingOut;
                }
            }
            break;
    
        case FighterExploding:
            // Fighter ist am explodieren. Warten bis Explosion abgeschlossen ist
            if(!fighter.isExploding)
            {
                // Explosion abgeschlossen
                sceneState = FighterExploded;
            }
            break;

        case FighterExploded:
            {
                SKAction *actionTerrainMoveOutShipExlodeds = [SKAction sequence:@[
                                                                                  [SKAction moveByX:320 y:0 duration:0.8],
                                                                                  [SKAction runBlock:^{sceneState = TerrainMovedOutForNextFighter;}]
                                                                                  ]
                                                              ] ;;
            
                [colorCycleNode removeFromParent];
                [terrainNode runAction:actionTerrainMoveOutShipExlodeds];
                sceneState = TerrainMovingOut;
            }
            break;
            
        case TerrainMovedOutForNextFighter:
            // war es der letzte fighter?
            if([game newFighterAvailable])
            {
                // nein es gibt noch einen weiteren fighter
                [self prepareSceneRemove];
                [game fighterLost];         // der Gamelogik mitteilen, dass ein Fighter explodiert ist
                sceneState = DoNothing;
            }
            else
            {
                // Game Over!
                [self showGameOver];
                sceneState = GameOverShowing;
            }
            break;
            
        case GameOverFinished:
            [self prepareSceneRemove];
            [game fighterLost];         // der Gamelogik mitteilen, dass ein Fighter explodiert ist
            break;

            
        case TerrainMovedOutForNextLevel:
            [self prepareSceneRemove];
            [game levelCompleted];      // der Gamelogik mitteilen, dass Level beendet wurde
            sceneState = DoNothing;
            break;
        
        default:
            break;
    }
    

    
    panel.score = game.score;
    panel.energy = game.energyLevel;
    panel.highScore = game.highScore;
    panel.numEnemiesDestroyed = game.enemiesDestroyed;
    panel.numFighters = game.numFighters - game.currentFighter + 1;
    panel.positionInHighScore = game.positionInHighScore;
    
    //NSLog(@"update end");
}

-(void) moveBigShip{
    
    if(![bigShip isExploding])
    {
        // BigShip bewegen (falls es nicht am explodieren ist)
        [bigShip moveX:0 andY:-0.8];
    }
    
    
    int bigShipBottomPosition = bigShip.position.y - bigShip.size.height / 2;   // y-position des big-ships ganz unten
    
    
    switch (bigShipState) {
        case StateWeitVorne:
            if(bigShipBottomPosition - (terrainNode.position.y * -1) < (self.size.height + BIG_SHIP_RADAR_DISTANCE))
            {
                // BigShip wird bald auf Display erscheinen
                NSLog(@"BigShip Alarm!");
                bigShipState = StateKommtBald;
                panel.bigShipAlarm = bigShipXIndex + 1; // 1 = links, 2 = mitte, 3 = rechts
                panel.alarmLevel = 7;
            }
            break;

        case StateKommtBald:
            if(bigShipBottomPosition - (terrainNode.position.y * -1) < self.size.height)
            {
                // BigShip ist auf Display und schiesst nun
                NSLog(@"BigShip on screen!");
                bigShipState = StateShooting;
                [bigShip shoot];
            }
            break;
            
            
        case StateShooting:
            if(bigShipBottomPosition - (terrainNode.position.y * -1) < panel.size.height)
            {
                // BigShip ist am unteren Displayrand angekommen
                NSLog(@"BigShip missed");
                bigShipState = StateVorbeiGeflogen;
                game.energyLevel = game.energyLevel / ENERGY_LOSS_AT_BIGSHIP_MISSED;
                panel.bigShipAlarm = NO;
                panel.alarmLevel = 3;
            }
            
            break;
            
        default:
            break;
    }
    
}

-(void) showGameOver{
    SKSpriteNode *gameOverNode = [SKSpriteNode spriteNodeWithImageNamed:@"GameOver1.png"];
    SKTexture *gameOverExploded = [SKTexture textureWithImageNamed:@"GameOver2.png"];
    
    SKAction *actionGameOver = [SKAction sequence:@[
                                                    
                                                          [SKAction waitForDuration: 1.5],
                                                          [SKAction playSoundFileNamed:@"GameOverBang.wav" waitForCompletion:NO],
                                                          [SKAction setTexture:gameOverExploded],
                                                          [SKAction waitForDuration: 3.0],
                                                          [SKAction runBlock:^{sceneState = GameOverFinished;}]
                                                          ]
                                      ] ;;
    
    gameOverNode.zPosition = Z_POSITION_GAME_OVER;      // immer zu vorderst
    //gameOverNode.anchorPoint = CGPointMake(0,0);
    
    gameOverNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame) + 30);
    [gameOverNode runAction:actionGameOver];
    [rootNode addChild:gameOverNode];
}


- (void)updateShipAndScrollSpeedFromMotionManager
{
    
    float x;
    
    // MFi Controller Steuerung (ohne Shoot)
    if(game.steeringMode == SteeringMode_MFi)
    {
        fighterMove = NoMove;
        if(game.mFi.leftDpad) {fighterMove = LeftMove; }
        if(game.mFi.rightDpad)  { fighterMove = RightMove; }
        
        if(game.mFi.leftThumbstickLeft)  { fighterMove = LeftMove; }
        if(game.mFi.leftThumbstickRight)  { fighterMove = RightMove; }
  
        
        speedChange = NoChange;
        if(game.mFi.rightThumbstickUp)  { speedChange = Faster; }
        if(game.mFi.rightThumbstickDown)  { speedChange = Slower; }

        if(game.mFi.upDpad)  { speedChange = Faster; }
        if(game.mFi.downDpad)  { speedChange = Slower; }

        

        
        // SpecialTile vertauschte Steuerung?
        if(leftRightSwapped){
            if(fighterMove == LeftMove)
            {
                fighterMove = RightMove;
            }
            else if (fighterMove == RightMove)
            {
                fighterMove = LeftMove;
            }
        }
        _fighterMoveSpeed = 5;
    }
    
    
    if(game.steeringMode == SteeringMode_Accelerometer)
    {
        [self updateShipPositionFromMotionManager];
    }
    
    switch (fighterMove) {
        case LeftMove:
            x = 20;
            [fighter moveX: (_fighterMoveSpeed * -1) andY: 0.0];
            
            // nur bis zum gedrückten Finger fahren
            if (fighter.position.x < x) {
                fighterMove = NoMove;
            }
            
            break;
            
        case RightMove:
            x = 320;
            [fighter moveX: _fighterMoveSpeed andY: 0.0];
            
            // nur bis zum gedrückten Finger fahren
            if (fighter.position.x >= x) {
                fighterMove = NoMove;
            }
            
            break;
            
        default:
            break;
    }
    
    // kontrollieren ob fighter an der richtigen y-position ist (manchmal wird er weggeschoben)
    if(fighter.position.y != fighterYPos){
        fighter.position = CGPointMake(fighter.position.x, fighterYPos);
        NSLog(@"Fighter Y-Pos resetted!");
    }
    
    
    
    // ScroolSpeed festlegen
    
    if(!turboFighter)
    {
        switch(speedChange)
        {
            case Faster:
                if(scrollSpeedDetectCounter == 0)
                {
                    scrollSpeed += 0.2;
                    if(scrollSpeed > SPEED_MAX)
                    {
                        scrollSpeed = SPEED_MAX;
                    }
                    [self setNoiseSpeed];
                    panel.speed = scrollSpeed;
                }
                scrollSpeedDetectCounter++;
                if(scrollSpeedDetectCounter > SPEED_DELAY)
                    scrollSpeedDetectCounter = 0;
                
                break;
                
            case Slower:
                if(scrollSpeedDetectCounter == 0)
                {
                    scrollSpeed -= 0.2;
                    if(scrollSpeed < 0)
                    {
                        scrollSpeed = 0;
                    }
                    [self setNoiseSpeed];
                    panel.speed = scrollSpeed;
                }
                scrollSpeedDetectCounter++;
                if(scrollSpeedDetectCounter > SPEED_DELAY)
                    scrollSpeedDetectCounter = 0;
                
                break;
                
            case NoChange:
                scrollSpeedDetectCounter = 0;
                break;
        }
    }
 }


-(int)getRandomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}

// wird z.B. gerufen wenn incoming call oder homebutton event kommt. (nicht mit MFi PauseButton verwechseln!)
-(void) pause{
    [_backgroundAudioPlayer stop];      // Wenn wir diesen nicht anhalten, gibt's eine Exception :-(
    NSLog(@"GameScene: pause");
}

// wird z.B. gerufen wenn wir aus dem Background geholt werden
-(void) resume{
    [_backgroundAudioPlayer play];
    NSLog(@"GameScene: resume");
}

-(void) gameControllerButtonPressed{
    NSLog(@"GameScene: gameControllerButtonPressed");
    if(sceneState == Running){
        
        if(game.mFi.rightShoulder)
        {
            game.mFi.rightShoulder = NO;
            [self fighterShoot];
        }

        if(game.mFi.buttonA)
        {
            game.mFi.buttonA = NO;
            [self fighterShoot];
        }
    }
}

-(void)addPauseSymbol{
    if(_pauseModeSprite == nil)
    {
        _pauseModeSprite = [SKSpriteNode spriteNodeWithImageNamed:@"pause.png"];
        _pauseModeSprite.anchorPoint = CGPointMake(0.5,0.5);
        _pauseModeSprite.position = CGPointMake(game.sceneSize.width/2, game.sceneSize.height/2);
        _pauseModeSprite.alpha = 0.3;
        [rootNode addChild:_pauseModeSprite];
        
        // Pausensymbol hovern lassen
        SKAction* actionHover = [SKAction sequence:@[
                                                     [SKAction fadeAlphaTo:0.8 duration:0.7],
                                                    [SKAction waitForDuration:0.5],
                                                     [SKAction fadeAlphaTo:0.3 duration:0.7]
                                                     
                                                     ]];
        
        [_pauseModeSprite runAction:[SKAction repeatActionForever:actionHover]];
        _pauseModeSprite.xScale = 0.5;
        _pauseModeSprite.yScale = 0.5;

    }
}

-(void)removePauseSymbol{
    [_pauseModeSprite removeFromParent];
    _pauseModeSprite = nil;
}

-(void)gameControllerChanged{
    if(game.mFi.controllerConnected)
    {
        // ein Gamecontroller ist verbunden -> Steuerungssymbole entfernen
        [joyStick removeAll];
        joyStick = nil;
    }
    else
    {
        // kein GameController ist verbunden -> Steuerungssymbole hinzufügen
        if(joyStick == nil){
            joyStick = [Joystick new];
            [joyStick addToNode:self];
        }
    }
}

@end


