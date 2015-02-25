//
//  AMCViewController.m
//  AMCMultiWindowTest
//
//  Created by Andrew Chang on 13-1-29.
//  Copyright (c) 2015年 Andrew Chang. All rights reserved.
//

#import "AMCViewController.h"

@interface AMCViewController ()

@end

@implementation AMCViewController
{
	BOOL _AMCViewController_isAddedSubViewBefore;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
        // Initialization code here.
		self.delegate = nil;
		_identifier = nil;
		_AMCViewController_isAddedSubViewBefore = NO;
	}
    
	return self;
}

- (void)localize:(id)sender
{
	/* Null. subclass should re-write this method */
}

- (void)smartLocalize:(id)sender
{
	NSUInteger tmp, count;
	NSArray *subViews = [self.view subviews];
	NSObject *target;
	count = [subViews count];
	for (tmp = 0; tmp < count; tmp++)
	{
		target = [subViews objectAtIndex:tmp];
		if ([target isKindOfClass:[NSButton class]])
		{
			[(NSButton*)target setTitle:NSLocalizedString([(NSButton*)target title], nil)];
		}
		else if ([target isKindOfClass:[NSTextField class]])
		{
			[(NSTextField*)target setStringValue:NSLocalizedString([(NSTextField*)target stringValue], nil)];
		}
		else
		{
			/* do nothing */
		}
		target = nil;
	}
	
	subViews = nil;
}

+ (void)smartLocalizeView:(NSView *)view
{
	NSUInteger tmp, count;
	NSArray *subViews = [view subviews];
	NSObject *target;
	count = [subViews count];
	for (tmp = 0; tmp < count; tmp++)
	{
		target = [subViews objectAtIndex:tmp];
		if ([target isKindOfClass:[NSButton class]])
		{
			[(NSButton*)target setTitle:NSLocalizedString([(NSButton*)target title], nil)];
		}
		else if ([target isKindOfClass:[NSTextField class]])
		{
			[(NSTextField*)target setStringValue:NSLocalizedString([(NSTextField*)target stringValue], nil)];
		}
		else
		{
			/* do nothing */
		}
		target = nil;
	}
	
	subViews = nil;
}

/* add the controller's view to a superview */
- (void)addViewToSuperview:(NSView *)superview
{
	@autoreleasepool {
		if ([self view])
		{
			[superview addSubview:self.view];
			//[superview setNeedsDisplay:YES];
			if (!_AMCViewController_isAddedSubViewBefore)
			{
				[self localize:self];
				[self oneTimeInit];
				_AMCViewController_isAddedSubViewBefore = YES;
			}
		}
	}
    
	/* subclass should call super when re-writing this method */
}

- (void)oneTimeInit
{
	/* NULL */
}

/* remove from its superview */
- (void)removeViewFromSuperview
{
	@autoreleasepool {
		//NSView *theSuperview;
		
		if (self.view && self.view.superview)
		{
			//theSuperview = self.view.superview;
			[self.view removeFromSuperview];
			//[theSuperview setNeedsDisplay:YES];
		}
	}
	
	/* subclass should call super when re-writing this method */
}

/* layout view. This function can be called in resizing operation */
- (void)layoutViewWithNotification:(NSNotification *)notification
							sender:(id)sender
{
	/* Null. Can be overwritten */
}



/* send message to delegate object */
- (void)sendMessageToDelegate:(id)message
{
	if ([self.delegate respondsToSelector:@selector(informToSuperviewWithMessage:fromSender:)])
	{
		[self.delegate informToSuperviewWithMessage:message
									 fromSender:self];
	}
	else if ([self.delegate respondsToSelector:@selector(informToSuperviewWithMessage:withObject:fromSender:)])
	{
		[self.delegate informToSuperviewWithMessage:message
									 withObject:nil
									 fromSender:self];
	}
}

- (void)sendMessageToDelegate:(id)message
				   withObject:(id)arg
{
	if ([self.delegate respondsToSelector:@selector(informToSuperviewWithMessage:withObject:fromSender:)])
	{
		[self.delegate informToSuperviewWithMessage:message
									 withObject:arg
									 fromSender:self];
	}
}

/* init With nib */
/* This is a virtual method, should NEVER be called */
- (id)initWithDefaultNibWithBundle:(NSBundle *)nibBundleOrNil
{
	self = nil;	// release self
	return nil;
}


- (void)setViewFrame:(NSRect)frame
{
	[self.view setFrame:frame];
}

@end
