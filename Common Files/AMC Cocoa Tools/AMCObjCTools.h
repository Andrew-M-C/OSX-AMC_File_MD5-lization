//
//  AMCDebug.h
//  HelloMac
//
//  Created by Andrew Chang on 12-11-23.
//  Copyright (c) 2012年 Andrew Chang. All rights reserved.
//

#ifndef HelloMac_AMCDebug_h
#define HelloMac_AMCDebug_h

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

/* NSObject release */
#if __has_feature(objc_arc)
#define AMCRelease(obj)		(obj) = (nil)
#else
#define AMCRelease(obj)     if (obj){[(obj) release]; (obj) = nil;}
#endif

#define AMC_RELEASE(obj)	AMCRelease(obj)

/* ANSI-C free */
#define AMCFree(ptr)		if(ptr){free(ptr); (ptr) = (NULL);}
#define	AMC_FREE(ptr)		AMCFree(ptr)

/* Core Funcdation release */
#define AMCCFRetain(ref)	if(ref){CFRetain(ref);}
#define AMCCFRelease(ref)	if(ref){CFRelease(ref); (ref) = (NULL);}
#define AMC_CF_RETAIN(ref)	AMCCFRetain(ref)
#define AMC_CF_RELEASE(ref)	AMCCFRelease(ref)

/* force value type conversion */
#define NSTimeInterval_COVT(x)		((NSTimeInterval)(x))
#define CGFloat_COVT(x)				((CGFloat)(x))

/* define debug flag and other log flags */
//#define AMC_DEBUG
#define AMC_SYSTEM_ERROR
#define AMC_SYSTEM_LOG

/* debug log tools */
#ifdef  AMC_DEBUG
#define AMCDebug(fmt, arg...)	printf("\n>> Line %03d, %s\n", __LINE__, __FUNCTION__);NSLog(@"\n"fmt, ##arg)
#define AMCAlert(fmt, arg...)		\
		dispatch_async(dispatch_get_main_queue(), ^{	\
			NSRunAlertPanel(\
					@" ", \
					fmt, \
					@"OK", nil, nil, ##arg);	\
		})
#define AMCTodo(x)	AMCDebug(@"<<<TODO>>>\n%@", x)
#define AMCMark()	AMCDebug(@"<<<MARK>>>");
#define AMCSimpleMark()		AMCPrintf("<<<MARK>>>")
//#define AMCPrintf(fmt, arg...)	printf("%s>> %s(%03d): ", [[AMCTools timeStringForCurrentTimeWithDateFormat:@"HH:mm.SSS"] UTF8String], __FUNCTION__, __LINE__);printf(fmt, ##arg);printf("\n")
#define AMCPrintf(fmt, arg...)	printf("%s>> (%03d): ", [[AMCTools timeStringForCurrentTimeWithDateFormat:@"HH:mm:ss.SSS"] UTF8String], __LINE__);printf(fmt, ##arg);printf("\n")
#define AMCTodoMark()	printf("\n#### Line %d, %s is TODO!!\n\n", __LINE__, __FUNCTION__)
#else
#define AMCDebug(fmt, arg...)
#define AMCAlert(fmt, arg...)
#define	AMCTodo(x)
#define AMCMark()
#define	AMCPrintf(fmt, arg...)
#define	AMCTodoMark()	printf("\n#### %s is TODO!!\n\n", __FUNCTION__)
#endif

/* system error log */
#ifdef  AMC_SYSTEM_ERROR
#define AMCSysError(fmt, arg...)	printf("ERROR in Line %d, %s\n", __LINE__, __FUNCTION__);NSLog(@"\n"fmt, ##arg)
#else
#define AMCSysError(fmt, arg...)
#endif

/* normal system log */
#ifdef AMC_SYSTEM_LOG
#ifdef AMC_DEBUG
#define AMCSysLog(fmt, arg...)		printf("\nLOG:");AMCDebug(fmt, ##arg)
#else
#define AMCSysLog(fmt, arg...)		NSLog(fmt, ##arg)
#endif
#else
#define AMCSysLog(fmt, arg...)
#endif

//#define AMCSuperDealloc()			[super dealloc]
#define AMCSuperDealloc()
#define AMCAlertAndExit(fmt, arg...)		AMCAlert(fmt, ##arg);[NSApp terminate:self]


/* NSFileManager macros */
#define NSDefaultFileManager		[NSFileManager defaultManager]

/* NSNotificationCenter */
#define NSDefaultNotificatonCenter	[NSNotificationCenter defaultCenter]

/* NSBundle */
#define NSMainBundle			[NSBundle mainBundle]

/* NSWorkspace */
#define NSSharedWorkspace		[NSWorkspace sharedWorkspace]

/* NSFileManager */
#define NSDefaultFileManager	[NSFileManager defaultManager]

/* NSNull */
#define NSNullObject			[NSNull null]


/* some common tools */
//NSString *AMCLocalize(NSString *para);
#define AMCLocalize(str)    NSLocalizedString(str, nil)
#define AMCWait(event)		while(!(event))
#define AMCPwd()	[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]
#define	AMCSleep(interval)	[NSThread sleepForTimeInterval:(interval)]

/* TRUE/FALSE setting */
#define SET_TRUE(x)		((x) = YES)
#define SET_FALSE(x)	((x) = NO)
#define IS_TRUE(x)		(NO != (x))
#define IS_FALSE(x)		(NO == (x))

#endif  /* end of file */
