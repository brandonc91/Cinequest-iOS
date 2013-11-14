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
#import "LoadDataViewController.h"
#import "DDXML.h"

@interface NewsViewController (Private)

- (void)loadNewsFromDB;

@end


@implementation NewsViewController

@synthesize newsTableView;
@synthesize activityIndicator;
@synthesize loadingLabel;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidLoad {
    [super viewDidLoad];
	

	// Initialize
	data = [[NSMutableDictionary alloc] init];
	sections = [[NSMutableArray alloc] init];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Festival"
																			  style:UIBarButtonItemStyleBordered
																			 target:self
																			 action:@selector(toFestival:)];
	
	[NSThread detachNewThreadSelector:@selector(startParsingXML) toTarget:self withObject:nil];
	self.newsTableView.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
	NSIndexPath *tableSelection = [self.newsTableView indexPathForSelectedRow];
    [self.newsTableView deselectRowAtIndexPath:tableSelection animated:YES];

	// Don't show the spinning wheel and the "loading" label for now... (Luca 11-6-13)
	activityIndicator.hidden = YES;
	loadingLabel.hidden = YES;
}

- (void)startParsingXML {
	@autoreleasepool {
		NSURL *link = [NSURL URLWithString:NEWS];
		NSData *htmldata = [NSData dataWithContentsOfURL:link];
        
        NSString* myString = [[NSString alloc] initWithData:htmldata encoding:NSUTF8StringEncoding];
        myString = [myString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        myString = [myString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        htmldata = [myString dataUsingEncoding:NSUTF8StringEncoding];
        
		DDXMLDocument *newsXMLDoc = [[DDXMLDocument alloc] initWithData:htmldata options:0 error:nil];
		DDXMLElement *rootElement = [newsXMLDoc rootElement];
		NSString *preSection	= @"empty";
		NSMutableArray *temp	= [[NSMutableArray alloc] init];
		if ([rootElement childCount] == 3) {
			for (int i=0; i<[rootElement childCount]; i++) {
				DDXMLElement *child = (DDXMLElement*)[rootElement childAtIndex:i];
				NSDictionary *attributes = [child attributesAsDictionary];
				
				NSString *section = [attributes objectForKey:@"name"];
				DDXMLElement *item = (DDXMLElement*)[child childAtIndex:0];
				NSString *title = @"";
				NSString *date = @"";
				NSString *link = @"";
				NSString *imgurl = @"";
							
				for (int j=0; j<[item childCount]; j++) {
					DDXMLElement *node = (DDXMLElement*)[item childAtIndex:j];
					if ([[node name] isEqualToString:@"title"]) {
						title = [node stringValue];
					}
					if ([[node name] isEqualToString:@"date"]) {
						date = [node stringValue];
					}
					if ([[node name] isEqualToString:@"imageURL"]) {
						imgurl = [node stringValue];
						
					}
					if ([[node name] isEqualToString:@"link"]) {
						NSDictionary *nodeAttributes = [node attributesAsDictionary];
						link = [nodeAttributes objectForKey:@"id"];
					}
				}
				
				if ([section isEqualToString:@"Header"]) {
					DDXMLElement *node = (DDXMLElement*)[item childAtIndex:0];
					imgurl = [node stringValue];
				}
				NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
				[info setObject:title forKey:@"title"];
				[info setObject:date forKey:@"date"];
				[info setObject:link forKey:@"link"];
				[info setObject:imgurl	forKey:@"image"];
				
				if (![preSection isEqualToString:section]) {
					
					[data setObject:temp forKey:preSection];
					
					preSection = [[NSString alloc] initWithString:section];
					
					[sections addObject:section];
					
					temp = [[NSMutableArray alloc] init];
					[temp addObject:info];
				} else {
					[temp addObject:info];
				}
				
			}
		} else {
			//NSLog(@"child count: %d",[rootElement childCount]);
			loadingLabel.text = @"Error parsing XML.";
			return;
		}

		[data setObject:temp forKey:preSection];
		
		[sections removeObjectAtIndex:0];
		
		[NSThread detachNewThreadSelector:@selector(loadImage) toTarget:self withObject:nil];
	}
}
- (void)loadImage{
    
    @autoreleasepool {
        NSMutableArray *headerInfoArray = [data objectForKey:@"Header"];
        NSMutableDictionary *headerInfo = [headerInfoArray objectAtIndex:0];
        NSString *imagelink = [headerInfo objectForKey:@"image"];
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imagelink]];
        UIImage *image = [UIImage imageWithData:imageData];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.newsTableView setTableHeaderView:imageView];
        loadingLabel.hidden = YES;
        [activityIndicator stopAnimating];
        self.newsTableView.hidden = NO;
        [self.newsTableView reloadData];
        
    }
}

- (IBAction)toFestival:(id)sender {
	CinequestAppDelegate *delegate = appDelegate;
	delegate.tabBarController.selectedIndex = 0;
	delegate.isPresentingModalView = NO;
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sections count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *sectionString = [sections objectAtIndex:section];
	NSMutableArray *rows = [data objectForKey:sectionString];
	return [rows count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
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

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
	return [sections objectAtIndex:section];
}

#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
	NSString *sectionString = [sections objectAtIndex:section];
	
	NSMutableArray *rows = [data objectForKey:sectionString];
	NSMutableDictionary *rowData = [rows objectAtIndex:row];
	
	
	NSString *link = [NSString stringWithFormat:@"%@%@",DETAILFORITEM, [rowData objectForKey:@"link"]];
	
	EventDetailViewController *eventDetail = [[EventDetailViewController alloc] initWithTitle:[rowData objectForKey:@"title"]
																				andDataObject:nil
																					   andURL:[NSURL URLWithString:link]];	
	app.networkActivityIndicatorVisible = YES;
	[self.navigationController pushViewController:eventDetail animated:YES];
}

@end
