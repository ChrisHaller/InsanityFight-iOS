//
//  IFScene.h
//  Insanity Fight
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import <SpriteKit/SpriteKit.h>

@interface IFScene : SKScene

-(void) pause;
-(void) resume;
-(void) gameControllerButtonPressed;
-(void) gameControllerChanged;
-(void) orientationChanged;

@end
