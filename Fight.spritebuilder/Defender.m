//
//  Defender.m
//  Fight
//
//  Created by Jianchen Tao on 7/17/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "Defender.h"


@implementation Defender

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"defender";
    CCLOG(@"initialize defender!");
}

@end
