//
//  HighScoreManager.h
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

#define HIGHSCORE_MAX_ENTRIES 99

@interface HighScoreEntry : NSObject{
    
}

@property NSString* name;
@property uint score;


@end

@interface HighScoreManager : NSObject
@property(readonly) uint highScore;
-(uint)addPlayer:(NSString*) name withScore:(uint) score;
-(HighScoreEntry*)playerAtIndex:(uint) index;
-(uint) count;
-(uint) loadHighScore;
-(void) saveHighScore;
-(void) clearHighScores;
-(uint) positionInHighScore:(uint) score;
@end



