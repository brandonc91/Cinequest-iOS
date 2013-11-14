//
//  FilmDetail.h
//  CineQuest
//
//  Created by Loc Phan on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FBConnect.h"

@class CinequestAppDelegate;
@class Schedule;
@class FBSession;

@interface FilmDetail : UIViewController <UIWebViewDelegate,
						FBDialogDelegate, FBSessionDelegate, FBRequestDelegate, 
						MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
	NSUInteger							filmId;
	Schedule							*myFilmData;
	NSMutableDictionary					*dataDictionary;
	
	IBOutlet UIWebView					*webView;
	IBOutlet UITableView				*_tableView;
	IBOutlet UIActivityIndicatorView	*activityIndicator;
	
	BOOL isDVD;
	
	FBSession *_session;
	FBUID facebookID;
	UIButton *postThisButton;
	
	CinequestAppDelegate *delegate;
	NSMutableArray *mySchedule;
}

@property (readwrite) BOOL isDVD;
@property (nonatomic, strong) IBOutlet UIWebView				*webView;
@property (nonatomic, strong) IBOutlet UITableView				*tableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView  *activityIndicator;
@property (nonatomic, strong) NSMutableDictionary				*dataDictionary;


- (id)initWithTitle:(NSString*)name andDataObject:(id)dataObject andId:(NSUInteger)id;

@end
