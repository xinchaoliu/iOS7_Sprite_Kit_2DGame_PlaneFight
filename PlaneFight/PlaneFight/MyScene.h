//
//  MyScene.h
//  MyPlaneGame
//

//  Copyright (c) 2013 Xinchao Liu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>

static const uint8_t bulletCategory = 1;
static const uint8_t enemyCategory = 2;
static const uint8_t planeCategory = 3;

@interface MyScene : SKScene <UIAccelerometerDelegate,
                              SKPhysicsContactDelegate>

@property SKSpriteNode * plane;
@property SKSpriteNode * background;
@property SKSpriteNode * planeShadow;
@property SKSpriteNode * propeller;
@property SKSpriteNode * enemy;
@property SKSpriteNode * enemyPropeller;
@property SKSpriteNode * bullet;
@property SKSpriteNode * cloud;
@property SKEmitterNode * smokeTrail;
@property SKEmitterNode * enemySmokeTrail;
@property (strong, nonatomic) CMMotionManager * motionManager;
@property double currentMaxAccelX;
@property double currentMaxAccelY;
@property NSMutableArray * explosionTextures;
@property NSMutableArray * cloudsTextures;

@end
