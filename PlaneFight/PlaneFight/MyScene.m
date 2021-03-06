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
        
        self.backgroundColor = [SKColor blackColor];
        
        //adding the airplane
        _plane = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 8 N"];
        _plane.scale = 0.6;
        _plane.zPosition = 2;
        _plane.position = CGPointMake(self.frame.size.width / 2,
                                      15 + _plane.size.height / 2);
        [self addChild:_plane];
        
        //adding the airplane shadow
        _planeShadow = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 8 SHADOW"];
        _planeShadow.scale = 0.6;
        _planeShadow.zPosition = 1;
        _planeShadow.position = CGPointMake(self.frame.size.width / 2 + 10,
                                            5 + _planeShadow.size.height / 2);
        [self addChild:_planeShadow];
        
        //adding the propeller animation
        _propeller = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE PROPELLER 1"];
        _propeller.scale = 0.2;
        _propeller.zPosition = 2;
        _propeller.position = CGPointMake(self.frame.size.width / 2,
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
        
        //adding the smokeTrail
        NSString * smokePath = [[NSBundle mainBundle] pathForResource:@"trail"
                                                               ofType:@"sks"];
        _smokeTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
        _smokeTrail.position = CGPointMake(self.frame.size.width / 2,
                                           15);
        [self addChild:_smokeTrail];
        
        //schedule enemies
        SKAction * wait = [SKAction waitForDuration:1];
        SKAction * callEnemies = [SKAction runBlock:^{
            [self enemiesAndClouds];
        }];
        SKAction * updateEnimies = [SKAction sequence:@[wait,
                                                        callEnemies]];
        [self runAction:[SKAction repeatActionForever:updateEnimies]];
        
        //physics
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        //load explosions
        SKTextureAtlas * explosionAtlas = [SKTextureAtlas atlasNamed:@"Explosion"];
        NSArray * textureNamesExplosion = [explosionAtlas textureNames];
        _explosionTextures = [NSMutableArray new];
        for (NSString * name in textureNamesExplosion) {
            SKTexture * texture = [explosionAtlas textureNamed:name];
            [_explosionTextures addObject:texture];
        }
        
        //load clouds
        SKTextureAtlas * cloudsAtlas = [SKTextureAtlas atlasNamed:@"Clouds"];
        NSArray * textureNamesClouds = [cloudsAtlas textureNames];
        _cloudsTextures = [NSMutableArray new];
        for (NSString * name in textureNamesClouds) {
            SKTexture * texture = [cloudsAtlas textureNamed:name];
            [_cloudsTextures addObject:texture];
        }
        
    }
    return self;
}

-(void)outputAccelertionData:(CMAcceleration)acceleration {
    _currentMaxAccelX = 0;
    _currentMaxAccelY = 0;
    if (fabs(acceleration.x) > fabs(_currentMaxAccelX)) {
        _currentMaxAccelX = acceleration.x;
    }
    if (fabs(acceleration.y) > fabs(_currentMaxAccelY)) {
        _currentMaxAccelY = acceleration.y;
    }
}

-(void)enemiesAndClouds {
    //not always come
    int goOrNot = [self getRandomNumberBetween:0
                                            to:10];
    if (goOrNot > 0) {
        int randomEnemy = [self getRandomNumberBetween:0
                                                    to:1];
        if (randomEnemy == 0) {
            _enemy = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 1 N"];
        } else {
            _enemy = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 2 N"];
        }
        _enemy.scale = 0.6;
        _enemy.zPosition = 1;
        _enemy.position = CGPointMake(self.frame.size.width / 2,
                                      self.frame.size.height / 2);
        
        CGMutablePathRef cgPath = CGPathCreateMutable();
        //random values
        float xOfStartPoint = [self getRandomNumberBetween:0 + _enemy.size.width
                                                        to:self.frame.size.width - _enemy.size.width];
        float xOfEndPoint = [self getRandomNumberBetween:0 + _enemy.size.width
                                                      to:self.frame.size.width - _enemy.size.width];
        //controlPoint1
        float xOfControlPoint1 = [self getRandomNumberBetween:0 + _enemy.size.width
                                                           to:self.frame.size.width - _enemy.size.width];
        float yOfControlPoint1 = [self getRandomNumberBetween:0 + _enemy.size.height
                                                           to:self.frame.size.height - _enemy.size.height];
        //controlPoint2
        float xOfControlPoint2 = [self getRandomNumberBetween:0 + _enemy.size.width
                                                           to:self.frame.size.width - _enemy.size.width];
        float yOfControlPoint2 = [self getRandomNumberBetween:0
                                                         to:yOfControlPoint1];
        CGPoint startPoint = CGPointMake(xOfStartPoint,
                                         self.frame.size.height + 100);
        CGPoint endPoint = CGPointMake(xOfEndPoint,
                                       -100);
        CGPoint controlPoint1 = CGPointMake(xOfControlPoint1,
                                            yOfControlPoint1);
        CGPoint controlPoint2 = CGPointMake(xOfControlPoint2,
                                            yOfControlPoint2);
        CGPathMoveToPoint(cgPath,
                          NULL,
                          startPoint.x,
                          startPoint.y);
        CGPathAddCurveToPoint(cgPath,
                              NULL,
                              controlPoint1.x,
                              controlPoint1.y,
                              controlPoint2.x,
                              controlPoint2.y,
                              endPoint.x,
                              endPoint.y);
        SKAction * planeDestroy = [SKAction followPath:cgPath
                                              asOffset:NO
                                          orientToPath:YES
                                              duration:5];
        [self addChild:_enemy];
        SKAction * remove = [SKAction removeFromParent];
        _enemy.position = CGPointMake(-100, -100);
        [_enemy runAction:[SKAction sequence:@[[SKAction waitForDuration:0.25],
                                               planeDestroy,
                                               remove]]];
        
        /*
        //adding the enemySmokeTrail
        NSString * smokePath = [[NSBundle mainBundle] pathForResource:@"enemyTrail"
                                                               ofType:@"sks"];
        _enemySmokeTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
        [self addChild:_enemySmokeTrail];
        [_enemySmokeTrail runAction:[SKAction sequence:@[[SKAction waitForDuration:0.5],
                                                         planeDestroy,
                                                         remove]]];
        
        //adding the propeller animation
        _enemyPropeller = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE PROPELLER 1"];
        _enemyPropeller.scale = 0.2;
        _enemyPropeller.zPosition = 2;
        SKTexture * enemyPropeller1 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 1"];
        SKTexture * enemyPropeller2 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 2"];
        SKAction * spin = [SKAction animateWithTextures:@[enemyPropeller1,
                                                          enemyPropeller2]
                                           timePerFrame:0.1];
        SKAction * spinForever = [SKAction repeatActionForever:spin];
        [_enemyPropeller runAction:spinForever];
        [self addChild:_enemyPropeller];
        [_enemyPropeller runAction:[SKAction sequence:@[planeDestroy,remove]]];
        */
         
        CGPathRelease(cgPath);
        
        //enemyPhysicsBody
        _enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_enemy.size];
        _enemy.physicsBody.dynamic = YES;
        _enemy.physicsBody.categoryBitMask = enemyCategory;
        _enemy.physicsBody.contactTestBitMask = bulletCategory;
        _enemy.physicsBody.collisionBitMask = 0;
        
        //random Clouds
        int randomClouds = [self getRandomNumberBetween:0
                                                     to:1];
        if (randomClouds == 1) {
            int whichCloud = [self getRandomNumberBetween:0
                                                       to:3];
            _cloud = [SKSpriteNode spriteNodeWithTexture:[_cloudsTextures objectAtIndex:whichCloud]];
            int randomY = [self getRandomNumberBetween:0
                                                    to:self.frame.size.height];
            _cloud.zPosition = 1;
            _cloud.position = CGPointMake(self.frame.size.height + _cloud.size.height / 2,
                                          randomY);
            int randomTimeCloud = [self getRandomNumberBetween:9
                                                            to:19];
            SKAction * move = [SKAction moveTo:CGPointMake(0 - _cloud.size.height,
                                                           randomY)
                                      duration:randomTimeCloud];
            SKAction * remove = [SKAction removeFromParent];
            [_cloud runAction:[SKAction sequence:@[move,
                                                   remove]]];
            [self addChild:_cloud];
        
        }
    }
}

-(int)getRandomNumberBetween:(int)from
                          to:(int)to {
    return (int)from + arc4random() % (to - from + 1);
}


-(void)touchesBegan:(NSSet *)touches
          withEvent:(UIEvent *)event {
    
    /* Called when a touch begins */
    CGPoint location = [_plane position];
    _bullet = [SKSpriteNode spriteNodeWithImageNamed:@"B 2"];
    _bullet.position = CGPointMake(location.x,
                                  location.y + _plane.size.height / 2);
    _bullet.zPosition = 1;
    _bullet.scale = 0.8;
    SKAction * action = [SKAction moveToY:self.frame.size.height + _bullet.size.height
                                duration:2];
    SKAction * remove = [SKAction removeFromParent];
    [_bullet runAction:[SKAction sequence:@[action,
                                            remove]]];
    [self addChild:_bullet];
    
    //bulletPhysicsBody
    _bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_bullet.size];
    _bullet.physicsBody.dynamic = NO;
    _bullet.physicsBody.categoryBitMask = bulletCategory;
    _bullet.physicsBody.contactTestBitMask = enemyCategory;
    _bullet.physicsBody.collisionBitMask = 0;
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody * firstBody;
    SKPhysicsBody * secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if ((firstBody.categoryBitMask & bulletCategory) != 0) {
        SKNode * projectile = (contact.bodyA.categoryBitMask & bulletCategory) ? contact.bodyA.node : contact.bodyB.node;
        SKNode * enemy = (contact.bodyA.categoryBitMask & bulletCategory) ? contact.bodyB.node : contact.bodyA.node;
        [projectile runAction:[SKAction removeFromParent]];
        [enemy runAction:[SKAction removeFromParent]];
        
        //add explosion
        SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[_explosionTextures objectAtIndex:0]];
        explosion.zPosition = 1;
        explosion.scale = 0.6;
        explosion.position = contact.bodyA.node.position;
        [self addChild:explosion];
        SKAction * explosionAction = [SKAction animateWithTextures:_explosionTextures
                                                      timePerFrame:0.07];
        SKAction * remove = [SKAction removeFromParent];
        [explosion runAction:[SKAction sequence:@[explosionAction,remove]]];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    float maxX = self.frame.size.width - _plane.size.width / 2;
    float minX = _plane.size.width / 2;
    float maxY = self.frame.size.height - _plane.size.height / 2;
    float minY = _plane.size.height / 2;
    float newX = 0;
    float newY = 0;
    if (_currentMaxAccelX > 0.05) {
        newX = _currentMaxAccelX * 10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 R"];
    } else if (_currentMaxAccelX < -0.05) {
        newX = _currentMaxAccelX * 10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 L"];
    } else {
        newX = _currentMaxAccelX * 10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 N"];
    }
    newY = 8 + _currentMaxAccelY * 10;
    float newXshadow = newX + _planeShadow.position.x;
    float newYshadow = newY + _planeShadow.position.y;
    newXshadow = MIN(MAX(newXshadow,
                         minX + 10),
                     maxX + 10);
    newYshadow = MIN(MAX(newYshadow,
                         minY - 10),
                     maxY - 10);
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
    _propeller.position = CGPointMake(newXpropeller,
                                      newYpropeller);
    _smokeTrail.position = CGPointMake(newX,
                                       newY - (_plane.size.height / 2));
}

@end
