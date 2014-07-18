//
//  Border.m
//  Fight
//
//  Created by Jianchen Tao on 7/17/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "Border.h"


@implementation Border

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"border";
}

@end
