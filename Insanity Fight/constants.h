//
//  constants.h
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#ifndef SpriteWalkthrough_constants_h
#define SpriteWalkthrough_constants_h

#define DIRECT_GAME_START 0
#define START_LEVEL 1
#define SK_DEBUG 1                  // SpriteKit Debug-Mode


#define CHEAT_TEXT_PREFIX @"Lol"
#define CHEAT_TEXT_NO_TILE_COLLISION @"ntc"
#define CHEAT_TEXT_NO_ENEMY_COLLISION @"nec"
#define CHEAT_TEXT_START_LEVEL @"sl"

#define INITIAL_CHEAT_SHORT_LEVEL NO
#define INITIAL_CHEAT_NO_DANGEROUS_TILE_COLLISION  NO
#define INITIAL_CHEAT_UNLIMITED_LIVES  NO
#define INITIAL_CHEAT_NO_ENEMY_COLLISION  NO

#define FIRE_BUTTON_REMOVE 10    // nach xx Schüssen wird Firebutton entfernt (weil er sonst stört)
#define INITIAL_SCROLL_SPEED 1
#define INITIAL_NUM_FIGHTERS 5     // wieviele Leben hat unser Fighter zu Beginn (orig = 5)
#define NUM_LEVELS 18               // so viele Levels gibt es
#define TIME_PER_LEVEL (3*60)       // in soviel Sekunden muss Level durchflogen sein. standard =3 * 60

#define SCORE_FOR_BONUS_FIGHTER 15000  // Alle xx Punkte gibt es einen zusätzlichen Fighter (original = 15000)

#define BIG_SHIP_MIN_DISTANCE_TO_HIT 200  // ab dieser Distance ganz BigShip abgeschossen werden
#define BIG_SHIP_INITIAL_Y_MIN 3500      // tiefst mögliche, zufällige y-startposition des BigShips
#define BIG_SHIP_INITIAL_Y_MAX 4500     // höchst möglichw, zufällige y-startposition des BigShips
#define BIG_SHIP_RADAR_DISTANCE 600    // wenn der Abstand zwischen Fighter und BigShip kleiner als dieser Wert ist, erscheint Alarm im Panel

#define SPEED_DELAY 1           // wie schnell wird auf Speedänderungen reagiert
#define SPEED_MAX 10            // (turbo ist noch schneller)

#define ENEMY_WAIT_MIN 2        // mindestens alle x Sekunden kommen neue Enemies
#define ENEMY_WAIT_MAX 5        // maximal alle x Sekunden kommen neue Enemies
#define ENEMY_SHOOT_RATIO 150   // pro SKScene Update wird mit einer Chance von 1:150 geschossen
#define NUM_ENEMIES_IN_GROUP 6  // Enemies erscheinen in sechser Gruppen
#define NUM_ENEMIES_FOR_BONUS_MODE 100  // so viele Enemies müssen abgeschossen werden um den BonusMode zu aktivieren (original = 100)


// Timer
#define TIMER_HIGHSCORE_DURATION 5  // wie lange sollen Highscore angezeigt werden (wenn kein Input erfolgt)
#define TIMER_TITLE_DURATION 7      // wie lange soll Titlescreen angezeigt werden

// Z-Positionen Game
#define Z_POSITION_TERRAIN 40
#define Z_POSITION_COLOR_CYCLE -50
#define Z_POSITION_FIGHTER 10
#define Z_POSITION_ENEMY 12
#define Z_POSITION_ENEMY_SHOOTS 13
#define Z_POSITION_BIG_SHIP 15
#define Z_POSITION_BIG_SHIP_EXPLO 16
#define Z_POSITION_FIGHTER_SHOOTS 20
#define Z_POSITION_BIG_SHIP_SHOOTS 20
#define Z_POSITION_PANEL 100
#define Z_POSITION_PANEL_ALARM 103
#define Z_POSITION_PANEL_ELEMENTS  105          // Dinge welche direkt über das Panel gezeichnet werden (Font, Engery, etc.)
#define Z_POSITION_GAME_OVER 150
#define Z_POSITION_JOYSTICK_ELEMENTS 500
#define Z_POSITION_HIGHSCORE_TEXT 50
#define Z_POSITION_HIGHSCORE_HELM_PIC 60
#define Z_POSITION_HIGHSCORE_BLACK_MASK 70
#define Z_POSITION_HIGHSCORE_ENTER_NAME_TEXT 77

// Scores

#define SCORE_EXPLODED_ENEMY 100
#define SCORE_EXPLODED_ENEMY_WITH_BONUS_FLAG 10  // so viele Punkte gibt es am Ende des Levels pro abgeschossenem Enemy bei gesetztem BonusFlag
#define SCORE_EXPLODED_TILE 10

#define SCORE_EXPLODED_BIGSHIP 100

// Energy

#define INITIAL_ENERGY_LEVEL (4*176)        // aus orig game (mit leichter korektur)
#define ENERGY_LOSS_AT_ENEMY_SHOOT_HIT 12*4   // Abzug wenn uns ein Enemy-Schuss getroffen hat
#define ENERGY_LOSS_AT_ENEMY_HIT 10*4         // Abzug wenn uns ein Enemy getroffen hat
#define ENERGY_LOSS_AT_SHOOT 1              // Abzug wenn Fighter schiesst
#define ENERGY_LOSS_AT_BIGSHIP_MISSED 2     // ein Zweitel der Energy wird abgezogen wenn BigShip vorbeifliegt und es nicht getroffen wird

#endif
