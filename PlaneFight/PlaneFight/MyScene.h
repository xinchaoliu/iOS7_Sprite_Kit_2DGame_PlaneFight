//
//  MyScene.h
//  MyPlaneGame
//

//  Copyright (c) 2013 Xinchao Liu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>

@interface MyScene : SKScene <UIAccelerometerDelegate> {
    CGFloat screenHeight;
    CGFloat screenWidth;
    double currentMaxAccelX;
    double currentMaxAccelY;
}

@property SKSpriteNode * plane;
@property SKSpriteNode * background;
@property SKSpriteNode * planeShadow;
@property SKSpriteNode * propeller;
@property (strong, nonatomic) CMMotionManager * motionManager;

@end
