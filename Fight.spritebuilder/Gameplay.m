//
//  Gameplay.m
//  Fight
//
//  Created by Jianchen Tao on 7/16/14.
//  Copyright 2014 Apportable. All rights reserved.
//
#import "Defender.h"
#import "Attacker.h"
#import "Gameplay.h"
#import "Border.h"
#import <CoreMotion/CoreMotion.h>
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Gameplay {
    UIAccelerationValue _accelerometerX;
    UIAccelerationValue _accelerometerY;
    UIAccelerationValue _accelerometerZ;
    
    
    float BorderCollisionDamping;
    
    
    
    Defender *_defender;
    float _defenderSpeedX;
    float _defenderSpeedY;
    float _defenderAccelX;
    float _defenderAccelY;
    float _defenderAccelZ;
    float _defenderAngle;
    float _defenderLastAngle;
    
    float _attacker1LastAngle;
    int _timer;
    
    Attacker *_attacker1;
    Attacker *_attacker2;
    Attacker *_attacker3;
    Attacker *_attacker4;
    NSMutableArray *_attackers;
    CCPhysicsNode *_physicsNode;
    CGFloat minY;
    CGFloat maxY;
    CGFloat minX;
    CGFloat maxX;
    CCButton *_restartButton;
    
    CMMotionManager *_motionManager;
    BOOL _gameStart;
    BOOL _gameOver;
    float mTimeInSec;
    CCLabelTTF *_scoreLabel;
}


const float MaxPlayerAccel = 400.0f;
const float MaxPlayerSpeed = 200.0f;
const float BorderCollisionDamping = 1.2f;

- (void)didLoadFromCCB {
    // visualize physics bodies & joints
//    _physicsNode.debugDraw = TRUE;
    
    
    _physicsNode.collisionDelegate = self;
    
    // tell this scene to accept touches
    CCLOG(@"init gameplay scene");
    
    _attackers = [[NSMutableArray alloc] initWithObjects:_attacker1, _attacker2, _attacker3, _attacker4, nil];
    self.userInteractionEnabled = TRUE;
    CGSize fieldSize = [[CCDirector sharedDirector] viewSize];
    CGPoint centerPoint = ccp(fieldSize.width/2, fieldSize.height/2);
    
    CCLOG(@"the size for defender is (%f, %f)", _defender.contentSize.width, _defender.contentSize.height);
    
    // get battlefield border
    minY = centerPoint.y - 307.0f/2 + _defender.contentSize.height/2;
    maxY = centerPoint.y + 307.0f/2 - _defender.contentSize.height/2;
    minX = centerPoint.x - 307.0f/2 + _defender.contentSize.width/2;
    maxX = centerPoint.x + 307.0f/2 - _defender.contentSize.width/2;
    
//    [self moveRandom:_attacker1];
    
    _motionManager = [[CMMotionManager alloc] init];
    _gameStart = NO;
    _gameOver = NO;
    [_scoreLabel setString:@"00:00"];
}



- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{

    
//    // we want to know the location of our touch in this scene
//    CGPoint touchLocation = [touch locationInNode:self];
//    
//    // confine touch region within battlefield
//    CCLOG(@"location min X is %f, max X is %f, min Y is %f, maxY is %f", minX, maxX, minY, maxY);
//    CCLOG(@"current location: (%f, %f)", touchLocation.x, touchLocation.y);
//    [_defender setPosition:ccp(clampf(touchLocation.x, minX, maxX), clampf(touchLocation.y, minY, maxY))];
//    [self startSet];
    if (!_gameStart) {
        [self startSet];
    }
    
}

//- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    CGPoint touchLocation = [touch locationInNode:self];
//    [_defender setPosition:ccp(clampf(touchLocation.x, minX, maxX), clampf(touchLocation.y, minY,

- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if(touch.tapCount==1) CCLOG(@"ONE TAP");
    if(touch.tapCount==2)  {
        CCLOG(@"TWO TAPS");
        [self startShield];
    }
    return;
}

- (void) startSet {
    CCLOG(@"touch received");
    _gameStart = YES;
    _timer = 0;
    [_motionManager startAccelerometerUpdates];
    for (int i = 0; i<_attackers.count; ++i) {
        CGPoint force = ccpMult(ccp(arc4random()%5+1, arc4random()%5+1), 10000);
        [[[_attackers objectAtIndex:i] physicsBody] applyForce:force];
    }
}

- (void) startShield {
    CCLOG(@"initiate shield");
}


- (void)update:(CCTime)delta
{
    [self tick:delta];
    [self updateDefender:delta];
    if (_timer % 5 == 3) {
        [self traceDefender];
    }
//    [self updateAttacker:delta];
}

- (void) traceDefender {
    int i = arc4random() % 4;
    CGFloat target_x = _defender.position.x;
    CGFloat target_y = _defender.position.y;
    CGPoint direction = ccp(target_x / sqrt(target_x * target_x + target_y * target_y), target_y / sqrt(target_x * target_x + target_y * target_y));
    CGPoint force = ccpMult(direction, 5000);
    [[[_attackers objectAtIndex:i] physicsBody] applyForce:force];
}

// a low pass filter
- (void)filterAcceleration:(CMAcceleration)acceleration
{
    const double FilteringFactor = 0.1;

    _accelerometerX = acceleration.x * FilteringFactor + _accelerometerX * (1.0 - FilteringFactor);
    _accelerometerY = acceleration.y * FilteringFactor + _accelerometerY * (1.0 - FilteringFactor);
    _accelerometerZ = acceleration.z * FilteringFactor + _accelerometerZ * (1.0 - FilteringFactor);

    
    _defenderAccelX = _accelerometerX;
    _defenderAccelY = _accelerometerY;
    _defenderAccelZ = _accelerometerZ;
    
    if (_accelerometerX > 0.05)
    {
        _defenderAccelX = MaxPlayerAccel;
    }
    else if (_accelerometerX < -0.05)
    {
        _defenderAccelX = -MaxPlayerAccel;
    }
    if (_accelerometerY < -0.05)
    {
        _defenderAccelY = -MaxPlayerAccel;
    }
    else if (_accelerometerY > 0.05)
    {
        _defenderAccelY = MaxPlayerAccel;
    }
    if (_accelerometerZ < -0.05)
    {
        _defenderAccelZ = -MaxPlayerAccel;
    }
    else if (_accelerometerZ > 0.05)
    {
        _defenderAccelZ = MaxPlayerAccel;
    }
    
}


//- (void)updateAttacker:(CCTime)delta {
//    float newXPosition = _attacker1.position.x + _attacker1.physicsBody.velocity.x * delta;
//    float newYPosition = _attacker1.position.y + _attacker1.physicsBody.velocity.y * delta;
//    
//    BOOL collidedWithVerticalBorder = NO;
//    BOOL collidedWithHorizontalBorder = NO;
//    
//    if (newXPosition < minX)
//    {
//        collidedWithVerticalBorder = YES;
//    }
//    else if (newXPosition > maxX)
//    {
//        collidedWithVerticalBorder = YES;
//    }
//    
//    if (newYPosition < minY)
//    {
//        collidedWithHorizontalBorder = YES;
//    }
//    else if (newYPosition > maxY)
//    {
//        collidedWithHorizontalBorder = YES;
//    }
//    newXPosition = clampf(newXPosition, minX, maxX);
//    newYPosition = clampf(newYPosition, minY, maxY);
//    _attacker1.position = CGPointMake(newXPosition, newYPosition);
//    
//    float speed = sqrtf(_attacker1.physicsBody.velocity.x*_attacker1.physicsBody.velocity.x + _attacker1.physicsBody.velocity.y*_attacker1.physicsBody.velocity.y);
//
//    
//    if (speed > 40.0f)
//    {
//        float angle = atan2f(_attacker1.physicsBody.velocity.y, _attacker1.physicsBody.velocity.x);
//        
//        // Did the angle flip from +Pi to -Pi, or -Pi to +Pi?
//        if (_attacker1LastAngle < -3.0f && angle > 3.0f)
//        {
//            _attacker1LastAngle += M_PI * 2.0f;
//        }
//        else if (_attacker1LastAngle > 3.0f && angle < -3.0f)
//        {
//            _attacker1LastAngle -= M_PI * 2.0f;
//        }
//        
//        _attacker1LastAngle = angle;
//        const float RotationBlendFactor = 0.2f;
//        _attacker1LastAngle = angle * RotationBlendFactor + _attacker1LastAngle * (1.0f - RotationBlendFactor);
//    }
//    
//    _attacker1.rotation = 90.0f - CC_RADIANS_TO_DEGREES(_attacker1LastAngle);
//    
//    if (collidedWithVerticalBorder) {
//        CGPoint force = ccpMult(ccp(-_attacker1.physicsBody.velocity.x, _attacker1.physicsBody.velocity.y), BorderCollisionDamping *1000);
//        [[_attacker1 physicsBody] applyForce:force];
//    }
//    
//    if (collidedWithHorizontalBorder){
//        CGPoint force = ccpMult(ccp(_attacker1.physicsBody.velocity.x, -_attacker1.physicsBody.velocity.y), BorderCollisionDamping *1000);
//        [[_attacker1 physicsBody] applyForce:force];
//    }
//}

- (void)updateDefender:(CCTime)delta {



    
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    [self filterAcceleration:acceleration];
    
     _defenderSpeedX = _defenderAccelX * 10 * delta + _defender.physicsBody.velocity.x;
    _defenderSpeedY = _defenderAccelY * 10 *delta + _defender.physicsBody.velocity.y;
    
    _defenderSpeedX = fmaxf(fminf(_defenderSpeedX, MaxPlayerSpeed), -MaxPlayerSpeed);
    _defenderSpeedY = fmaxf(fminf(_defenderSpeedY, MaxPlayerSpeed), -MaxPlayerSpeed);
    
    
    
    float newXPosition = _defender.position.x + _defenderSpeedX * delta;
    float newYPosition = _defender.position.y + _defenderSpeedY * delta;
//    CCLOG(@"the accel is (%f, %f) with delta is %f", _defenderAccelX, _defenderAccelY, delta);
//    CCLOG(@"the new speed is (%f, %f)", _defenderSpeedX, _defenderSpeedY);
//    CCLOG(@"the new position is (%f, %f)", newXPosition, newYPosition);
    
    BOOL collidedWithVerticalBorder = NO;
    BOOL collidedWithHorizontalBorder = NO;
    
    if (newXPosition < minX)
    {
        collidedWithVerticalBorder = YES;
    }
    else if (newXPosition > maxX)
    {
        collidedWithVerticalBorder = YES;
    }
    
    if (newYPosition < minY)
    {
        collidedWithHorizontalBorder = YES;
    }
    else if (newYPosition > maxY)
    {
        collidedWithHorizontalBorder = YES;
    }
    
    newXPosition = clampf(newXPosition, minX, maxX);
    newYPosition = clampf(newYPosition, minY, maxY);
    _defender.position = CGPointMake(newXPosition, newYPosition);
    
    
    float speed = sqrtf(_defenderSpeedX*_defenderSpeedX + _defenderSpeedY*_defenderSpeedY);
    if (speed > 40.0f)
    {
        float angle = atan2f(_defenderSpeedY, _defenderSpeedX);

        if (_defenderLastAngle < -3.0f && angle > 3.0f)
        {
            _defenderAngle += M_PI * 2.0f;
        }
        else if (_defenderLastAngle > 3.0f && angle < -3.0f)
        {
            _defenderAngle -= M_PI * 2.0f;
        }
        
        _defenderLastAngle = angle;
        const float RotationBlendFactor = 0.2f;
        _defenderAngle = angle * RotationBlendFactor + _defenderAngle * (1.0f - RotationBlendFactor);
    }
    

    _defender.rotation = 90.0f - CC_RADIANS_TO_DEGREES(_defenderAngle);
    
    if (collidedWithVerticalBorder)
    {
        CGPoint force = ccpMult(ccp(-_defender.physicsBody.velocity.x, _defender.physicsBody.velocity.y), 1);
        [[_defender physicsBody] applyForce:force];
    }
    
    if (collidedWithHorizontalBorder)
    {
        CGPoint force = ccpMult(ccp(_defender.physicsBody.velocity.x, -_defender.physicsBody.velocity.y), 1);
        [[_defender physicsBody] applyForce:force];
    }
}




- (void)retry {
    //reload battle field
    _gameStart = NO;
    [[CCDirector sharedDirector]replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair border:(CCNode *)nodeA defender:(CCNode *)nodeB {
    CGPoint force = ccpMult(ccp(nodeB.physicsBody.velocity.x, nodeB.physicsBody.velocity.y), 1);
    [[nodeB physicsBody] applyForce:force];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair border:(CCNode *)nodeA attacker:(CCNode *)nodeB {
    CGPoint force = ccpMult(ccp(nodeB.physicsBody.velocity.x, nodeB.physicsBody.velocity.y), 40);
    [[nodeB physicsBody] applyForce:force];
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair defender:(CCNode *)nodeA attacker:(CCNode *)nodeB {
    CCLOG(@"game is over");
    [self gameOver];
    return true;
}

-(void)tick:(CCTime)delta {
    if(!_gameStart || _gameOver)
        return;
    
    mTimeInSec +=delta;
    
    float digit_min = mTimeInSec/60.0f;
    float digit_sec = ((int)mTimeInSec%60);
    
    int min = (int)digit_min;
    int sec = (int)digit_sec;
    _timer ++;
//    CCLOG(@"mTimeInSec is %f", mTimeInSec);
    
    [_scoreLabel setString:[NSString stringWithFormat:@"%.2d:%.2d", min,sec]];
    
}


- (void)gameOver {
    CCLOG(@"game over entered!");
    if (!_gameOver) {
        CCLOG(@"game over button should be visible.");
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
    }
}

@end
