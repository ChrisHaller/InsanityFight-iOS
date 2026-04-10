//
//  MFi.h
//  Insanity Fight
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import <GameController/GameController.h>
#import "iCadeReaderView.h"


@interface MFi : NSObject{
    
}



@property (nonatomic, assign) BOOL controllerConnected;
@property (nonatomic, strong) GCController * gameController;



@property BOOL leftShoulder;
@property BOOL rightShoulder;
@property BOOL upDpad;
@property BOOL downDpad;
@property BOOL leftDpad;
@property BOOL rightDpad;
@property BOOL buttonA;
@property BOOL buttonB;
@property BOOL buttonX;
@property BOOL buttonY;
@property BOOL leftThumbstickUp;
@property BOOL leftThumbstickDown;
@property BOOL leftThumbstickLeft;
@property BOOL leftThumbstickRight;

@property BOOL rightThumbstickUp;
@property BOOL rightThumbstickDown;
@property BOOL rightThumbstickLeft;
@property BOOL rightThumbstickRight;
@property BOOL leftTrigger;
@property BOOL rightTrigger;

-(void)iCadeButtonDown:(iCadeState)button;
-(void)iCadeButtonUp:(iCadeState)button;

@end
