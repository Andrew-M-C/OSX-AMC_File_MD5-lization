//
//  AMCViewController.h
//
//  Created by Andrew Chang on 13-1-29.
//  Copyright (c) 2015年 Andrew Chang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/****************************************************************
 * TPViewControllerDelegate
 */
@class AMCViewController;

@protocol AMCViewControllerDelegate <NSObject>
@optional
- (void) informToSuperviewWithMessage: (id) message
						   fromSender: (id) sender;
- (void) informToSuperviewWithMessage:(id)message
						   withObject:(id)arg
						   fromSender:(id)sender;
@end


@interface AMCViewController : NSViewController
@property (nonatomic, assign) id<AMCViewControllerDelegate> delegate;
@property (nonatomic) NSString *identifier;

/****************************************************************
 * Method:	- localize:
 * Author:	Andrew Chang
 * Input:	Caller id
 * Return:	N/A
 * Discription:
 *		Tell the controller to localize his view. This method may
 *	be called when initializing or displaying a subview.
 */
- (void) localize: (id) sender;

/****************************************************************
 * Method:	- smartLocalize:
 * Author:	Andrew Chang
 * Input:	Caller id
 * Return:	N/A
 * Discription:
 *     Tell the controller to localize his view. This method is
 * already implementded. It chek all the sub views, and localize
 * all NSTextField and NSButton objects according to their string
 * or title value. 
 *     This method is not involked by -addViewToSuperView: method.
 * User should call this method explicitly, or overwrite -localize:
 * method and call this in it.
 */
- (void) smartLocalize: (id) sender;

/****************************************************************
 * Method:	+ smartLocalizeView:
 * Author:	Andrew Chang
 * Input:	a view
 * Return:	N/A
 * Discription:
 *     Tell the controller to localize his view. This method is
 * already implementded. It chek all the sub views, and localize
 * all NSTextField and NSButton objects according to their string
 * or title value.
 *     This method is not involked by -addViewToSuperView: method.
 * User should call this method explicitly, or overwrite -localize:
 * method and call this in it.
 */
+ (void) smartLocalizeView: (NSView*) view;

/****************************************************************
 * Method:	- addViewToSuperview:
 * Author:	Andrew Chang
 * Input:	the super view to add to
 * Return:	N/A
 * Discription:
 *		Tell the controller to add its view to specified super 
 *	view. Calling [super] to add the view before you initialize
 *	your custom codes.
 */
- (void) addViewToSuperview: (NSView*) superview;

/****************************************************************
 * Method:	- oneTimeInit:
 * Author:	Andrew Chang
 * Input:	N/A
 * Return:	N/A
 * Discription:
 *		Called after view was firstly added to superview. Only
 *  when a view is added, view controller's outlets are assigned.
 *      This method will be call once. Do not need to call super 
 *  when overwritting this method.
 */
- (void)oneTimeInit;

/****************************************************************
 * Method:	- removeViewFromSuperview:
 * Author:	Andrew Chang
 * Input:	N/A
 * Return:	N/A
 * Discription:
 *		Tell the controller to remove its view from super view.
 *	Calling [super] to remove the view. And then you can specify 
 *	your custom codes such as free some resources or close some
 *	file descriptors.
 */
- (void) removeViewFromSuperview;

/****************************************************************
 * Method:	- layoutViewWithNotification:
 * Author:	Andrew Chang
 * Input:	notification
 * Return:	N/A
 * Discription:
 *		Request re-layout the view. This method is designed to be
 *	called in - windowDidResize: method of NSWindowDelegate;
 *		Controller should be responds to layout view components
 *	those could not be spefified in nib file.
 */
- (void) layoutViewWithNotification: (NSNotification *)notification
							 sender: (id) sender;

/****************************************************************
 * Method:	- sendMessageToDelegate:
 * Author:	Andrew Chang
 * Input:	a message with object to send
 * Return:	N/A
 * Discription:
 *		This is a package of TPViewControllerDelegate message send
 *	method.
 */
- (void) sendMessageToDelegate: (id) message;

/****************************************************************
 * Method:	- sendMessageToDelegate:withObject:
 * Author:	Andrew Chang
 * Input:	a message to send
 *			an argument object
 * Return:	N/A
 * Discription:
 *		This is a package of TPViewControllerDelegate message send
 *	method.
 */
- (void)sendMessageToDelegate:(id)message
				   withObject:(id)arg;

/****************************************************************
 * Method:	- initWithDefaultNibWithBundle:nibBundleOrNil
 * Author:	Andrew Chang
 * Input:	Initialize with default nib file
 * Return:	id
 * Discription:
 *		Init with its only nib file. 
 *		This method should NEVER called in a TPViewController object
 *	Subclasses should implement this method WITHOUT calling super!
 */
- (id)initWithDefaultNibWithBundle:(NSBundle *)nibBundleOrNil;

/****************************************************************
 * Method:	- setViewFrame
 * Author:	Andrew Chang
 * Input:	view frame
 * Return:	N/A
 * Discription:
 *		...
 */
- (void)setViewFrame:(NSRect)frame;
@end
