//
//  NewsViewController.m
//  CineQuest
//
//  Created by Loc Phan on 10/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NewsViewController.h"
#import "CinequestAppDelegate.h"
#import "EventDetailViewController.h"
#import "DDXML.h"
#import "DataProvider.h"

@interface NewsViewController (Private)

- (void)loadNewsFromDB;

@end


@implementation NewsViewController

@synthesize newsTableView;
@synthesize activityIndicator;

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"News";
	
	data = [[NSMutableDictionary alloc] init];
	sections = [[NSMutableArray alloc] init];

	tabBarAnimation = YES;

	self.newsTableView.tableHeaderView = nil;
	self.newsTableView.tableFooterView = nil;
	
	// Initialize
	[data removeAllObjects];
	[sections removeAllObjects];
	
	[self performSelectorOnMainThread:@selector(startParsingXML) withObject:nil waitUntilDone:NO];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear: animated];
	
	activityIndicator.hidden = YES;
	
	if(tabBarAnimation)
	{
		[appDelegate.tabBarController.view setHidden:YES];
	}
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear: animated];

	if(tabBarAnimation)
	{
		// Don't show an ugly jerk while the bottom tabbar is drawed
		[UIView transitionWithView:appDelegate.tabBarController.view duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve
		animations:^
		{
			[appDelegate.tabBarController.view setHidden:NO];
		}
		completion:nil];
		
		tabBarAnimation = NO;
	}
}

- (void) startParsingXML
{
	NSData *htmldata = [[appDelegate dataProvider] news];
	
	NSString* myString = [[NSString alloc] initWithData:htmldata encoding:NSUTF8StringEncoding];
	myString = [myString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	myString = [myString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
	htmldata = [myString dataUsingEncoding:NSUTF8StringEncoding];
	
	DDXMLDocument *newsXMLDoc = [[DDXMLDocument alloc] initWithData:htmldata options:0 error:nil];
	DDXMLElement *rootElement = [newsXMLDoc rootElement];
	NSString *preSection	= @"empty";
	NSMutableArray *temp	= [[NSMutableArray alloc] init];
	if ([rootElement childCount] == 3)
	{
		for (int i=0; i<[rootElement childCount]; i++)
		{
			DDXMLElement *child = (DDXMLElement*)[rootElement childAtIndex:i];
			NSDictionary *attributes = [child attributesAsDictionary];
			
			NSString *section = [attributes objectForKey:@"name"];
			DDXMLElement *item = (DDXMLElement*)[child childAtIndex:0];
			NSString *title = @"";
			NSString *date = @"";
			NSString *link = @"";
			NSString *imgurl = @"";
						
			for (int j=0; j<[item childCount]; j++)
			{
				DDXMLElement *node = (DDXMLElement*)[item childAtIndex:j];
				
				if ([[node name] isEqualToString:@"title"])
				{
					title = [node stringValue];
				}
				
				if ([[node name] isEqualToString:@"date"])
				{
					date = [node stringValue];
				}
				
				if ([[node name] isEqualToString:@"imageURL"])
				{
					imgurl = [node stringValue];
				}
				
				if ([[node name] isEqualToString:@"link"])
				{
					NSDictionary *nodeAttributes = [node attributesAsDictionary];
					link = [nodeAttributes objectForKey:@"id"];
				}
			}
			
			if ([section isEqualToString:@"Header"])
			{
				DDXMLElement *node = (DDXMLElement*)[item childAtIndex:0];
				imgurl = [node stringValue];
			}
			
			NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
			[info setObject:title forKey:@"title"];
			[info setObject:date forKey:@"date"];
			[info setObject:link forKey:@"link"];
			[info setObject:imgurl	forKey:@"image"];
			
			if (![preSection isEqualToString:section])
			{
				[data setObject:temp forKey:preSection];
				
				preSection = [[NSString alloc] initWithString:section];
				
				[sections addObject:section];
				
				temp = [[NSMutableArray alloc] init];
				[temp addObject:info];
			}
			else
			{
				[temp addObject:info];
			}
			
		}
	}
	else
	{
		NSLog(@"Error parsing XML");
		return;
	}

	[data setObject:temp forKey:preSection];
	
	[sections removeObjectAtIndex:0];
	
	// [self loadImage];

	[self.newsTableView reloadData];
}

- (void) loadImage
{

	NSMutableArray *headerInfoArray = [data objectForKey:@"Header"];
	NSMutableDictionary *headerInfo = [headerInfoArray objectAtIndex:0];
	NSString *imagelink = [headerInfo objectForKey:@"image"];
	NSData *imageData = [[appDelegate dataProvider] image:[NSURL URLWithString:imagelink] expiration:nil];
	UIImage *image = [UIImage imageWithData:imageData];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.newsTableView setTableHeaderView:imageView];

	[activityIndicator stopAnimating];
	self.newsTableView.hidden = NO;
	[self.newsTableView reloadData];
}

- (IBAction) toFestival:(id)sender
{
	CinequestAppDelegate *delegate = appDelegate;
	delegate.tabBarController.selectedIndex = 0;
	delegate.isPresentingModalView = NO;
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITableView Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sections count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSString *sectionString = [sections objectAtIndex:section];
	NSMutableArray *rows = [data objectForKey:sectionString];
	return [rows count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Set up the cell...
	NSString *sectionString = [sections objectAtIndex:section];
	
	NSMutableArray *rows = [data objectForKey:sectionString];
	NSMutableDictionary *rowData = [rows objectAtIndex:row];
									 
	cell.textLabel.text = [rowData objectForKey:@"title"];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
	return [sections objectAtIndex:section];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
	NSString *sectionString = [sections objectAtIndex:section];
	
	NSMutableArray *rows = [data objectForKey:sectionString];
	NSMutableDictionary *rowData = [rows objectAtIndex:row];
/*
	NSString *link = [NSString stringWithFormat:@"%@%@",DETAILFORITEM, [rowData objectForKey:@"link"]];
	EventDetailViewController *eventDetail = [[EventDetailViewController alloc] initWithTitle:[rowData objectForKey:@"title"]
																						andDataObject:nil
																						andURL:[NSURL URLWithString:link]];
*/
	NSString *eventId = [rowData objectForKey:@"link"];
	EventDetailViewController *eventDetail = [[EventDetailViewController alloc] initWithTitle:[rowData objectForKey:@"title"]
																						andDataObject:nil
																						andId:eventId];
	[self.navigationController pushViewController:eventDetail animated:YES];
}

@end
