//
//  MyScene.m
//  MyPlaneGame
//
//  Created by Xinchao Liu on 10/14/13.
//  Copyright (c) 2013 Xinchao Liu. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        //init several sizes used in all scene
        screenHeight = self.frame.size.height;
        screenWidth = self.frame.size.width;
        self.backgroundColor = [SKColor blackColor];
        
        //adding the airplane
        _plane = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 8 N"];
        _plane.scale = 0.6;
        _plane.zPosition = 2;
        _plane.position = CGPointMake(screenWidth / 2,
                                      15 + _plane.size.height / 2);
        [self addChild:_plane];
        
        //adding the airplane shadow
        _planeShadow = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 8 SHADOW"];
        _planeShadow.scale = 0.6;
        _planeShadow.zPosition = 1;
        _planeShadow.position = CGPointMake(screenWidth / 2 + 15,
                                            0 + _planeShadow.size.height / 2);
        [self addChild:_planeShadow];
        
        //adding the propeller animation
        _propeller = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE PROPELLER 1"];
        _propeller.scale = 0.2;
        _propeller.zPosition = 2;
        _propeller.position = CGPointMake(screenWidth / 2,
                                          _plane.size.height + 10);
        SKTexture * propeller1 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 1"];
        SKTexture * propeller2 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 2"];
        SKAction * spin = [SKAction animateWithTextures:@[propeller1,
                                                          propeller2]
                                           timePerFrame:0.1];
        SKAction * spinForever = [SKAction repeatActionForever:spin];
        [_propeller runAction:spinForever];
        [self addChild:_propeller];
        
        //adding the background
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"airPlanesBackground"];
        _background.scale = 1.2;
        _background.position = CGPointMake(CGRectGetMidX(self.frame),
                                           CGRectGetMidY(self.frame));
        [self addChild:_background];
        
        //CoreMotion
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = 0.2;
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData * accelerometerData,
                                                               NSError * error) {
                                                     [self outputAccelertionData:accelerometerData.acceleration];
                                                     if (error) {
                                                         NSLog(@"%@", error);
                                                     }
                                                 }];
        
    }
    return self;
}

-(void)outputAccelertionData:(CMAcceleration)acceleration {
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    if (fabs(acceleration.x) > fabs(currentMaxAccelX)) {
        currentMaxAccelX = acceleration.x;
    }
    if (fabs(acceleration.y) > fabs(currentMaxAccelY)) {
        currentMaxAccelY = acceleration.y;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)update:(CFTimeInterval)currentTime {
    float maxX = screenWidth - _plane.size.width / 2;
    float minX = _plane.size.width / 2;
    float maxY = screenHeight - _plane.size.height / 2;
    float minY = _plane.size.height / 2;
    float newX = 0;
    float newY = 0;
    if (currentMaxAccelX > 0.05) {
        newX = currentMaxAccelX * 10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 R"];
    } else if (currentMaxAccelX < -0.05) {
        newX = currentMaxAccelX * 10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 L"];
    } else {
        newX = currentMaxAccelX * 10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 N"];
    }
    newY = 7.5 + currentMaxAccelY * 10;
    float newXshadow = newX + _planeShadow.position.x;
    float newYshadow = newY + _planeShadow.position.y;
    newXshadow = MIN(MAX(newXshadow,
                         minX + 15),
                     maxX + 15);
    newYshadow = MIN(MAX(newYshadow,
                         minY - 15),
                     maxY - 15);
    float newXpropeller = newX + _propeller.position.x;
    float newYpropeller = newY + _propeller.position.y;
    newXpropeller = MIN(MAX(newXpropeller,
                            minX),
                        maxX);
    newYpropeller = MIN(MAX(newYpropeller,
                            minY + (_plane.size.height / 2) - 5),
                        maxY + (_plane.size.height / 2) - 5);
    newX = MIN(MAX(newX + _plane.position.x,
                   minX),
               maxX);
    newY = MIN(MAX(newY + _plane.position.y,
                   minY),
               maxY);
    _plane.position = CGPointMake(newX,
                                  newY);
    _planeShadow.position = CGPointMake(newXshadow,
                                        newYshadow);
    _propeller.position = CGPointMake(newXpropeller, newYpropeller);
    
}

@end
