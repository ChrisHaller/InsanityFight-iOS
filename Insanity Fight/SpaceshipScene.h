//
//  SpaceshipScene.h
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import <SpriteKit/SpriteKit.h>
#import "Game.h"
#import "IFScene.h"


// Special Tiles

#define SPECIAL_TILE_SUPER_SHOOT 100
#define SPECIAL_TILE_SUPER_SHOOT_DURATION 8

#define SPECIAL_TILE_INVISIBLE_FIGHTER 101
#define SPECIAL_TILE_INVISIBLE_FIGHTER_DURATION 3

#define SPECIAL_TILE_MIRROR_FIGHTER 102


#define SPECIAL_TILE_TURBO_FIGHTER 103
#define SPECIAL_TILE_TURBO_FIGHTER_FULL_SPEED 10
#define SPECIAL_TILE_TURBO_FIGHTER_NORMAL_SPEED 2       // Speed nach Ablauf des Turbo Timers
#define SPECIAL_TILE_TURBO_FIGHTER_DURATION 5
#define SPECIAL_TILE_TURBO_FIGHTER_EXTRA_SCORE 10

#define SPECIAL_TILE_LEFT_RIGHT_SWAPPED 104
#define SPECIAL_TILE_LEFT_RIGHT_SWAPPED_DURATION 8

#define SPECIAL_TILE_ADD_SCORE_SUB_ENERGY 105
#define SPECIAL_TILE_ADD_SCORE_SUB_ENERGY_SUB_ENERGY 100
#define SPECIAL_TILE_ADD_SCORE_SUB_ENERGY_ADD_SCORE 100


#define SPECIAL_TILE_ADD_ENERGY_SUB_SCORE 106
#define SPECIAL_TILE_ADD_ENERGY_SUB_SCORE_ADD_ENERGY 100
#define SPECIAL_TILE_ADD_ENERGY_SUB_SCORE_SUB_SCORE 100


@interface SpaceshipScene : IFScene <SKPhysicsContactDelegate> {
}

- (void)startGame:(Game*) game withView:(SKView *)view atLevel:(int) level;

@end
