//
//  CalculateTurnByTurn.h
//  PBDirection
//
//  Created by Guido Naturani on 19/09/13.
//  Copyright (c) 2013 Guido Naturani. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KBPebbleMessageQueue.h"

@protocol UpdateCompleteDelegate <NSObject>
-(void)updateEnd:(BOOL)iSuccess :(NSString *) iMessage;
@end

@interface CalculateTurnByTurn : NSObject{
    
    id<UpdateCompleteDelegate> _Delegate;
}

@property (strong, nonatomic) id<UpdateCompleteDelegate> _Delegate;

-(void)calculate;

@end
