//
//  Panel.h
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Panel : NSObject

@property (readonly) CGSize size;
@property int bigShipAlarm;
@property uint speed;
@property uint alarmLevel;
@property bool bonusFlag;
@property uint level;
@property uint positionInHighScore;
@property uint numFighters;
@property uint numEnemiesDestroyed;
@property uint energy;
@property uint highScore;
@property uint score;

    
-(void) addPanelToNode:(SKNode*) sceneNode;


-(void) startTimer;
@end
