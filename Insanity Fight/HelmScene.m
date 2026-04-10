//
//  HelmScene.m
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import "HelmScene.h"
#import "Panel.h"
#import "Game.h"

@import AVFoundation;

const int numStars = 8;

@implementation HelmScene{
    
    BOOL contentCreated;
    
    SKNode* rootNode;
    Panel* panel;
    AVAudioPlayer *_backgroundAudioPlayer;
    SKTextureAtlas *atlasStars;
    SKTexture* textureStars[numStars];
    UILabel *title;
    UIButton *button;
    BOOL _shootLock;
    
}

@synthesize game;




- (void)didMoveToView:(SKView *)view
{
    NSLog(@"HelmScene didMoveToView");
    if (!contentCreated)
    {
        
        
        self.backgroundColor = [SKColor blackColor];
        self.scaleMode = SKSceneScaleModeAspectFit;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        
        // RootNode an welchem wir ALLES weitere anhängen. Dadurch müssen wir z.B. nur in einem einzigen Node die Grösse ändern wenn wir das mal tun wollen.
        
        rootNode = [[SKNode alloc] init];
        [self addChild:rootNode];
        
        
        // panel hinzufügen
        
        panel = [Panel new];
        [panel addPanelToNode:rootNode];
        panel.highScore = game.highScore;
        panel.score = game.score;
        
        
        // Helm-Pic
        
        SKTexture* textureHelmNormal = [SKTexture textureWithImageNamed:@"HelmPic1.png"];
        SKTexture* textureHelmBlinzel = [SKTexture textureWithImageNamed:@"HelmPic2.png"];
        SKTexture* textureHelmClosed = [SKTexture textureWithImageNamed:@"HelmPic3.png"];


        // normales Helm-Sprite
        SKSpriteNode *picNode = [SKSpriteNode spriteNodeWithTexture:textureHelmNormal];
        picNode.anchorPoint = CGPointMake(0,0);
        picNode.position = CGPointMake(0, panel.size.height + 0);
        [rootNode addChild:picNode];
        
        // Sprite mit geschlossenem Visier
        
        SKSpriteNode *nodeHelmClosed = [SKSpriteNode spriteNodeWithTexture:textureHelmClosed];
        nodeHelmClosed.anchorPoint = CGPointMake(0, 0);
        nodeHelmClosed.position = CGPointMake(0, panel.size.height + 0);
        
        //
        SKCropNode *cropNode = [SKCropNode new];
        cropNode.position = CGPointMake(0, 0);

        SKSpriteNode *mask = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(self.size.width, self.size.height)];
        mask.anchorPoint = CGPointMake(0, 0);
        mask.position = CGPointMake(0, mask.position.y + 225);
        
        [cropNode setMaskNode:mask];
        
        [cropNode addChild:nodeHelmClosed];
        [rootNode addChild:cropNode];
        
        
        [self startBackgroundMusic];
        
        SKAction* blinzelSequence = [SKAction sequence:@[
                              [SKAction waitForDuration:4.5],
                              [SKAction setTexture:textureHelmBlinzel],
                              [SKAction waitForDuration:0.10],
                              [SKAction setTexture:textureHelmNormal]
                                ]
                              ];
        
        [picNode runAction:blinzelSequence];
        
        SKAction* hemlDownSequence = [SKAction sequence:@[
                                                         [SKAction waitForDuration:5.2],
                                                         [SKAction moveByX:0 y:-100 duration:0.84],
                                                         ]
                                     ];
        
        [mask runAction:hemlDownSequence];
        
        // Sterne
        

        atlasStars = [SKTextureAtlas atlasNamed:@"HelmStar"];
        for(int i = 0; i < numStars; i++)
        {
            textureStars[i] = [atlasStars textureNamed: [NSString stringWithFormat:@"HelmStar_%d.PNG", i]];
        }
        
        SKSpriteNode *star = [SKSpriteNode spriteNodeWithTexture:textureStars[7]];
        //star.texture = textureStars[4];
        star.position = CGPointMake(146, 140-8);
        star.zPosition = 190;
        
     
        
        SKAction* starAnim = [SKAction animateWithTextures:@[
                                                             textureStars[7],
                                                             textureStars[6],
                                                             textureStars[5],
                                                             textureStars[4],
                                                             textureStars[3],
                                                             textureStars[2],
                                                             textureStars[1],
                                                             textureStars[0]
                                                        
                                                             ]
                                              timePerFrame:0.8/8];
        
        
        SKAction* sequence = [SKAction sequence: @[
                                                   [SKAction waitForDuration:0.6],
                                                   starAnim,
                                                   [SKAction runBlock:^{star.hidden = YES;}],
                                                   [SKAction waitForDuration:0.6],
                                                   
                                                   [SKAction moveTo:CGPointMake(274, 216-8) duration:0],
                                                   [SKAction setTexture:textureStars[7]],
                                                   [SKAction runBlock:^{star.hidden = NO;}],
                                                   starAnim,
                                                   [SKAction runBlock:^{star.hidden = YES;}],
                                                   [SKAction waitForDuration:0.6],
                                                   
                                                   [SKAction moveTo:CGPointMake(75, 156-8) duration:0],
                                                   [SKAction setTexture:textureStars[7]],
                                                   [SKAction runBlock:^{star.hidden = NO;}],
                                                   starAnim,
                                                   [SKAction runBlock:^{star.hidden = YES;}],
                                                   [SKAction waitForDuration:1.9],
                                                   
                                                   [SKAction moveTo:CGPointMake(190, 235-8) duration:0],
                                                   [SKAction setTexture:textureStars[7]],
                                                   [SKAction runBlock:^{star.hidden = NO;}],
                                                   starAnim,

                                                   [SKAction runBlock:^{star.hidden = YES;}],
                                                   [SKAction waitForDuration:2.0],
                                                   [SKAction runBlock:^{[self exitHelmScene];}]
                                                   
                                                   ]
                              ];
        
        
        [star runAction:sequence];

        [rootNode addChild:star];
        

    }
    
    NSLog(@"HelmScene end didMoveToView");
}


- (void)startBackgroundMusic
{
    NSError *err;
    NSURL *file = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"GetReady.wav" ofType:nil]];
    _backgroundAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:&err];
    if (err) {
        NSLog(@"error in audio play %@",[err userInfo]);
        return;
    }
    [_backgroundAudioPlayer prepareToPlay];
    

    _backgroundAudioPlayer.numberOfLoops = 0;
    [_backgroundAudioPlayer setVolume:0.5];
    [_backgroundAudioPlayer play];
}


// wird gerufen wenn Display berührt wird.

- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSSet *allTouches = [event allTouches];
    CGPoint touchLocation;
    
    float viewHeight;

    for (UITouch *touch in allTouches)
    {
        touchLocation = [touch locationInView:touch.view];
        touchLocation = [self convertPointFromView: touchLocation];     // null-punkt unten links
        viewHeight = touch.view.bounds.size.height;
        NSLog(@"touchesBegan %f, %f", touchLocation.x, touchLocation.y);
        [self exitHelmScene];
        break;
    }
}

-(void) exitHelmScene{
    [rootNode removeAllActions];
    [_backgroundAudioPlayer stop];
    
  //  [button removeFromSuperview];
  //  [title removeFromSuperview];
    
    [game endHelmScene];
}

// wird z.B. gerufen wenn incoming call oder homebutton event kommt.
-(void) pause{
    
    
    [_backgroundAudioPlayer stop];
    
    NSLog(@"HelmScene: pause");
}

// wird z.B. gerufen wenn wir aus dem Background geholt werden
-(void) resume{
    
    [_backgroundAudioPlayer play];
    NSLog(@"HelmScene: resume");
}

-(void) gameControllerButtonPressed{
    NSLog(@"HelmScene: gameControllerButtonPressed");
    if(game.mFi.rightShoulder | game.mFi.buttonA)
    {
        game.mFi.rightShoulder = NO;
        game.mFi.buttonA = NO;
        [self exitHelmScene];
    }
}

@end
