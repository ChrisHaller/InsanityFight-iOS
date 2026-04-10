//
//  Game.h
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "HighScoreManager.h"
#import <GameController/GameController.h>
#import "MFi.h"
#import "iCadeReaderView.h"
#import "IFScene.h"



#ifndef DEBUG
#define NSLog(...) /* suppress NSLog when in release mode */
#endif

enum SteeringMode{
    SteeringMode_Classic,
    SteeringMode_Accelerometer,
    SteeringMode_TwoFingers,
    SteeringMode_MFi
};

enum TitleExitMode
{
    Mode_ShowHighScore,
    Mode_StartGame,
    Mode_ShowSettings
};

@interface Game : NSObject<iCadeEventDelegate>{
    ViewController* viewController;
}

-(void) startGame: (ViewController*) viewController heightFactor:(float) heightFactor;
-(void) setNewHeightFactor: (float) heightFactor;
-(void) playLevel: (int) level;
-(void) levelCompleted;
-(void) endTitleScene:(enum TitleExitMode) titleExitMode;
-(void) endHelmScene;
-(void) endHighScoreScene;
-(void) endSettingsScene;
-(void) fighterLost;
-(void) applicationWillResignActive;
-(void) applicationDidBecomeActive;
-(void)setDefaultSteeringMode;
+(SKColor*)colorFromHexString:(NSString *)hexString;


@property int currentLevel;
@property int currentFighter;
@property int numFighters;
@property(readonly) BOOL newFighterAvailable;
@property int score;
@property (readonly) uint highScore;
@property uint enemiesDestroyed;
@property CGSize sceneSize;
@property(readonly) HighScoreManager* highScoreManager;
@property(readonly) uint positionInHighScore;
@property bool newHighScore;
@property int energyLevel;
@property BOOL accelerometerAvailable;
@property enum SteeringMode steeringMode;
@property (nonatomic, assign) BOOL gamePaused;


//cheatFlags
@property BOOL cheatShortLevel;
@property int cheatFirstLevel;
@property BOOL cheatNoDangerousTileCollision;
@property BOOL cheatUnlimitedLives;
@property BOOL cheatNoEnemyCollision;


@property (readonly)MFi* mFi;
@property (readonly)iCadeReaderView* iCadeReaderView;
@property uint nextBonusFighterAtScore;
@property (readonly) IFScene* currentScene;

@end
