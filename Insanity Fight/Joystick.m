//
//  Joystick.m
//  SpriteWalkthrough
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import "Joystick.h"
#import "Game.h"
#import "constants.h"
#import "AppDelegate.h"


@implementation Joystick{

    SKNode* _parentNode;
}

#define ALPHA_NORMAL 0.2
#define ALPHA_HOVERED 0.5


-(id)init
{
    self = [super init];
    if (self) {
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Joystick"];
        
        float alpha = 0.2;
        
        _arrowLeft = [SKSpriteNode spriteNodeWithTexture: [atlas textureNamed:@"pfeil%20links.png"]];
        _arrowRight = [SKSpriteNode spriteNodeWithTexture: [atlas textureNamed:@"pfeil%20rechts.png"]];
        
        _arrowUp = [SKSpriteNode spriteNodeWithTexture: [atlas textureNamed:@"pfeil_up.png"]];
        _arrowDown = [SKSpriteNode spriteNodeWithTexture: [atlas textureNamed:@"pfeil_down.png"]];
        
        _arrowLeft.zPosition = Z_POSITION_JOYSTICK_ELEMENTS;
        _arrowRight.zPosition = Z_POSITION_JOYSTICK_ELEMENTS;
        
        _arrowUp.zPosition = Z_POSITION_JOYSTICK_ELEMENTS;
        _arrowDown.zPosition = Z_POSITION_JOYSTICK_ELEMENTS;
        

        _arrowLeft.alpha = alpha;
        _arrowRight.alpha = alpha;
        _arrowUp.alpha = alpha;
        _arrowDown.alpha = alpha;
        
        
        _fireButton = [SKSpriteNode spriteNodeWithTexture: [atlas textureNamed:@"Fire.png"]];
        _fireButton.zPosition = Z_POSITION_JOYSTICK_ELEMENTS;
        _fireButton.alpha = 0.4;
        
        _fireButton.xScale = 0.5;
        _fireButton.yScale = 0.5;
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        switch (delegate.game.steeringMode) {

            case SteeringMode_Accelerometer:
                _fireButton.position = CGPointMake(280, 120);
                _fireButton.xScale = 0.2;
                _fireButton.yScale = 0.2;
                //arrowLeft.position = CGPointMake(20, 104);
                //arrowRight.position = CGPointMake(70, 104);
                
                _arrowLeft.hidden = YES;
                _arrowRight.hidden = YES;
                
                _arrowDown.position = CGPointMake(22, 104);
                _arrowUp.position = CGPointMake(20, 150);
                break;
                

            case SteeringMode_TwoFingers:
                _fireButton.position = CGPointMake(280, 120);
                _fireButton.xScale = 0.2;
                _fireButton.yScale = 0.2;
                _arrowLeft.position = CGPointMake(20, 104);
                _arrowRight.position = CGPointMake(70, 104);
                _arrowDown.position = CGPointMake(20, 145);
                _arrowUp.position = CGPointMake(70, 145);
                break;
            
                
            case SteeringMode_MFi:
                _arrowLeft.hidden = YES;
                _arrowRight.hidden = YES;
                _arrowUp.hidden = YES;
                _arrowDown.hidden = YES;
                _fireButton.hidden = YES;
                break;
                
            default:
                _fireButton.position = CGPointMake(320/2, 300);
                _arrowLeft.position = CGPointMake(20, 104);
                _arrowRight.position = CGPointMake(300, 104);
                _arrowUp.position = CGPointMake(300, 185);
                _arrowDown.position = CGPointMake(20, 185);
                break;
        }


        
    
    
    }
    return self;
}

-(void)removeAll{
    [_fireButton removeFromParent];
    [_arrowDown removeFromParent];
    [_arrowUp removeFromParent];
    [_arrowLeft removeFromParent];
    [_arrowRight removeFromParent];
    
    _fireButton = nil;
    _arrowDown = nil;
    _arrowLeft = nil;
    _arrowRight = nil;
    _arrowUp  = nil;
    
    
}


-(void) addFireButton{
    [_parentNode addChild:_fireButton];
    
    // In Version 1.0 war der FireButton hovering. In V1.1 entfernt.
    /*
    SKAction* actionHover = [SKAction sequence:@[
                                                 [SKAction fadeAlphaTo:0.4 duration:1.0],
                                                 [SKAction fadeAlphaTo:0.1 duration:1.0]
                                                 ]];
    
    [_fireButton runAction:[SKAction repeatActionForever:actionHover]];
    */
}

-(void) stopFireButtonHover{
    [_fireButton removeAllActions];
    SKAction* actionHover = [SKAction sequence:@[
                                                 [SKAction fadeAlphaTo:0.2 duration:1.0],
                                                 ]];
    
    [_fireButton runAction:actionHover];
}

// FireButton wird nur noch ganz schwach angezeigt (in Version 1.0 wurde er ganz entfernt)
-(void) removeFireButton{
    [_fireButton removeAllActions];
    SKAction* actionHover = [SKAction sequence:@[
                                                 [SKAction fadeAlphaTo:0.1 duration:2.0],
                                                 //[SKAction removeFromParent]
                                                 ]];
    
    [_fireButton runAction:actionHover];
    
}

-(void) addToNode:(SKNode*) node{
    
    _parentNode = node;
    [node addChild:_arrowRight];
    [node addChild:_arrowLeft];
 
    [node addChild:_arrowUp];
    [node addChild:_arrowDown];
    
    
    
}

-(void) hoverUpLeft:(BOOL) left right:(BOOL) right up:(BOOL) up down:(BOOL) down{
    
    SKAction* actionHover = [SKAction sequence:@[
                                                 [SKAction fadeAlphaTo:ALPHA_HOVERED duration:0.1],
                                                 ]];
    
    if(left)
    {
       [_arrowLeft runAction:actionHover];
    }
    
    if(right)
    {
        [_arrowRight runAction:actionHover];
    }
    
    
    if(up)
    {
        [_arrowUp runAction:actionHover];
    }
    
    
    if(down)
    {
        [_arrowDown runAction:actionHover];
    }
}

-(void) hoverDownLeft:(BOOL) left right:(BOOL) right up:(BOOL) up down:(BOOL) down{
    
    SKAction* actionHover = [SKAction sequence:@[
                                                 [SKAction fadeAlphaTo:ALPHA_NORMAL duration:0.1]
                                                 ]];
    
    if(left)
    {
        [_arrowLeft runAction:actionHover];
    }
    
    if(right)
    {
        [_arrowRight runAction:actionHover];
    }
    
    
    if(up)
    {
        [_arrowUp runAction:actionHover];
    }
    
    
    if(down)
    {
        [_arrowDown runAction:actionHover];
    }
}


@end
