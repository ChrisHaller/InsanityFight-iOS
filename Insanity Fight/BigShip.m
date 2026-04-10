//
//  BigShip.m
//  SpriteWalkthrough
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import "BigShip.h"
#import "constants.h"

const int numExploPics = 15;


@implementation BigShip{
    SKNode* rootNode;
    NSMutableArray *exploAnimation;
    SKAction* explo;
    SKAction* actionSequenceExplodeShip;
    SKSpriteNode *explSprite;
    SKSpriteNode *bottomSprite;
    SKTexture *bottomNormal;
    SKTexture *bottomShoot;
    
    uint shootCounter;
    SKAction *actionShoot;
}

@synthesize shipSprite;
@synthesize isExploding;
@synthesize shootCategoryBitMask;
@synthesize shootContactTestBitMask;


-(CGSize) size
{
    return shipSprite.size;
}


-(id)init
{
    self = [super init];
    if (self) {
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"BigShip"];
        shipSprite = [SKSpriteNode spriteNodeWithTexture: [atlas textureNamed:@"BigShip.png"]];
        shipSprite.name = @"BigShip";
        shipSprite.zPosition = Z_POSITION_BIG_SHIP;

        
        // unterer Teil mit Kanone
        
        bottomNormal = [atlas textureNamed:@"BigShipBottom.png"];
        bottomShoot = [atlas textureNamed:@"BigShipBottomShoot.png"];
        
        bottomSprite = [SKSpriteNode spriteNodeWithTexture: bottomNormal];
        bottomSprite.position = CGPointMake(0, -226);
       // bottomSprite.zPosition = Z_POSITION_BIG_SHIP;
        bottomSprite.name = @"BigShipBottom";
        [shipSprite addChild:bottomSprite];
        
        // Explosionssequenz laden
        exploAnimation = [[NSMutableArray alloc] init];
        SKTexture* texture;
        for(int i = 0; i < numExploPics; i++)
        {
            texture = [atlas textureNamed: [NSString stringWithFormat:@"Explo%d.PNG", i+1]];
            [exploAnimation addObject:texture];
        }

        shipSprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:shipSprite.size];
        shipSprite.physicsBody.affectedByGravity = NO;
      //  shipSprite.physicsBody.dynamic = NO;

        
        bottomSprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bottomSprite.size];
        bottomSprite.physicsBody.affectedByGravity = NO;
       // bottomSprite.physicsBody.dynamic = NO;

        
        
        // actions preloaden
        explSprite = [SKSpriteNode spriteNodeWithTexture:exploAnimation[0]];
        explSprite.name = @"BigShipExplo";
        explo = [SKAction animateWithTextures:exploAnimation timePerFrame:0.11];
        actionSequenceExplodeShip = [SKAction sequence:@
                                  [
                                   [SKAction runBlock:^{explSprite.hidden = NO;}],
                                   [SKAction playSoundFileNamed:@"BigShipExplo.wav" waitForCompletion:NO],
                                   explo,
                                   [SKAction runBlock:^{isExploding = NO;}],
                                    [SKAction removeFromParent]
                                   ]
                                  ];
        

    
        actionShoot   = [SKAction sequence:@
                                     [
                                      [SKAction waitForDuration:2],
                                      [SKAction playSoundFileNamed:@"BigShipShoots.wav" waitForCompletion:NO],
                                      [SKAction setTexture:bottomShoot],
                                      [SKAction runBlock:^{[self addShsootSprite];}],
                                      [SKAction waitForDuration:0.1],
                                      [SKAction setTexture:bottomNormal],
                                      [SKAction waitForDuration:0.3],
                                      [SKAction setTexture:bottomShoot],
                                      [SKAction runBlock:^{[self addShsootSprite];}],
                                      [SKAction waitForDuration:0.1],
                                      [SKAction setTexture:bottomNormal],
                                      [SKAction waitForDuration:0.3],
                                      [SKAction setTexture:bottomShoot],
                                      [SKAction runBlock:^{[self addShsootSprite];}],
                                      [SKAction waitForDuration:0.1],
                                      [SKAction setTexture:bottomNormal],
                                      [SKAction waitForDuration:0.3],
                                      [SKAction setTexture:bottomShoot],
                                      [SKAction runBlock:^{[self addShsootSprite];}],
                                      [SKAction waitForDuration:0.1],
                                      [SKAction setTexture:bottomNormal],
                                      [SKAction waitForDuration:0.3],
                                      [SKAction setTexture:bottomShoot],
                                      [SKAction runBlock:^{[self addShsootSprite];}],
                                      [SKAction waitForDuration:0.1],
                                      [SKAction setTexture:bottomNormal],
                                      [SKAction waitForDuration:0.3],
                                      [SKAction setTexture:bottomShoot],
                                      [SKAction runBlock:^{[self addShsootSprite];}],
                                      [SKAction waitForDuration:0.1],
                                      [SKAction setTexture:bottomNormal],
                                      [SKAction waitForDuration:0.3],
                                      [SKAction setTexture:bottomShoot],
                                      [SKAction runBlock:^{[self addShsootSprite];}],
                                      [SKAction waitForDuration:0.1],
                                      [SKAction setTexture:bottomNormal]                                      ]
                                     ];
        
    
    }
    return self;
}

-(void) addShsootSprite
{
    
    SKSpriteNode *shootLeft = [[SKSpriteNode alloc] initWithColor:[SKColor blueColor] size:CGSizeMake(5,5)];
    SKSpriteNode *shootRight = [[SKSpriteNode alloc] initWithColor:[SKColor blueColor] size:CGSizeMake(5,5)];
    [shootLeft addChild:shootRight];
    shootRight.position =  CGPointMake(shootLeft.position.x + 12, shootLeft.position.y);
    
    shootLeft.name = @"BigShipShoot";
    shootRight.name = @"BigShipShoot";

    
    shootLeft.position =  CGPointMake(shipSprite.position.x - 5, shipSprite.position.y -240);
    
    
    shootLeft.zPosition = Z_POSITION_BIG_SHIP_SHOOTS;
    SKAction *actionMoveDown = [SKAction moveByX: 0 y: -380 duration: 1.5];
    SKAction *actionRemove = [SKAction removeFromParent];
    SKAction *actionMoveSequence = [SKAction sequence:@[actionMoveDown, actionRemove]];
    
    [shootLeft runAction: actionMoveSequence];
    [rootNode addChild: shootLeft];
    
    shootLeft.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:shootLeft.size];
    shootLeft.physicsBody.categoryBitMask =   shootCategoryBitMask;
    shootLeft.physicsBody.contactTestBitMask = shootContactTestBitMask;
    shootLeft.physicsBody.collisionBitMask = 0;
    shootLeft.physicsBody.usesPreciseCollisionDetection = YES;
    

    shootRight.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:shootRight.size];
    shootRight.physicsBody.categoryBitMask =   shootCategoryBitMask;
    shootRight.physicsBody.contactTestBitMask = shootContactTestBitMask;
    shootRight.physicsBody.collisionBitMask = 0;
    shootRight.physicsBody.usesPreciseCollisionDetection = YES;
}

-(void) addShipToNode:(SKNode*) sceneNode{
    rootNode = sceneNode;
    [sceneNode addChild:shipSprite];
}


-(CGPoint) position{
    return shipSprite.position;
}


-(void) moveX:(float) x andY:(float) y{
    shipSprite.position = CGPointMake(shipSprite.position.x + x, shipSprite.position.y + y);
    
    if(shipSprite.position.x < 0)
        shipSprite.position = CGPointMake(0.0, shipSprite.position.y);
    
    
    if(shipSprite.position.x > rootNode.scene.view.bounds.size.width)
        shipSprite.position = CGPointMake(rootNode.scene.view.bounds.size.width, shipSprite.position.y);
}


-(void) setPosition:(CGPoint)position{
    shipSprite.position = position;
}

-(uint32_t) categoryBitMask{
    return shipSprite.physicsBody.categoryBitMask;
}


-(void) setCategoryBitMask:(uint32_t)categoryBitMask{
    shipSprite.physicsBody.categoryBitMask = categoryBitMask;
    bottomSprite.physicsBody.categoryBitMask = categoryBitMask;
}


-(uint32_t) contactTestBitMask{
    return shipSprite.physicsBody.contactTestBitMask;
}


-(void) setContactTestBitMask:(uint32_t)contactTestBitMask{
    shipSprite.physicsBody.contactTestBitMask = contactTestBitMask;
    bottomSprite.physicsBody.contactTestBitMask = contactTestBitMask;
    shipSprite.physicsBody.collisionBitMask = 0;
    bottomSprite.physicsBody.collisionBitMask = 0;
}


// Explosion des BigSips auslösen
-(void) explode{
    NSLog(@"BigShip explode!");
    isExploding = YES;
    
    [bottomSprite removeAllActions];        // evtl. gestartete Schiess-SKAction anhalten
    
    SKAction* actionSequenceFadeOutShip = [SKAction sequence:@
                              [
                               [SKAction waitForDuration:0.4],
                               [SKAction fadeOutWithDuration: 0.5],
                               [SKAction removeFromParent]
                               ]
                              ];
    
    
    explSprite.anchorPoint = CGPointMake(0.5, 1);
    explSprite.position = CGPointMake(shipSprite.position.x -1 , shipSprite.position.y - 61);
    explSprite.hidden = YES;
    explSprite.zPosition = Z_POSITION_BIG_SHIP_EXPLO;
    [rootNode addChild:explSprite];
    
    [explSprite runAction:actionSequenceExplodeShip];
    [shipSprite runAction:actionSequenceFadeOutShip];
}




-(void) shoot{
    [bottomSprite runAction:actionShoot];
    NSLog(@"BigShip shoot");
    
}

@end

