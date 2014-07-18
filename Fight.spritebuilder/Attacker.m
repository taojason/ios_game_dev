//
//  Attacker.m
//  Fight
//
//  Created by Jianchen Tao on 7/17/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "Attacker.h"


@implementation Attacker {
    float speedX;
    float speedY;
    float accelX;
    float accelY;
    float spin;
}

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"attacker";
}



@end
