//
//  TitleScene.h
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import <SpriteKit/SpriteKit.h>
#import "Game.h"
#import "IFScene.h"
#import "iCadeReaderView.h"

@interface TitleScene : IFScene<iCadeEventDelegate>

@property Game* game;



@end
