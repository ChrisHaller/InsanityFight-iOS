//
//  Fighter.m
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import "Fighter.h"
#import "constants.h"
#import "Game.h"

const int numFighterInAtlas = 7;
const int normalFighterIndexInAtlas = 3;
const int numExploFighterInAtlas = 19;

@implementation Fighter{
    SKAction* actionPlayFighterShootSound;
    SKNode* rootNode;
    SKTexture* fighterTextures[numFighterInAtlas];
    NSMutableArray* exploFighterTextures;
    SKAction* actionPlayTileHitSound;
}


@synthesize fighterSprite;
@synthesize shootCategoryBitMask;
@synthesize shootContactTestBitMask;
@synthesize isExploding;


// Fighter-Sprite erstellen und einem SzenenNode hinzufügen
-(void) addFighterToNode:(SKNode*) sceneNode{

    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"fighter"];
    
    // normale Fighter Texturen laden
    for(int i = 0; i < numFighterInAtlas; i++)
    {
        fighterTextures[i] = [atlas textureNamed: [NSString stringWithFormat:@"fighter_%d.PNG", i]];
    }
    
    
    // Explosions Fighter Texturen laden
    exploFighterTextures = [NSMutableArray new];
    for(int i = 0; i < numExploFighterInAtlas; i++)
    {
        [exploFighterTextures addObject: [atlas textureNamed: [NSString stringWithFormat:@"fighterexplo_%d.PNG", i]]];
    }
    
    
    rootNode = sceneNode;
    fighterSprite = [SKSpriteNode spriteNodeWithTexture:fighterTextures[normalFighterIndexInAtlas]];
    fighterSprite.name = @"Fighter";
    
    [sceneNode addChild:fighterSprite];
    //fighterSprite.physicsBody.affectedByGravity = NO;   // nützt scheinbar nichts    
    fighterSprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:fighterSprite.size.width/3];
    fighterSprite.physicsBody.usesPreciseCollisionDetection = NO;
    fighterSprite.physicsBody.dynamic = YES;
    fighterSprite.zPosition = Z_POSITION_FIGHTER;
 
    

    // preload sound
    actionPlayFighterShootSound = [SKAction playSoundFileNamed:@"Fighter-Shoot.wav" waitForCompletion:NO];
    actionPlayTileHitSound = [SKAction playSoundFileNamed:@"TileHit.wav" waitForCompletion:NO];


    
}


-(void) shoot:(bool) superShoot;{
    
    // im Normalfall ein Schuss. 5 mal schiessen wenn "superShoot" aktiv ist
    int numShoots = 1;
    if(superShoot){
      numShoots = 5;
    }
    
    
    for(int i = 0; i < numShoots; i++)
    {
        SKSpriteNode *leftShoot = [[SKSpriteNode alloc] initWithColor:[SKColor blueColor] size:CGSizeMake(4,4)];
        SKSpriteNode *rightShoot = [[SKSpriteNode alloc] initWithColor:[SKColor blueColor] size:CGSizeMake(4,4)];
    
        leftShoot.name = @"FighterShoot left";
        leftShoot.position =  CGPointMake(fighterSprite.position.x - 9, fighterSprite.position.y + 20);
        leftShoot.zPosition = Z_POSITION_FIGHTER_SHOOTS;

        leftShoot.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftShoot.size];
        leftShoot.physicsBody.categoryBitMask =   shootCategoryBitMask;
        leftShoot.physicsBody.contactTestBitMask = shootContactTestBitMask;
        leftShoot.physicsBody.collisionBitMask = 0;
        leftShoot.physicsBody.usesPreciseCollisionDetection = YES;
        leftShoot.physicsBody.dynamic = NO;
        
        
        rightShoot.name = @"FighterShoot right";
        rightShoot.position =  CGPointMake(fighterSprite.position.x + 6, fighterSprite.position.y + 20);
        rightShoot.zPosition = Z_POSITION_FIGHTER_SHOOTS;
        
        rightShoot.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightShoot.size];
        rightShoot.physicsBody.categoryBitMask =   shootCategoryBitMask;
        rightShoot.physicsBody.contactTestBitMask = shootContactTestBitMask;
        rightShoot.physicsBody.collisionBitMask = 0;
        rightShoot.physicsBody.usesPreciseCollisionDetection = YES;
        rightShoot.physicsBody.dynamic = NO;
        
        leftShoot.alpha = 0;
        rightShoot.alpha = 0;
        
        SKAction *actionShootSequence = [SKAction sequence:@[
                                                             [SKAction waitForDuration:i * 0.1],
                                                             [SKAction fadeInWithDuration:0],
                                                             actionPlayFighterShootSound,
                                                            [SKAction moveByX: 0 y: 380 duration: 0.7],
                                                            [SKAction removeFromParent]
                                                             ]
                                         ];
        [leftShoot runAction: actionShootSequence];
        [rightShoot runAction: actionShootSequence];
        [rootNode addChild: leftShoot];
        [rootNode addChild: rightShoot];
    }
     
}

-(void) moveX:(float) x andY:(float) y{
    self.position = CGPointMake(fighterSprite.position.x + x, fighterSprite.position.y + y);

    if(fighterSprite.position.x < 0)
        self.position = CGPointMake(0.0, fighterSprite.position.y);
    
    if(fighterSprite.position.x > rootNode.scene.size.width)
        self.position = CGPointMake(rootNode.scene.size.width, fighterSprite.position.y);
}

-(CGSize) size{
    return fighterSprite.size;
}

-(CGPoint) position{
    return fighterSprite.position;
}

-(void) setPosition:(CGPoint)position{
    fighterSprite.position = position;
   // NSLog(@"New position x:%f, y; %f", position.x, position.y);
}

-(uint32_t) categoryBitMask{
    return fighterSprite.physicsBody.categoryBitMask;
}


-(void) setCategoryBitMask:(uint32_t)categoryBitMask{
    fighterSprite.physicsBody.categoryBitMask = categoryBitMask;
    
}


-(uint32_t) contactTestBitMask{
    return fighterSprite.physicsBody.contactTestBitMask;
}


-(void) setContactTestBitMask:(uint32_t)contactTestBitMask{
    fighterSprite.physicsBody.contactTestBitMask = contactTestBitMask;
    fighterSprite.physicsBody.collisionBitMask = 0;
}


-(void) explode{
    NSLog(@"Fighter explode");
    isExploding = YES;
    SKAction* explo = [SKAction animateWithTextures:exploFighterTextures timePerFrame:0.1];
    
    SKAction* fullSequence = [SKAction sequence:@
                              [
                               actionPlayTileHitSound,
                               explo,
                               [SKAction runBlock:^{fighterSprite.hidden = YES;}],
                               [SKAction waitForDuration:0.5],
                               [SKAction runBlock:^{isExploding = NO;}]
                               ]
                              ];
    
    [fighterSprite runAction:fullSequence];
}




@end
