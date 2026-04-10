//
//  Enemies.m
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import "Enemies.h"
#import "constants.h"


const int NUM_ENEMY_VARIANTS = 14;
const int NUM_EXPLO_IMAGES = 11;


@implementation Enemies{
    SKNode* rootNode;
    NSMutableArray *exploAnimation;
    struct CGPath *path;
    SKSpriteNode *enemySprites[NUM_ENEMIES_IN_GROUP];
    SKTexture *enemyTextures[NUM_ENEMY_VARIANTS];
    SKAction *exploSequence;
}


@synthesize numEnemiesFlying;
@synthesize shootCategoryBitMask;
@synthesize shootContactTestBitMask;

-(id)init
{
    self = [super init];
    if (self) {
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"enemy"];
        
        // Explosionssequenz laden
        exploAnimation = [[NSMutableArray alloc] init];
        SKTexture* texture;
        for(int i = 0; i < NUM_EXPLO_IMAGES; i++)
        {
            texture = [atlas textureNamed: [NSString stringWithFormat:@"enemy_%d.PNG", i+40]];
            [exploAnimation addObject:texture];
        }

        // die verschiedenen EnemyVarianten als Textures laden
        for(int i = 0; i < NUM_ENEMY_VARIANTS; i++)
        {
            texture = [atlas textureNamed: [NSString stringWithFormat:@"enemy_%d.PNG", i]];
            enemyTextures[i] = texture;
        }

        
        SKAction *exploAnim = [SKAction animateWithTextures:exploAnimation timePerFrame:0.1];
        exploSequence = [SKAction sequence:@[
                                                  [SKAction playSoundFileNamed:@"EnemyHit.wav" waitForCompletion:NO],
                                                  exploAnim,
                                                  [SKAction removeFromParent]
                                                  ]];
        
        

     
    }
    return self;
}

// Enemies anhalten (Pause-Modus MFi)
-(void) pause{
    for(int i = 0; i < NUM_ENEMIES_IN_GROUP; i++){
        SKSpriteNode* enemy = enemySprites[i];
        enemy.paused = YES;
    }
}

// Enemies wieder fliegen lassen (Pause-Modus MFi)
-(void) resume{
    for(int i = 0; i < NUM_ENEMIES_IN_GROUP; i++){
        SKSpriteNode* enemy = enemySprites[i];
        enemy.paused = NO;
    }
}

-(void) addEnemiesToNode:(SKNode*) node{
    rootNode = node;

    if(numEnemiesFlying != 0)
    {
        NSLog(@"ERROR numEnemiesFlying != 0!!!");
    }
    
    numEnemiesFlying += NUM_ENEMIES_IN_GROUP;
    
    CGMutablePathRef cgpath = CGPathCreateMutable();
    
    /*
    //random values
    float xStart =  [self getRandomNumberBetween:0 to:320 ];
    float xEnd = [self getRandomNumberBetween:0 to:320 ];
    //ControlPoint1
    float cp1X = [self getRandomNumberBetween:0 to:320 ];
    float cp1Y = [self getRandomNumberBetween:80 to:480];
    //ControlPoint2
    float cp2X = [self getRandomNumberBetween:0 to:320];
    float cp2Y = [self getRandomNumberBetween:80 to:480];
    CGPoint s = CGPointMake(xStart, 480);
    CGPoint e = CGPointMake(xEnd, 40);
    CGPoint cp1 = CGPointMake(cp1X, cp1Y);
    CGPoint cp2 = CGPointMake(cp2X, cp2Y);
    CGPathMoveToPoint(cgpath,NULL, s.x, s.y);
    CGPathAddCurveToPoint(cgpath, NULL, cp1.x, cp1.y, cp2.x, cp2.y, e.x, e.y);
    
    
    CGPathMoveToPoint(cgpath,NULL, s.x, s.y);
     
    */
    
    CGPathMoveToPoint(cgpath,NULL, getRandomNumberBetween(0,320), 480);
    CGPathAddArc(cgpath, NULL, getRandomNumberBetween(100, 220), getRandomNumberBetween(200, 440 ), getRandomNumberBetween(30, 100), 0.f, (360* M_PI)/180, NO);
    CGPathAddLineToPoint(cgpath, NULL, getRandomNumberBetween(0, 320), getRandomNumberBetween(130, 480));
    
    

    CGPathAddArc(cgpath, NULL, getRandomNumberBetween(100, 220), getRandomNumberBetween(200, 440), getRandomNumberBetween(30,100), 0.f, (360* M_PI)/180, NO);
    CGPathAddLineToPoint(cgpath, NULL,  getRandomNumberBetween(0, 320), 50);
    
    SKAction *actionEnemyPath = [SKAction followPath:cgpath asOffset:NO orientToPath:NO duration:8]; // standard = 8sek
    
    
    
    // Sprites erstellen
    int enmyIndex = getRandomNumberBetween(0, NUM_ENEMY_VARIANTS - 1);
    for(int i = 0; i < NUM_ENEMIES_IN_GROUP; i++){
        enemySprites[i] = [SKSpriteNode spriteNodeWithTexture:enemyTextures[enmyIndex]];
    }
    
    
    //
    
    for(int i = 0; i < NUM_ENEMIES_IN_GROUP; i++){
        SKSpriteNode* enemy = enemySprites[i];
        enemy.zPosition = Z_POSITION_ENEMY;
        enemy.position = CGPointMake(0, 1000);       // zuerst ausserhablb des sichtbaren Bereichs positionieren
        
        enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.size];
        enemy.physicsBody.affectedByGravity = NO;
        enemy.physicsBody.dynamic = YES;
        enemy.name = @"Enemy";
        
        [rootNode addChild:enemy];
        
        SKAction *sequence = [SKAction sequence:@[
                                                  [SKAction waitForDuration:i*0.11],
                                                  actionEnemyPath,
                                                  [SKAction runBlock:^{numEnemiesFlying--;}],
                                                  [SKAction removeFromParent],
                             ]];
        [enemy runAction:sequence];
    }
}

int getRandomNumberBetween(int from,  int to)
{
    return (int)from + arc4random() % (to-from+1);
}

// categoryBitMask des ersten Sprites (alle anderen sind identisch)
-(uint32_t) categoryBitMask{
    return enemySprites[0].physicsBody.categoryBitMask;
}


-(void) setCategoryBitMask:(uint32_t)categoryBitMask{
    for(int i = 0; i < NUM_ENEMIES_IN_GROUP; i++)
    {
        enemySprites[i].physicsBody.categoryBitMask = categoryBitMask;
    }
}


// categoryBitMask des ersten Sprites (alle anderen sind identisch)
-(uint32_t) contactTestBitMask{
    return enemySprites[0].physicsBody.contactTestBitMask;
}


-(void) setContactTestBitMask:(uint32_t)contactTestBitMask{
    for(int i = 0; i < NUM_ENEMIES_IN_GROUP; i++)
    {
        enemySprites[i].physicsBody.contactTestBitMask = contactTestBitMask;
        enemySprites[i].physicsBody.collisionBitMask = 0;
        
    }
}

-(void) explodeEnemy:(SKSpriteNode*) enemySprite{
    [enemySprite removeAllActions];             // Bewegung anhalten
    [enemySprite runAction:exploSequence];
    numEnemiesFlying--;
}

// Gegner schiessen lassen (wird bei jedem SKScene -> Update gerufen
-(void) updateShoots{
    if(numEnemiesFlying > 0)
    {
        for(int i = 0; i < NUM_ENEMIES_IN_GROUP; i++)
        {
            if(getRandomNumberBetween(0, ENEMY_SHOOT_RATIO) == 5)         // Zufällig (150:1) wird geschossen
            {
                SKSpriteNode *enemy = enemySprites[i];
                if(enemy.physicsBody.categoryBitMask != 0)      // nur schiessen wenn enemy noch nicht abgeschossen wurde
                {
                    [self shoot:enemySprites[i]];
                }
            }
        }
    }
}

-(void) shoot:(SKSpriteNode*) node{
    SKSpriteNode *shootLeft = [[SKSpriteNode alloc] initWithColor:[SKColor blueColor] size:CGSizeMake(4,4)];
    
    shootLeft.name = @"EnemyShoot";
    // SKSpriteNode *shootRight = [[SKSpriteNode alloc] initWithColor:[SKColor blueColor] size:CGSizeMake(4,4)];
    // shootRight.position = CGPointMake(12.0, 0.0);
    // [shootLeft addChild: shootRight];
    
    shootLeft.position =  CGPointMake(node.position.x, node.position.y + 8);
    
    
    shootLeft.zPosition = Z_POSITION_ENEMY_SHOOTS;
    SKAction *actionMoveDown = [SKAction moveByX: 0 y: -280 duration: 1.5];
    SKAction *actionRemove = [SKAction removeFromParent];
    SKAction *actionMoveSequence = [SKAction sequence:@[actionMoveDown, actionRemove]];
    
    [shootLeft runAction: actionMoveSequence];
    [rootNode addChild: shootLeft];
    
    shootLeft.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:shootLeft.size];
    shootLeft.physicsBody.categoryBitMask =   shootCategoryBitMask;
    shootLeft.physicsBody.contactTestBitMask = shootContactTestBitMask;
    shootLeft.physicsBody.collisionBitMask = 0;
    shootLeft.physicsBody.usesPreciseCollisionDetection = YES;
}


@end
