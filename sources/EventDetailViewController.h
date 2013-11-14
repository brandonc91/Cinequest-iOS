//
//  EventDetailViewController.h
//  CineQuest
//
//  Created by Loc Phan on 10/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FBConnect.h"

@class Schedule;
@class CinequestAppDelegate;

@interface EventDetailViewController : UIViewController 
	<UIWebViewDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, FBDialogDelegate, FBSessionDelegate, FBRequestDelegate>
{
	CinequestAppDelegate *delegate;
	NSMutableArray *mySchedule;
	Schedule *myData;
	
	NSString *eventId;
	NSURL *dataLink;
	
	NSMutableDictionary *dataDictionary;
	BOOL displayAddButton;	
	FBSession *_session;
	FBUID facebookID;
	UIButton *postThisButton;
}

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activity;
@property (readwrite) BOOL displayAddButton;

- (id)initWithTitle:(NSString*)name andDataObject:(Schedule*)dataObject andURL:(NSURL*)link;
- (id)initWithTitle:(NSString*)name andDataObject:(id)dataObject andId:(NSString*)eventID;

@end
