//
//  Joystick.h
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>


@interface Joystick : NSObject


@property (readonly) SKSpriteNode* arrowRight;
@property (readonly) SKSpriteNode* arrowLeft;
@property (readonly) SKSpriteNode* arrowDown;
@property (readonly) SKSpriteNode* arrowUp;
@property (readonly) SKSpriteNode* fireButton;

-(void) addToNode:(SKNode*) node;
-(void) hoverUpLeft:(BOOL) left right:(BOOL) right up:(BOOL) up down:(BOOL) down;
-(void) hoverDownLeft:(BOOL) left right:(BOOL) right up:(BOOL) up down:(BOOL) down;
-(void) removeFireButton;
-(void) addFireButton;
//-(void) stopFireButtonHover;
-(void)removeAll;
@end
