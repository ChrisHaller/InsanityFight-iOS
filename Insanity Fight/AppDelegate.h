//
//  AppDelegate.h
//  Insanity Fight
//
//   Created and Copyright (c) 2014–2026 Christian Haller
//   This file is part of Insanity Fight.
//   Released under the GNU General Public License v3.0 or later.
//   See the LICENSE file for details.
//

#import <UIKit/UIKit.h>
#import "Game.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property Game* game;

@end
