//
//  Game.m
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import "Game.h"
#import "SpaceshipScene.h"
#import "TitleScene.h"
#import "HelmScene.h"
#import "HighScoreScene.h"
#import "SettingsScene.h"
#import "constants.h"
@import CoreMotion;

@import AVFoundation;

enum state
{
    TitleScreenState,
    HelmSceneState,
    GameSceneState,
    HighScoreSceneState,
    SettingsSceneState
};


@implementation Game{
    int _score;
    uint _enemiesDestroyed;
    int _energyLevel;
    HighScoreManager* _highScoreManager;
    TitleScene* titleScene;
    IFScene* currentScene;
    HelmScene* helmScene;
    SpaceshipScene* gameScene;
    HighScoreScene* highScoreScene;
    SettingsScene* settingsScene;
    enum state _state;
    bool _paused;
    AVAudioPlayer *_backgroundAudioPlayer;
    uint _positionInHighScore;
    enum SteeringMode _steeringMode;
    BOOL _shootLock;
    BOOL _buttonShoot;
    BOOL _leftShoulderLastValue;
    BOOL _rightShoulderLastValue;
    BOOL _upDpadLastValue;
    BOOL _downDpadLastValue;
    BOOL _leftDpadLastValue;
    BOOL _rightDpadLastValue;
    BOOL _buttonALastValue;
    BOOL _buttonBLastValue;
    BOOL _buttonXLastValue;
    BOOL _buttonYLastValue;
    BOOL _leftThumbstickUpLastValue;
    BOOL _leftThumbstickDownLastValue;
    BOOL _leftThumbstickLeftLastValue;
    BOOL _leftThumbstickRightLastValue;
    BOOL _rightThumbstickUpLastValue;
    BOOL _rightThumbstickDownLastValue;
    BOOL _rightThumbstickLeftLastValue;
    BOOL _rightThumbstickRightLastValue;
    BOOL _leftTriggerLastValue;
    BOOL _rightTriggerLastValue;
    iCadeReaderView* _iCadeReaderView;

}

@synthesize currentLevel;
@synthesize currentFighter;
@synthesize numFighters;
    
@synthesize sceneSize;
    
@synthesize cheatShortLevel;
@synthesize cheatFirstLevel;
@synthesize cheatNoDangerousTileCollision;
@synthesize cheatUnlimitedLives;
@synthesize cheatNoEnemyCollision;
@synthesize newHighScore;
@synthesize accelerometerAvailable;





-(void) setNewHeightFactor: (float) heightFactor
{
   sceneSize = CGSizeMake(320, 320 * heightFactor - 0);
    
    switch (_state) {
        case TitleScreenState:
            [titleScene setSize:CGSizeMake(sceneSize.width, sceneSize.height)];
            break;
            
        case HelmSceneState:
            [helmScene setSize:CGSizeMake(sceneSize.width, sceneSize.height)];
            break;
            
        case GameSceneState:
            [gameScene setSize:CGSizeMake(sceneSize.width, sceneSize.height)];
            [gameScene orientationChanged];
            break;
            
        case HighScoreSceneState:
            [highScoreScene setSize:CGSizeMake(sceneSize.width, sceneSize.height)];
            break;

        case SettingsSceneState:
            [settingsScene setSize:CGSizeMake(sceneSize.width, sceneSize.height)];
            break;
            
            
        default:
            break;
    }
    
}

-(void) startGame: (ViewController*) pviewController heightFactor:(float) heightFactor
{
    cheatShortLevel = INITIAL_CHEAT_SHORT_LEVEL;
    cheatNoDangerousTileCollision  = INITIAL_CHEAT_NO_DANGEROUS_TILE_COLLISION;
    cheatUnlimitedLives = INITIAL_CHEAT_UNLIMITED_LIVES;
    cheatNoEnemyCollision = INITIAL_CHEAT_NO_ENEMY_COLLISION;
    
    
    sceneSize = CGSizeMake(320, 320 * heightFactor - 0);
    
    viewController = pviewController;
    
    SKView *spriteView = (SKView *) viewController.view;
    
    CMMotionManager* mm = [CMMotionManager new];
    self.accelerometerAvailable = mm.accelerometerAvailable;
    //self.accelerometerAvailable = YES;

    _mFi = [MFi new];

    [self setDefaultSteeringMode];
    
    //
    
    if(SK_DEBUG)
    {
        spriteView.showsDrawCount = YES;
        spriteView.showsNodeCount = YES;
        spriteView.showsFPS = YES;
    }

    
    _highScoreManager = [HighScoreManager new];
    
    
    int numEntries = [_highScoreManager loadHighScore];
   
    
    if(numEntries != HIGHSCORE_MAX_ENTRIES)
    {
        NSLog(@"No hiscores found. Generating defaults");

        [_highScoreManager clearHighScores];
        [_highScoreManager addPlayer:@"AMIGA" withScore:19000];
        [_highScoreManager addPlayer:@"FOR " withScore:18500];
        [_highScoreManager addPlayer:@"EVER!" withScore:18000];
        [_highScoreManager addPlayer:@"Chris" withScore:17000];
        [_highScoreManager addPlayer:@"Rene" withScore:16000];
        [_highScoreManager addPlayer:@"Roman" withScore:15000];
        [_highScoreManager addPlayer:@"Marc" withScore:14000];
        [_highScoreManager addPlayer:@"Phil" withScore:13000];
        [_highScoreManager addPlayer:@"Eric" withScore:12000];
        [_highScoreManager addPlayer:@"Chris" withScore:11000];
        [_highScoreManager saveHighScore];
    }
    
    [self initGameValues];
    
    // iCade
    _iCadeReaderView = [iCadeReaderView new];
    _iCadeReaderView.delegate = self;
    _iCadeReaderView.active = YES;
    [pviewController.view addSubview:_iCadeReaderView];
    //
    
    
    if(/* DISABLES CODE */ (0))
    {
        [self showSettingsScene];
    }
    
     if(/* DISABLES CODE */ (0))
     {
         self.score = _highScoreManager.highScore + 1;
         self.newHighScore = YES;
         [self showHighScoreScene];
         
    }
    
    if(1)
    {
        // im Normalfall wird zuerst der TitleScreen angezeigt
        if(DIRECT_GAME_START)
        {
            [self playFirstLevel];
        }
        else
        {
            [self startBackgroundMusic];
            [self showTitleScene:NO];
        }
    }
    
}

-(void)buttonDown:(iCadeState)button{
    [_mFi iCadeButtonDown:button];
}

-(void)buttonUp:(iCadeState)button{
    [_mFi iCadeButtonUp:button];

}

-(void)stateChanged:(iCadeState)state{
    NSLog(@"iCade stateChanged");
}




// Setzt den initialen SteeringMode
-(void)setDefaultSteeringMode{
    if(_mFi.controllerConnected)
    {
        _steeringMode = SteeringMode_MFi;
    }
    else
    {
        
        // Default Steuerung  setzen
        if(self.accelerometerAvailable)
        {
            _steeringMode = SteeringMode_Accelerometer;
        }
        else
        {
            _steeringMode = SteeringMode_TwoFingers;
        }
        
        // eventuell gespeicherte Steuerungsart laden
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults ];
        NSMutableDictionary* settingsDictionary = [defaults objectForKey:@"Settings"];
        if(settingsDictionary != nil)
        {
            NSString* value = [settingsDictionary objectForKey:@"steeringMode"];
            if(value != nil)
            {
                _steeringMode = (int)[value integerValue];
                NSLog(@"steeringmode %d loaded from userdefaults", _steeringMode);
            }
        }
    }
}

- (void)startBackgroundMusic
{
    NSError *err;
    NSURL *file = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"TitleSound.wav" ofType:nil]];
    _backgroundAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:&err];
    if (err) {
        NSLog(@"error in audio play %@",[err userInfo]);
        return;
    }
    [_backgroundAudioPlayer prepareToPlay];
    
    // this will play the music infinitely
    _backgroundAudioPlayer.numberOfLoops = -1;
    
    _backgroundAudioPlayer.enableRate = YES;
    _backgroundAudioPlayer.rate = 1.0;
    
    [_backgroundAudioPlayer setVolume:1.0];
    [_backgroundAudioPlayer play];
}


-(void) initGameValues{
    numFighters = INITIAL_NUM_FIGHTERS;
    currentFighter = 1;
    
    if(cheatFirstLevel > 0) {
        currentLevel = cheatFirstLevel;
    }
    else
    {
        currentLevel = START_LEVEL;
    }
    
    self.score = 0;
    self.enemiesDestroyed = 0;
    self.newHighScore = NO;
    self.gamePaused = NO;
    self.nextBonusFighterAtScore = SCORE_FOR_BONUS_FIGHTER;
}

// wird von LevelCompleted gerufen wenn ein fighter zerstört wurde. Hier wird geprüft ob es der letzte fighter war oder ob es noch einen gibt.
-(BOOL) newFighterAvailable{
    NSLog(@"newFighterAvailable?");
    bool result = false;
    if(currentFighter < numFighters)
        result = YES;
    return result;
}

-(void) playFirstLevel{
    [self initGameValues];
    [self playLevel:currentLevel];
}



-(void) playLevel: (int) level{
    _state = GameSceneState;
    gameScene = [[SpaceshipScene alloc]
                             initWithSize:CGSizeMake(sceneSize.width, sceneSize.height)];
    SKView *spriteView = (SKView *) viewController.view;
    currentScene = gameScene;
    [gameScene startGame:self withView:spriteView atLevel:level];
    [spriteView presentScene: gameScene];
    
}

// wird von LevelCompleted wenn ein Level abgeschlossen wurde. Wenn es der letzte Level war, wird Spiel abgeschlossen. Sonst wird der nächste Level gestartet.
-(void) levelCompleted{
    if(currentLevel < NUM_LEVELS)
    {
        currentLevel++;
        [self playLevel: currentLevel];
    }
    else
    {
        [self gameOver];
    }
}

// Alle Fighters zerstört oder alle Levels durchgespielt
-(void) gameOver{
    [self startBackgroundMusic];        // "Insanity Fight düdüdüdü...."
    if(self.positionInHighScore != 0)   // neuer Eintrag in der Highscore-Liste?
    {
        self.newHighScore = YES;
        [self showHighScoreScene];      // ja -> HighScores anzeigen
    }
    else
    {
        [self showTitleScene:NO];          // nein -> Titelbild anzeigen
    }
    
}

// wird von LevelCompleted wenn ein Fighter zuerstört wurde.

-(void) fighterLost{
    // Fighter ist explodiert
    
    if(cheatUnlimitedLives)
    {
        // im CheatMode den selben Level nochmals spielen
        [self playLevel:currentLevel];
    }
    else
    {
        
        // letzter Fighter?
        if(currentFighter == numFighters)
        {
            // ja -> entweder HighScore oder Titel anzeigen
            [self gameOver];
        }
        else
        {
            // level nochmal von vorne beginnen
            currentFighter++;
            [self playLevel:currentLevel];
        }
    }
}


-(void) showTitleScene: (BOOL) transition{
    _state = TitleScreenState;
    titleScene = [[TitleScene alloc]
                             initWithSize:CGSizeMake(sceneSize.width, sceneSize.height)];
    titleScene.game = self;
    SKView *spriteView = (SKView *) viewController.view;
    currentScene = titleScene;
    if(transition)
    {
        [spriteView presentScene: titleScene transition:[SKTransition doorwayWithDuration:1.0]  ];
    }
    else
    {
        [spriteView presentScene: titleScene ];
    }

}

-(void) showHelmScene{
    _state = HelmSceneState;
    helmScene = [[HelmScene alloc]
                         initWithSize:CGSizeMake(sceneSize.width, sceneSize.height)];
    helmScene.game = self;
    SKView *spriteView = (SKView *) viewController.view;
    currentScene = helmScene;
    [spriteView presentScene: helmScene];
}

-(void) showHighScoreScene{
    _state = HighScoreSceneState;
    highScoreScene = [[HighScoreScene alloc]
                 initWithSize:CGSizeMake(sceneSize.width, sceneSize.height)];
    highScoreScene.game = self;
    SKView *spriteView = (SKView *) viewController.view;
    currentScene = highScoreScene;
    
    // neuer Highscore?
    if(newHighScore)
    {
        // wenn ja, nach Name fragen
        highScoreScene.newHighScore = _score;
    }
    [spriteView presentScene: highScoreScene];
}

-(void) showSettingsScene{
    _state = SettingsSceneState;
    settingsScene = [[SettingsScene alloc]
                 initWithSize:CGSizeMake(sceneSize.width, sceneSize.height)];
    settingsScene.game = self;
    SKView *spriteView = (SKView *) viewController.view;
    currentScene = settingsScene;
    
  //  [spriteView presentScene: settingsScene];
    [spriteView presentScene: settingsScene transition:[SKTransition doorwayWithDuration:1.0]];
     
}


-(void) endTitleScene:(enum TitleExitMode) titleExitMode
{
    switch (titleExitMode) {
        case Mode_ShowHighScore:
            [self showHighScoreScene];
            break;
            
        case Mode_ShowSettings:
            [self showSettingsScene];
            break;
            
        case Mode_StartGame:
            [_backgroundAudioPlayer stop];
            [self showHelmScene];
            break;
            
        default:
            break;
    }

}

-(void) endHelmScene
{
    [self playFirstLevel];
}

-(void) endHighScoreScene
{
    [self showTitleScene:NO];
}


-(void) endSettingsScene{
    [self endTitleScene:Mode_StartGame];    // Umweg über endTitleScene damit TitleSound stoppt
}


-(int)score{
    return _score;
}

-(void)setScore:(int) score{
    if(score < 0)
        score = 0;
    
    if(_score != score)
    {
        _score = score;
        _positionInHighScore = [_highScoreManager positionInHighScore:_score];
        NSLog(@"New score = %d / positionInHighScore = %d", _score, _positionInHighScore);
    }
}

// liefert die Position in der HighScoreListe oder 0 wenn der Score nicht für den Platz unter den ersten 100 reicht.
-(uint)positionInHighScore{
    return _positionInHighScore;
}

// bester Score
-(uint)highScore{
    return _highScoreManager.highScore;
}


-(int)energyLevel{
    return _energyLevel;
}

-(void)setEnergyLevel:(int) energyLevel{
    if(energyLevel < 0)
        energyLevel = 0;
    
    if(energyLevel > INITIAL_ENERGY_LEVEL)
        energyLevel = INITIAL_ENERGY_LEVEL;
    
    _energyLevel = energyLevel;
    if(_energyLevel < 0)
        _energyLevel = 0;
    NSLog(@"New energyLevel = %d", _energyLevel);
}

// Anzahl zuerstörte Enemies
-(uint)enemiesDestroyed{
    return _enemiesDestroyed;
}

-(void)setEnemiesDestroyed:(uint) enemiesDestroyed{
    _enemiesDestroyed = enemiesDestroyed;
    NSLog(@"New enemiesDestroyed = %d", _enemiesDestroyed);
}


// Game wurde unterbrochen (z.B. HomeButtton oder incoming call). --> pausieren
// wichtig ist, dass hier der loopende Backgroundsound abgestellt wird. Sonst crasht das Game.
-(void) applicationWillResignActive{
    NSLog(@"Game: applicationWillResignActive");
    _paused = true;
    switch (_state) {
        case TitleScreenState:
            [_backgroundAudioPlayer stop];
            [titleScene pause];
            break;
            
        case HelmSceneState:
            [helmScene pause];
            break;
            
        case GameSceneState:
            [gameScene pause];
            break;

        case HighScoreSceneState:
            [_backgroundAudioPlayer stop];
            [highScoreScene pause];
            break;
            
        default:
            break;
    }

    
}

// Game wird aus dem Hintergrund wieder nach vorne geholt -> Sound wieder starten
-(void) applicationDidBecomeActive{
    NSLog(@"Game: applicationDidBecomeActive");
    
    if(_paused)
    {
        // Event bearbeiten falls wir aus dem Hintergrund geholt wurden
        NSLog(@"Game: resume");
        _paused = false;
        
        
        switch (_state) {
            case TitleScreenState:
                [_backgroundAudioPlayer play];
                [titleScene resume];
                break;
                
            case HelmSceneState:
                [helmScene resume];
                break;
                
            case GameSceneState:
                [gameScene resume];
                break;
                
            case HighScoreSceneState:
                [_backgroundAudioPlayer play];
                [highScoreScene resume];
                break;
            
            default:
                break;
        }
        
    }
    
}

// Farbe von HTML nach SKColor vonvertieren
// Assumes input like "#00FF00" (#RRGGBB).
+(SKColor*)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [SKColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

// liefert POinter zu HighScoreverwaltung
-(HighScoreManager*) highScoreManager{
    return _highScoreManager;
}

-(void) setSteeringMode:(enum SteeringMode)steeringMode{
    _steeringMode = steeringMode;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults ];
    NSMutableDictionary *settingsDictionary = [NSMutableDictionary new];
    NSNumber* value = [NSNumber numberWithInt:_steeringMode];
    [settingsDictionary setObject:value forKey:@"steeringMode"];
    [defaults setObject:settingsDictionary forKey:@"Settings"];
    [defaults synchronize];
    NSLog(@"steeringmode %d stored in userdefaults", _steeringMode);
}

-(enum SteeringMode) steeringMode{
    return _steeringMode;
}

-(IFScene*) currentScene{
    return currentScene;
}

-(iCadeReaderView*) iCadeReaderView{
    return _iCadeReaderView;
}
@end
