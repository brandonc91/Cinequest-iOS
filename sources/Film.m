//
//  Film.m
//  Cinequest
//
//  Created by Hai Nguyen on 11/5/13.
//  Copyright (c) 2013 San Jose State University. All rights reserved.
//

#import "Film.h"

@implementation Film

@synthesize schedules;
@synthesize tagline;
@synthesize genre;
@synthesize director;
@synthesize producer;
@synthesize writer;
@synthesize cinematographer;
@synthesize editor;
@synthesize cast;
@synthesize country;
@synthesize language;
@synthesize filmInfo;

- (id)init
{
    schedules = [[NSMutableArray alloc] init];
    return self;
}

@end
