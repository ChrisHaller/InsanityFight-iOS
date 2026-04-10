//
//  HighScoreScene.m
//
//  Created and Copyright (c) 2014–2026 Christian Haller
//  This file is part of Insanity Fight.
//  Released under the GNU General Public License v3.0 or later.
//  See the LICENSE file for details.
//

#import "HighScoreScene.h"
#import "Panel.h"
#import "constants.h"
#import "HighScoreManager.h"

#define NUM_CHARS_IN_FONT 128
#define NUM_X_CHARS 16
#define MAX_NAME_LEN 5

#define FONT_PIXEL_SIZE 8

@interface HighScoreScene() {
    
    SKNode* rootNode;
    SKNode* textNode;
    Panel* panel;
    NSMutableArray* textArrayEnterName;
    NSMutableArray* fontArray;
    NSMutableArray* textArray;
    NSMutableArray* textArrayEnterNameInput;    // hier wird der Name eingetragen welchen der Benutzer eingibt
    UIPanGestureRecognizer *gestureRecognizer;
    NSTimer* durationTimer;
    bool scrollLock;
    BOOL _shootLock;
}

@property BOOL contentCreated;


@end

@implementation HighScoreScene
    
@synthesize game;
@synthesize newHighScore;

#define NUM_CHARS_IN_ASCII_TABLE 0x80

char asciTable[] = {
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   // 0x00
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   // 0x10
    32, 33, 34, -1, -1, -1, -1, -1, -1, -1, -1, 43, -1, 45, 46, -1,   // 0x20 SP ! "" # $ % & ' ( ) * + , - . /
    48, 49, 50, 51, 52, 53, 54, 5, 56, 57, -1, -1, -1, -1, -1, -1,   // 0x30 0 1 2 3 4 5 6 7 8 9 : ; < = > s?
    -1,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,   // 0x40 @ A B C D E F G H I J K L M N O
    16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, -1, -1, -1, -1, -1,   // 0x50 P Q R S T U V W X Y Z [ \ ] ^ _
    -1,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,   // 0x60 ` a b c d e f g h i j k l m n o
    16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, -1, -1, -1, -1, -1,   // 0x70 p q r s t u v w x y z { | } ~	DEL
};



- (void)printHighScoreList
{
    [self print:@"    HI-SCORES" atLine:0 textArray:textArray];
    
    for(int i = 0; i < [game.highScoreManager count]; i++)
    {
        HighScoreEntry* entry = [game.highScoreManager playerAtIndex:i];
        if(entry.name.length > MAX_NAME_LEN)
        {
            entry.name = [entry.name substringToIndex:MAX_NAME_LEN - 1];
        }
        
        if(entry.name.length < MAX_NAME_LEN)
        {
            entry.name = [entry.name stringByPaddingToLength:MAX_NAME_LEN withString:@" " startingAtIndex:0];
        }
        
        
        NSString* formatString = [NSString stringWithFormat:@"%02d.%@ %06d", i + 1, entry.name, entry.score];
        [self print:formatString atLine:i + 2 textArray:textArray];
    }
}

- (void)didMoveToView:(SKView *)view
{
    NSLog(@"TitleScene didMoveToView");
    if (!self.contentCreated)
    {
        self.contentCreated = YES;
        
        bool landScapeMode = NO;
        int yOffset = 0;
        UIDeviceOrientation orientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
        if (UIDeviceOrientationIsLandscape(orientation))
        {
            landScapeMode = YES;
        }

        
        
        self.backgroundColor = [SKColor blackColor];
        self.scaleMode = SKSceneScaleModeAspectFit;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        
        // RootNode an welchem wir ALLES weitere anhängen. Dadurch müssen wir z.B. nur in einem einzigen Node die Grösse ändern wenn wir das mal tun wollen.
        
        rootNode = [[SKNode alloc] init];
        [self addChild:rootNode];
        
        // TextNode (dient zum Scrollen des Textes)
        textNode = [[SKNode alloc] init];
        [rootNode addChild:textNode];

        // panel hinzufügen
        panel = [Panel new];
        if(!landScapeMode)          // im Landscape Mode müssen wir Platz sparen --> kein Panel
        {
            [panel addPanelToNode:rootNode];
        }
        else
        {
            yOffset = 83;
        }
        panel.highScore = game.highScore;
        panel.score = game.score;

        
        // Font laden
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"font"];
        
        fontArray = [[NSMutableArray alloc] init];
        SKTexture* texture;
        for(int i = 0; i < NUM_CHARS_IN_FONT; i++)
        {
            texture = [atlas textureNamed: [NSString stringWithFormat:@"font_%d.PNG", i]];
            
            [fontArray addObject:texture];
        }
        
        
        // TextSprites
        int textY = 204 - yOffset;
        textArray   = [NSMutableArray new];
        SKColor *textColor =  [SKColor whiteColor];  // [Game colorFromHexString:@"#22cc11"];
        
        
        for(int y = 0; y < [game.highScoreManager count] + 2; y++)
        {
            int textX = 102;
            for(int x = 0; x < NUM_X_CHARS; x++)
            {
                
                SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:fontArray[32]];
                node.position = CGPointMake(textX, textY);
                node.zPosition = Z_POSITION_HIGHSCORE_TEXT;
                node.size = CGSizeMake(FONT_PIXEL_SIZE, FONT_PIXEL_SIZE);
                node.color = textColor;
                node.colorBlendFactor = 1.0;
                [textNode addChild:node];
                [textArray addObject:node];
                textX += FONT_PIXEL_SIZE;
            }
            textY -= FONT_PIXEL_SIZE + 6;
        }
        

        
        // Helm-Pic
        
        SKTexture* textureHelmNormal = [SKTexture textureWithImageNamed:@"HelmPic4.png"];
        SKSpriteNode *picNode = [SKSpriteNode spriteNodeWithTexture:textureHelmNormal];
        picNode.anchorPoint = CGPointMake(0,0);
        picNode.position = CGPointMake(0, panel.size.height - yOffset);
        picNode.zPosition = Z_POSITION_HIGHSCORE_HELM_PIC;
        [rootNode addChild:picNode];
    
        [self printHighScoreList];
        
        // gestures
        gestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [gestureRecognizer setDelegate:self];
        [self.view addGestureRecognizer:gestureRecognizer];
        
        
        // black mask
        SKSpriteNode *blackNode = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(330,500)];
        blackNode.anchorPoint = CGPointMake(0,0);
        blackNode.position = CGPointMake(0, (panel.size.height - yOffset) + picNode.size.height);
        blackNode.zPosition = Z_POSITION_HIGHSCORE_BLACK_MASK;
        [rootNode addChild:blackNode];
        


        // wenn es einen neuen Highscore gibt, zeigen wir zusätzliche Dinge an
        if(game.newHighScore)
        {
            scrollLock = YES;           // scrollen sperren
            game.newHighScore = NO;     // dafür sorgen, dass beim nächsten Aufruf nicht nochmal nach dem Namen gefragt wird.
            
            // [game.iCadeReaderView removeFromSuperview];
            game.iCadeReaderView.active = NO;                   // ruft u.a. resignFirstResponder
            //[game.iCadeReaderView resignFirstResponder];        // eigentlich unnötig. aber ohne diese Zeile erscheint virtuelles KB nicht.
            
            // TextSprites für dex Text "Enter Name"
            textY = 320 - yOffset;
            textArrayEnterName   = [NSMutableArray new];
            textColor =  [SKColor whiteColor];
            
            for(int y = 0; y < 3; y++)
            {
                int textX = 105;
                for(int x = 0; x < NUM_X_CHARS; x++)
                {
                    SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:fontArray[32]];
                    node.position = CGPointMake(textX, textY);
                    node.zPosition = Z_POSITION_HIGHSCORE_ENTER_NAME_TEXT;
                    node.size = CGSizeMake(FONT_PIXEL_SIZE, FONT_PIXEL_SIZE);
                    node.color = textColor;
                    node.colorBlendFactor = 1.0;
                    [textNode addChild:node];
                    [textArrayEnterName addObject:node];
                    textX += FONT_PIXEL_SIZE;
                }
                textY -= FONT_PIXEL_SIZE + 6;
            }
            [self print:@"!NEW HIGHSCORE!" atLine:0 textArray:textArrayEnterName];
            [self print:@"ENTER YOUR NAME" atLine:1 textArray:textArrayEnterName];


            // TextSprites für dex Usernamen welchen der Benutzer eingibt
            textY = 280 - yOffset;
            textArrayEnterNameInput = [NSMutableArray new];
            textColor =  [SKColor whiteColor];
            

            int textX = 145;
            for(int x = 0; x < NUM_X_CHARS; x++)
            {
                SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:fontArray[32]];
                node.position = CGPointMake(textX, textY);
                node.zPosition = Z_POSITION_HIGHSCORE_ENTER_NAME_TEXT;
                node.size = CGSizeMake(FONT_PIXEL_SIZE, FONT_PIXEL_SIZE);
                node.color = textColor;
                node.colorBlendFactor = 1.0;
                [textNode addChild:node];
                [textArrayEnterNameInput addObject:node];
                textX += FONT_PIXEL_SIZE;
            }

            [self print:@"....." atLine:0 textArray:textArrayEnterNameInput];
 


 

            // unsichtbares Textfeld. Es ist unsichtbar, damit ich den Text mit dem eigenen Font (C-64!) anzeigen kann und damit es keinen Mix zwischen SKScene Koordinaten und UI Koordinaten gibt.
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
            
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.font = [UIFont systemFontOfSize:12];
            textField.placeholder = @"";
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.returnKeyType = UIReturnKeyDone;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.backgroundColor = [SKColor blackColor];
            textField.textColor = [SKColor blackColor];         // unsichtbar
            textField.tintColor = [SKColor blackColor];
            
            textField.delegate = self;
            textField.textAlignment = NSTextAlignmentCenter;
            
            [self.view addSubview:textField];
            [textField becomeFirstResponder];
        }
        else
        {
            
            // kein neuen HighScore. Timer starten
            durationTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_HIGHSCORE_DURATION target:self selector:@selector(durationTimerFired:) userInfo:Nil repeats:NO];

        }
        
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // KLEINBUCHSTABEN IN GROSSBUCHSTABEN KONVERTIEREN
    
    // thanks to Nicolas Bachschmidt (see http://stackoverflow.com/questions/9126709/create-uitextrange-from-nsrange)
    UITextPosition *beginning = textField.beginningOfDocument;
    UITextPosition *start = [textField positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [textField positionFromPosition:start offset:range.length];
    UITextRange *textRange = [textField textRangeFromPosition:start toPosition:end];
    
    // alle Sonderzeichen und Umlaute ruasfiltern
    if(string.length > 0)
    {
        unsigned char c = [string characterAtIndex:0];
        if(c > 127)
        {
            return NO;
        }
    }
    
    
    
    
    // replace the text in the range with the upper case version of the replacement string
    [textField replaceRange:textRange withText:[string uppercaseString]];
    
    
    // Länge auf 5 Zeichen begrenzen
    if(textField.text.length > MAX_NAME_LEN)
    {
        textField.text = [textField.text substringToIndex: MAX_NAME_LEN];
    }
    [self print:@"     " atLine:0 textArray:textArrayEnterNameInput];
    [self print:textField.text atLine:0 textArray:textArrayEnterNameInput];

    
    // don't change the characters automatically
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

// neuer Name wurde eingegeben
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(textField.text.length > 0)
    {
        [textField resignFirstResponder];
        [textField removeFromSuperview];
        [game.highScoreManager addPlayer:textField.text withScore:newHighScore];
        [self printHighScoreList];
        [game.highScoreManager saveHighScore];
        newHighScore = 0;
        
        // "Enter your Name" - Text löschen
        [self print:@"               " atLine:0 textArray:textArrayEnterName];
        [self print:@"               " atLine:1 textArray:textArrayEnterName];
        [self print:@"     " atLine:0 textArray:textArrayEnterNameInput];
        scrollLock = NO;
        return YES;
    }
    else
    {
        return NO;
    }
}


-(void) durationTimerFired:(NSTimer*) timer{
    NSLog(@"HighScoreScene: durationTimerFired");
    [self exitHighScoreScene];
}



- (void)pan:(UIPanGestureRecognizer *)recognizer{

    if(!scrollLock)     // scrollen ist während der EIngabe des Benutzername (neuer HighScore) gesperrt
    {
        
        // Timeout neu setzen (bei jeder Bewegung)
        [durationTimer invalidate];
        durationTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_HIGHSCORE_DURATION target:self selector:@selector(durationTimerFired:) userInfo:Nil repeats:NO];
        
        
        CGPoint translation = [recognizer translationInView:self.view];
        
        textNode.position = CGPointMake(textNode.position.x, textNode.position.y - (translation.y) / 2);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        
        if(textNode.position.y < 0)
        {
            textNode.position = CGPointMake(textNode.position.x, 0);
        }
        
        int maxY = (HIGHSCORE_MAX_ENTRIES - 2) * 14;
        
        if(textNode.position.y > maxY)
        {
            textNode.position = CGPointMake(textNode.position.x, maxY);
        }
    }
}


-(void)print:(NSString*) text atLine: (uint) line textArray:(NSMutableArray*) textSprites{
    int offset = line * NUM_X_CHARS;
    int textLen = (int)[text length];
    unsigned char currentChar = -1;
    for(int i = 0; i < textLen; i++)
    {
        SKSpriteNode* charSprite = textSprites[offset + i];
        currentChar = [text characterAtIndex:i];
        if(currentChar < NUM_CHARS_IN_ASCII_TABLE)
        {
            int charIndex = asciTable[currentChar];
            if(charIndex != -1)
            {
                SKTexture* charTexture = fontArray[charIndex];
                [charSprite setTexture:charTexture];
                charSprite.size = CGSizeMake(8, 8);
            }
            else
            {
                // @todo evtl.
                //[charSprite setTexture:emptyTexture];
            }
        }
    }
}


// wird gerufen wenn Display berührt wird.
- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    
    NSSet *allTouches = [event allTouches];
    for (UITouch *touch in allTouches)
    {
        CGPoint touchLocation = [touch locationInView:touch.view];
        touchLocation = [self convertPointFromView: touchLocation];     // null-punkt unten links
        
        if(touchLocation.y > 280)
        {
            if(!scrollLock)         // nicht beenden wenn Texteingabe aktiv ist
            {
                [self exitHighScoreScene];
            }
            break;
        }
        
    }
}



-(void) exitHighScoreScene{
    [durationTimer invalidate];
    [rootNode removeAllActions];
    [self.view removeGestureRecognizer:gestureRecognizer];
    [gestureRecognizer removeTarget:Nil action:NULL];
    game.iCadeReaderView.active = YES;
    [game endHighScoreScene];
}

// wird z.B. gerufen wenn incoming call oder homebutton event kommt.
-(void) pause{
    NSLog(@"HighScoreScene: pause");
}

// wird z.B. gerufen wenn wir aus dem Background geholt werden
-(void) resume{
    NSLog(@"HighScoreScene: resume");
}

-(void) gameControllerButtonPressed{
    NSLog(@"HighScoreScene: gameControllerButtonPressed");
    if(game.mFi.rightShoulder | game.mFi.buttonA)
    {
        game.mFi.rightShoulder = NO;
        game.mFi.buttonA = NO;
        [self exitHighScoreScene];
    }
}

@end
