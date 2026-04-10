//
//  Fighter.h
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>




@interface Fighter : NSObject{
    
   
    
}

@property(readonly) SKSpriteNode *fighterSprite;
@property uint32_t shootCategoryBitMask;
@property uint32_t shootContactTestBitMask;
@property CGPoint position;
@property uint32_t categoryBitMask;
@property uint32_t contactTestBitMask;
@property (readonly) CGSize size;
@property (readonly) BOOL isExploding;


-(void) addFighterToNode:(SKNode*) sceneNode;
-(void) shoot:(bool) superShoot;
-(void) moveX:(float) x andY:(float) y;
-(void) explode;



@end
