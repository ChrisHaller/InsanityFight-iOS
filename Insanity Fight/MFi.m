//
//  MFi.m
//  Insanity Fight
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import "MFi.h"
#import "AppDelegate.h"


@implementation MFi{
    BOOL _shootLock;
    BOOL _buttonShoot;
    BOOL _leftShoulderLastValue;
    BOOL _rightShoulderLastValue;
    BOOL _upDpadLastValue;
    BOOL _downDpadLastValue;
    BOOL _leftDpadLastValue;
    BOOL _rightDpadLastValue;
    BOOL _buttonALastValue;
    BOOL _buttonBLastValue;
    BOOL _buttonXLastValue;
    BOOL _buttonYLastValue;
    BOOL _leftThumbstickUpLastValue;
    BOOL _leftThumbstickDownLastValue;
    BOOL _leftThumbstickLeftLastValue;
    BOOL _leftThumbstickRightLastValue;
    BOOL _rightThumbstickUpLastValue;
    BOOL _rightThumbstickDownLastValue;
    BOOL _rightThumbstickLeftLastValue;
    BOOL _rightThumbstickRightLastValue;
    BOOL _leftTriggerLastValue;
    BOOL _rightTriggerLastValue;
    iCadeReaderView* _iCadeReaderView;

    Game* _game;
    
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _game = app.game;
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerStateChanged) name:GCControllerDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerStateChanged) name:GCControllerDidDisconnectNotification object:nil];
        
        /*
        [GCController startWirelessControllerDiscoveryWithCompletionHandler:^{
            [self controllerStateChanged];
         
            
        }];
        */
    }
    return self;
}

-(Game*) game{
    return _game;
}


// wird gerufen wenn ein MFI-Controller getrennt oder verbunden wird. Wenn mehrere Controller gleichzeitig verbunden sind, wird gemäss Apples Vorgaben der idealste verwendet.

-(void)controllerStateChanged {
    
    bool lastConnectState = self.controllerConnected;
    
    if ([[GCController controllers] count] > 0) {
        self.controllerConnected = YES;
        self.gameController = nil;
        
        // optimalen Controller suchen
        
        for (GCController* controller in [GCController controllers]) {
            if(controller.attachedToDevice)
            {
                // direkt verbundene haben immer Prioriät
                self.gameController = controller;
                NSLog(@"mfi game controller connected (attached)");
                break;
            }
            
            if(controller.extendedGamepad != nil)
            {
                // Controller mit extended Gamepad sind zweite Priorität
                // dieser wird aber nur gesetzt wenn nicht schon ein anderer Controller mit extended Gamepad gefunden wurde
                if(self.gameController != nil)
                {
                    if(self.gameController.extendedGamepad == nil){
                        self.gameController = controller;
                        NSLog(@"mfi game controller connected (extended profile, overriding controller with standard profile)");
                    }
                }
                else
                {
                    self.gameController = controller;
                    NSLog(@"mfi game controller connected (extended profile)");
                    
                }
            }
            
            if(controller.extendedGamepad == nil)
            {
                // Controller mit Standardprofile verwenden wir nur wenn es keine "besseren" gibt
                if(self.gameController == nil)
                {
                    self.gameController = controller;
                    NSLog(@"mfi game controller connected (standard profile)");
                }
            }
        }
        
        // handler setzen
        
        if(self.gameController.extendedGamepad != nil)
        {
            // extended gamepad
            
            __weak typeof(self) weakSelf = self;
            self.gameController.extendedGamepad.valueChangedHandler = ^(GCExtendedGamepad *gamepad, GCControllerElement *element) {
                [weakSelf updateExtendedGamePadProperties:gamepad controllerElement:element];
            };
            
            self.gameController.controllerPausedHandler = ^(GCController* controller){
                weakSelf.game.gamePaused = !weakSelf.game.gamePaused;
                NSLog(@"pause button pressed");
            };
            
        }
        else
        {
            // standard gamepad
            
            __weak typeof(self) weakSelf = self;
            self.gameController.gamepad.valueChangedHandler = ^(GCGamepad *gamepad, GCControllerElement *element) {
                [weakSelf updateGamePadProperties:gamepad controllerElement:element];
            };
            
            self.gameController.controllerPausedHandler = ^(GCController* controller){
                [weakSelf togglePauseMode];
            };
        }
    }
    else {
        self.controllerConnected = NO;
        self.gameController = nil;
        NSLog(@"no mfi game controller connected");
    }
    [_game setDefaultSteeringMode];
    
    if(self.controllerConnected != lastConnectState){
        //sobald ein MFi Controller getrennt oder verbunden wird, gehen wir in den Pausemodus (wirkt nur während dem eigentlichen Game)
        [self setPauseMode];
    }
    
    
    [_game.currentScene gameControllerChanged];
}

-(void)togglePauseMode{
    _game.gamePaused = _game.gamePaused;
    NSLog(@"pause button pressed");
}

-(void)setPauseMode{
    _game.gamePaused = YES;
    NSLog(@"pause button pressed");
}


-(void)updateExtendedGamePadProperties:(GCExtendedGamepad*) gamepad controllerElement:(GCControllerElement*) element {
    //  NSLog(@"MFi button pressed");
    
    // right trigger
    if (gamepad.rightTrigger == element){
        if(gamepad.rightTrigger.isPressed){
            self.rightTrigger = YES;
        }
        else{
            self.rightTrigger = NO;
        }
    }
    
    // left trigger
    if (gamepad.leftTrigger == element){
        if(gamepad.leftTrigger.isPressed){
            self.leftTrigger = YES;
        }
        else{
            self.leftTrigger = NO;
        }
    }
    
    // right shoulder
    if (gamepad.rightShoulder == element){
        if(_rightShoulderLastValue != gamepad.rightShoulder.isPressed)
        {
            _rightShoulderLastValue = gamepad.rightShoulder.isPressed;
            if(gamepad.rightShoulder.isPressed){
                NSLog(@"MFi rightShoulder button pressed");
                self.rightShoulder = YES;
            }
            else{
                self.rightShoulder = NO;
                NSLog(@"MFi rightShoulder button released");
            }
        }
    }
    
    
    // left shoulder
    if (gamepad.leftShoulder == element){
        if(gamepad.leftShoulder.isPressed){
            self.leftShoulder = YES;
        }
        else{
            self.leftShoulder = NO;
        }
        
    }
    
    
    // dpad
    if (gamepad.dpad == element){
        
        // right dpad
        if(gamepad.dpad.right.isPressed){
            self.rightDpad = YES;
            NSLog(@"set right dpad");
        }
        else{
            self.rightDpad = NO;
        }
        
        
        // left dpad
        if(gamepad.dpad.left.isPressed){
            self.leftDpad = YES;
            NSLog(@"set left dpad");
        }
        else{
            self.leftDpad = NO;
            NSLog(@"clear left dpad");
        }
        
        // up dpad
        if(gamepad.dpad.up.isPressed){
            self.upDpad = YES;
        }
        else{
            self.upDpad = NO;
        }
        
        // down dpad
        if(gamepad.dpad.down.isPressed){
            self.downDpad = YES;
        }
        else{
            self.downDpad = NO;
        }
    }
    
    // rightThumbstick
    if (gamepad.rightThumbstick == element){
        
        // rightThumbstickRight
        if(gamepad.rightThumbstick.right.isPressed){
            self.rightThumbstickRight = YES;
        }
        else{
            self.rightThumbstickRight = NO;
        }
        
        
        // rightThumbstickLeft
        if(gamepad.rightThumbstick.left.isPressed){
            self.rightThumbstickLeft = YES;
        }
        else{
            self.rightThumbstickLeft = NO;
        }
        
        // rightThumbstickUp
        if(gamepad.rightThumbstick.up.isPressed){
            self.rightThumbstickUp = YES;
        }
        else{
            self.rightThumbstickUp = NO;
        }
        
        // rightThumbstickDown
        if(gamepad.rightThumbstick.down.isPressed){
            self.rightThumbstickDown = YES;
        }
        else{
            self.rightThumbstickDown = NO;
        }
    }
    
    
    // leftThumbstick
    if (gamepad.leftThumbstick == element){
        
        // leftThumbstickRight
        if(gamepad.leftThumbstick.right.isPressed){
            self.leftThumbstickRight = YES;
        }
        else{
            self.leftThumbstickRight = NO;
        }
        
        
        // leftThumbstickRight
        if(gamepad.leftThumbstick.left.isPressed){
            self.leftThumbstickLeft = YES;
        }
        else{
            self.leftThumbstickLeft = NO;
        }
        
        // leftThumbstickUp
        if(gamepad.leftThumbstick.up.isPressed){
            self.leftThumbstickUp = YES;
        }
        else{
            self.leftThumbstickUp = NO;
        }
        
        // leftThumbstickDown
        if(gamepad.leftThumbstick.down.isPressed){
            self.leftThumbstickDown = YES;
        }
        else{
            self.leftThumbstickDown = NO;
        }
    }
    
    
    // button A
    if (gamepad.buttonA == element){
        
        if(_buttonALastValue != gamepad.buttonA.isPressed)
        {
            _buttonALastValue = gamepad.buttonA.isPressed;
            if(gamepad.buttonA.isPressed)
            {
                self.buttonA = YES;
            }
            else{
                self.buttonA = NO;
            }
        }
    }
    
    // button B
    if (gamepad.buttonB == element){
        if(gamepad.buttonB.isPressed){
            self.buttonB = YES;
        }
        else{
            self.buttonB = NO;
        }
    }
    
    // button X
    if (gamepad.buttonX == element){
        if(gamepad.buttonX.isPressed){
            self.buttonX = YES;
        }
        else{
            self.buttonX = NO;
        }
    }
    
    // button Y
    if (gamepad.buttonY == element){
        if(gamepad.buttonY.isPressed){
            self.buttonY = YES;
        }
        else{
            self.buttonY = NO;
        }
    }
    
    [_game.currentScene gameControllerButtonPressed];
    
}


-(void)updateGamePadProperties:(GCGamepad*) gamepad controllerElement:(GCControllerElement*) element {
    //  NSLog(@"MFi button pressed");
    
    
    // right shoulder
    if (gamepad.rightShoulder == element){
        if(_rightShoulderLastValue != gamepad.rightShoulder.isPressed)
        {
            _rightShoulderLastValue = gamepad.rightShoulder.isPressed;
            if(gamepad.rightShoulder.isPressed){
                NSLog(@"MFi rightShoulder button pressed");
                self.rightShoulder = YES;
            }
            else{
                self.rightShoulder = NO;
                NSLog(@"MFi rightShoulder button released");
            }
        }
        
    }
    
    
    // left shoulder
    if (gamepad.leftShoulder == element){
        if(gamepad.leftShoulder.isPressed){
            self.leftShoulder = YES;
        }
        else{
            self.leftShoulder = NO;
        }
        
    }
    
    
    // dpad
    if (gamepad.dpad == element){
        
        // right dpad
        if(gamepad.dpad.right.isPressed){
            self.rightDpad = YES;
            NSLog(@"set right dpad");
        }
        else{
            self.rightDpad = NO;
        }
        
        
        // left dpad
        if(gamepad.dpad.left.isPressed){
            self.leftDpad = YES;
            NSLog(@"set left dpad");
        }
        else{
            self.leftDpad = NO;
            NSLog(@"clear left dpad");
        }
        
        // up dpad
        if(gamepad.dpad.up.isPressed){
            self.upDpad = YES;
        }
        else{
            self.upDpad = NO;
        }
        
        // down dpad
        if(gamepad.dpad.down.isPressed){
            self.downDpad = YES;
        }
        else{
            self.downDpad = NO;
        }
    }
    
    
    // button A
    if (gamepad.buttonA == element){
        
        if(_buttonALastValue != gamepad.buttonA.isPressed)
        {
            _buttonALastValue = gamepad.buttonA.isPressed;
            if(gamepad.buttonA.isPressed)
            {
                self.buttonA = YES;
            }
            else{
                self.buttonA = NO;
            }
        }
    }
    
    // button B
    if (gamepad.buttonB == element){
        if(gamepad.buttonB.isPressed){
            self.buttonB = YES;
        }
        else{
            self.buttonB = NO;
        }
    }
    
    // button X
    if (gamepad.buttonX == element){
        if(gamepad.buttonX.isPressed){
            self.buttonX = YES;
        }
        else{
            self.buttonX = NO;
        }
    }
    
    // button Y
    if (gamepad.buttonY == element){
        if(gamepad.buttonY.isPressed){
            self.buttonY = YES;
        }
        else{
            self.buttonY = NO;
        }
    }
    
    [_game.currentScene gameControllerButtonPressed];
    
}

#pragma mark iCade

-(void)iCadeButtonDown:(iCadeState)button{
    NSLog(@"iCade buttonDown");
    
    // MFi-Steering einschalten/simulieren wenn iCade-Events kommen
    if(!_controllerConnected)
    {
        // MFi-Modus aktivieren (und danach emulieren)
        _controllerConnected = true;
        [_game setDefaultSteeringMode];
        [_game.currentScene gameControllerChanged];
    }
    


    if((button & iCadeButtonA) == iCadeButtonA)
    {
        self.rightShoulder = YES;
        _game.gamePaused = NO;       // Pausenmodus auflösen falls er aus irgendeinem Grund aktiviert war
        NSLog(@"iCade buttonDown A");
    }
    
    if((button & iCadeJoystickLeft) == iCadeJoystickLeft)
    {
        self.leftThumbstickLeft = YES;
        NSLog(@"iCade buttonDown left");

    }
    
    if((button & iCadeJoystickRight) == iCadeJoystickRight)
    {
        self.leftThumbstickRight = YES;
        NSLog(@"iCade buttonDown right");
    }
    
    
    if((button & iCadeJoystickUp) == iCadeJoystickUp)
    {
        self.leftThumbstickUp = YES;
        self.rightThumbstickUp = YES;
        NSLog(@"iCade buttonDown up");
    }
    
    
    if((button & iCadeJoystickDown) == iCadeJoystickDown)
    {
        self.leftThumbstickDown = YES;
        self.rightThumbstickDown = YES;
        NSLog(@"iCade buttonDown down");
    }
    [_game.currentScene gameControllerButtonPressed];
}

-(void)iCadeButtonUp:(iCadeState)button{
    NSLog(@"iCade buttonUp");
    
    if((button & iCadeButtonA) == iCadeButtonA)
    {
        self.rightShoulder = NO;
        NSLog(@"iCade buttonUp A");
    }
    
    if((button & iCadeJoystickLeft) == iCadeJoystickLeft)
    {
        self.leftThumbstickLeft = NO;
            NSLog(@"iCade buttonUp left");
    }
    
    if((button & iCadeJoystickRight) == iCadeJoystickRight)
    {
        self.leftThumbstickRight = NO;
            NSLog(@"iCade buttonUp right");
    }
    
    if((button & iCadeJoystickUp) == iCadeJoystickUp)
    {
        self.leftThumbstickUp = NO;
        self.rightThumbstickUp = NO;
        NSLog(@"iCade buttonUp up");
    }
    
    
    if((button & iCadeJoystickDown) == iCadeJoystickDown)
    {
        self.leftThumbstickDown = NO;
        self.rightThumbstickDown = NO;
        NSLog(@"iCade buttonUp down");
    }
    
    [_game.currentScene gameControllerButtonPressed];
}





@end
