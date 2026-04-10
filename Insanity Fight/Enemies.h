//
//  Enemies.h
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Enemies : NSObject

@property uint32_t shootCategoryBitMask;
@property uint32_t shootContactTestBitMask;
@property uint32_t categoryBitMask;
@property uint32_t contactTestBitMask;

-(void) addEnemiesToNode:(SKNode*) node;
-(void) explodeEnemy:(SKSpriteNode*) enemySprite;
-(void) updateShoots;
-(void) pause;
-(void) resume;


@property (readonly) uint numEnemiesFlying;


@end
