//
//  StartupViewController.m
//  Cinequest
//
//  Created by Luca Severini on 11/7/13.
//  Copyright (c) 2013 San Jose State University. All rights reserved.
//

#import "StartupViewController.h"
#import "CinequestAppDelegate.h"
#import "FestivalParser.h"
#import "Reachability.h"
#import "DataProvider.h"
#import "NewsViewController.h"

@implementation StartupViewController

@synthesize cinequestImage;
@synthesize sjsuImage;
@synthesize activityView;

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
	[app setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	
    [super viewDidLoad];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
	
	[activityView stopAnimating];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[app setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

	[super viewWillDisappear: animated];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear: animated];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) viewDidAppear:(BOOL)animated
{
	CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();

    [super viewDidAppear:animated];

	if(appDelegate.iPhone4Display)
	{
		[self.activityView setFrame:CGRectOffset(self.activityView.frame, 0.0, -80.0)];
		[self.sjsuImage setFrame:CGRectOffset(self.sjsuImage.frame, 0.0, -80.0)];
		[self.cinequestImage setFrame:CGRectOffset(self.cinequestImage.frame, 0.0, -80.0)];
	}

	[activityView startAnimating];
		
	[appDelegate startReachability:XML_FEED_URL];
	
	[appDelegate setMySchedule:[[NSMutableArray alloc] init]];
	[appDelegate setNewsView:[[NewsViewController alloc] init]];
	
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if(![prefs stringForKey:@"CalendarID"])
	{
        [prefs setObject:@"" forKey:@"CalendarID"];
    }
	
	[appDelegate setDataProvider:[[DataProvider alloc] init]];

	// Do we need it?
	if([appDelegate connectedToNetwork])
	{
		[appDelegate setOffSeason];
		// isOffSeason = YES;
		// NSLog(@"IS OFFSEASON? %@",(isOffSeason) ? @"YES" : @"NO");
	}

    FestivalParser *festivalParser = [[FestivalParser alloc] init];
	[appDelegate setFestival:[festivalParser parseFestival]];
	
	// Calc the delay to let the splash screen ve visible at least 3 seconds
	CFTimeInterval spentTime = CFAbsoluteTimeGetCurrent() - startTime;
	int64_t delayTime = spentTime >= 2.0 ? 0.0 : (2.0 - spentTime) * NSEC_PER_SEC;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTime), dispatch_get_main_queue(),
	^{
		UIWindow *window = [appDelegate window];
		[UIView transitionWithView:window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:
		^{
			window.rootViewController = [appDelegate tabBarController];
		}
		completion:nil];
	});
}

@end


