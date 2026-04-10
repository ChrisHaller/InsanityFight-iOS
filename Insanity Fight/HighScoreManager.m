//
//  HighScoreManager.m
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import "HighScoreManager.h"



@implementation HighScoreManager{
    NSMutableArray* scoreArray;            // höchster Score ist am tiefsten Index;

}

-(id)init
    {
        self = [super init];
        if (self) {
            scoreArray = [NSMutableArray new];
            for(int i = 0; i < HIGHSCORE_MAX_ENTRIES; i++)
            {
                HighScoreEntry* entry = [HighScoreEntry new];
                entry.name = @"";
                entry.score = 0;
                scoreArray[i] = entry;
            }
            [self clearHighScores];
        }
        return self;
    }

-(void) clearHighScores
{
    for (HighScoreEntry* entry in scoreArray) {
       entry.name = @"Amiga";
        entry.score = 1000;

    }

    
}

-(uint)addPlayer:(NSString*) name withScore:(uint) score{
    uint position = 0;
    
    for(int i = 0; i < HIGHSCORE_MAX_ENTRIES; i++)
    {
        HighScoreEntry* entry = scoreArray[i];
        if(entry.score == 0)        // freier Eintrag?
        {
            // ja. Dieser Eintrag kann verwendet werden
            position = i + 1;
            entry.name = name;
            entry.score = score;
            break;
        }
        else
        {
            // prüfen ob dieser EIntrag einen tieferen Score hat
            if(entry.score < score)
            {
                // Score ist tiefer. Somit fügen wir hier den neuen ein.
                
                
                // zuerst am Schluss Platz machen (letzten Eintrag entfernen)
                [scoreArray removeObjectAtIndex:HIGHSCORE_MAX_ENTRIES -1];
                
                // dann neuen Eintrag anfügen
                HighScoreEntry* newEntry = [HighScoreEntry new];
                newEntry.name = name;
                newEntry.score = score;
                [scoreArray insertObject:newEntry atIndex:i];
                position = i + 1;
                break;
            }
        }
        
    }

    return position;
}

-(uint) loadHighScore{
    uint result = 0;
    NSLog(@"loadHighScore");
    [self clearHighScores];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults ];
    NSMutableDictionary * highScoreNamesDictionary = [defaults objectForKey:@"HighScore-Names"];
    NSMutableDictionary * highScoreScoresDictionary = [defaults objectForKey:@"HighScore-Scores"];
    
    for(int i = 0; i < HIGHSCORE_MAX_ENTRIES; i++){
        NSNumber* position = [NSNumber numberWithInt:i + 1];
        
        NSString* name = [highScoreNamesDictionary objectForKey:[position stringValue]];
        
        if(name != nil)
        {
            NSString* score = [highScoreScoresDictionary objectForKey:[position stringValue]];
            if(score != nil)
            {
                [self addPlayer:name withScore:[score intValue]];
                result++;
            }
        }
     }
    NSLog(@"Num highscores loaded: %d", result);
    return result;
    
}

-(void) saveHighScore{
    // Liste speichern
    NSLog(@"saveHighScore");
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults ];
    
    NSMutableDictionary *dictionaryNames = [NSMutableDictionary new];
    NSMutableDictionary *dictionaryScores = [NSMutableDictionary new];
    
    
    int positionAsInt = 1;
    for (HighScoreEntry* entry in scoreArray) {
        NSNumber* score = [NSNumber numberWithInt:entry.score];
        NSNumber* position = [NSNumber numberWithInt: positionAsInt];
        
        [dictionaryScores setObject:score forKey:[position stringValue]];
        [dictionaryNames setObject:entry.name forKey:[position stringValue]];
        positionAsInt++;
    }
    
    [defaults setObject:dictionaryScores forKey:@"HighScore-Scores"];
    [defaults setObject:dictionaryNames forKey:@"HighScore-Names"];
    [defaults synchronize];

}


-(uint) positionInHighScore:(uint) score{
    uint position = 0;
    HighScoreEntry* lastEntry = scoreArray[scoreArray.count-1];
    if(score > lastEntry.score)         // Poistion in der Liste nur suchen wenn Score höher als der letzte Eintrag in der liste ist
    {
        for (HighScoreEntry* entry in scoreArray) {
            if(score > entry.score)
            {
                position++;
                break;
            }
            position++;
        }
    }
    else
    {
        position = 0;
    }
    
    NSLog(@"Position in highscore %d score = %d", position, score);
    return position;
}


-(uint) count{
    return (uint)[scoreArray count];
}

-(uint) highScore{
    HighScoreEntry* entry = scoreArray[0];
    return entry.score;
}

-(HighScoreEntry*)playerAtIndex:(uint) index{
    HighScoreEntry* entry = nil;
    
    if(index < [scoreArray count])
    {
        entry = [scoreArray objectAtIndex:index];
    }
    
    return entry;
}

    
@end

@implementation HighScoreEntry
@synthesize name;
@synthesize score;
@end

