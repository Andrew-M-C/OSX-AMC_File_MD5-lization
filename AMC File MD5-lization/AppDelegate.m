//
//  AppDelegate.m
//  AMC File MD5-lization
//
//  Created by Andrew's MAC on 15/2/6.
//  Copyright (c) 2015年 Andrew Chang. All rights reserved.
//

#import "AppDelegate.h"
#import "AMCTools.h"
#include "AMCmd5.h"

#define CFG_LIB_MMAP
#define CFG_LIB_DEVICE
#define CFFG_LB_ERRNO
#include "AMCCommonLib.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, assign) IBOutlet NSTextField *textDir;
@property (nonatomic, assign) IBOutlet NSButton *checkboxJpg;
@property (nonatomic, assign) IBOutlet NSButton *checkboxBmp;
@property (nonatomic, assign) IBOutlet NSButton *checkboxPng;
@property (nonatomic, assign) IBOutlet NSButton *checkboxGif;
@property (nonatomic, assign) IBOutlet NSProgressIndicator *progress;
@property (nonatomic, assign) IBOutlet NSButton *buttonBrowse;
@property (nonatomic, assign) IBOutlet NSButton *buttonStart;
@property (nonatomic, assign) IBOutlet NSTextField *labelProgress;
@end

@implementation AppDelegate
{
	NSURL __strong * _operateDir;
	NSThread __strong *_hdlThreadUpdateFileName;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if ([AMCTools checkAppDuplicateAndBringToFrontWithBundle:NSMainBundle])
	{
		[AMCTools terminateApplication:self];
	}
	
	/* UI */
	[self _setCheckboxesEnabled:YES];
	[_labelProgress setStringValue:@""];
	
	/* variables */
	_operateDir = nil;
	
	/* regular expression test */
	NSString *tmpString = @"20150215-1200-3257e170ac66c5400910b589a90db409";
	NSString *regex = @"^(?:19|20|21)\\d\\d(?:0\\d|10|11|12)(?:(?:[0-2]\\d)|30|31)-(?:[01]\\d|2[0-3])(?:[0-5]\\d)-[\\da-fA-F]{32}";
	AMCDebug(@"Match: %@", [AMCTools string:tmpString matchesRegularExpression:regex] ? @"YES" : @"NO");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	// Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

/*********************/
#pragma mark - UI operations

- (void)_setCheckboxesEnabled:(BOOL)flag
{
	[_checkboxBmp setEnabled:flag];
	[_checkboxJpg setEnabled:flag];
	[_checkboxPng setEnabled:flag];
	[_checkboxGif setEnabled:flag];
}

- (BOOL)_isJpgChecked
{
	return (NSOnState == [_checkboxJpg state]);
}

- (BOOL)_isPngChecked
{
	return (NSOnState == [_checkboxPng state]);
}

- (BOOL)_isBmpChecked
{
	return (NSOnState == [_checkboxBmp state]);
}

- (BOOL)_isGifChecked
{
	return (NSOnState == [_checkboxGif state]);
}

/*********************/
#pragma mark - IBActions

- (IBAction)actionBrowse:(id)sender
{
	NSURL *dirUrl = [AMCTools fileOpenURLDirectoryWithDelegate:nil];
	
	if (dirUrl)
	{
		[_textDir setStringValue:[[dirUrl path] stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@"~"]];
		_operateDir = dirUrl;
	}
}

- (IBAction)actionStart:(id)sender
{
	if (nil == _hdlThreadUpdateFileName)
	{
		AMCDebug(@"Start. Current value: %f", [_progress doubleValue]);
		[_progress setDoubleValue:0.0];
		[_progress startAnimation:sender];
		
		[_buttonBrowse setEnabled:NO];
		[_buttonStart setTitle:@"Stop"];

		_hdlThreadUpdateFileName = [[NSThread alloc] initWithTarget:self selector:@selector(_threadUpdateFileName:) object:nil];
		[_hdlThreadUpdateFileName start];
	}
	else
	{
		[_buttonBrowse setEnabled:YES];
		[_hdlThreadUpdateFileName cancel];
		AMCDebug(@"Thread already started");
	}
}


/********************/
#pragma mark - A thread to update progress

- (void)_threadUpdateFileName:(id)arg
{@autoreleasepool {
	NSFileManager *fileMgr = [[NSFileManager alloc] init];
	
	if (nil == fileMgr)
	{
		AMCDebug(@"System error");
	}
	else if ([AMCTools isFilePathDirectory:[_operateDir path]])
	{
		NSString *opearteDir = [_operateDir path];
		NSArray *allFiles = nil;
		allFiles = [fileMgr contentsOfDirectoryAtPath:opearteDir error:nil];
		NSString *fullPath;
		
		for (NSUInteger tmp = 0;
			 (tmp < [allFiles count]) && (NO == [[NSThread currentThread] isCancelled]);
			 tmp++)
		{@autoreleasepool {
			fullPath = [NSString stringWithFormat:@"%@/%@", opearteDir, [allFiles objectAtIndex:tmp]];
			
			if (NO == [AMCTools isFilePathDirectory:fullPath])
			{
				[self _filterImageFileIn:opearteDir
								fileName:[allFiles objectAtIndex:tmp]
							 fileManager:fileMgr];
			}
			
			[self _setProgressIdentifierWithIndex:tmp + 1 of:[allFiles count]];
			[_labelProgress performSelectorOnMainThread:@selector(setStringValue:)
											 withObject:[NSString stringWithFormat:@"%ld of %ld", tmp + 1, [allFiles count]]
										  waitUntilDone:NO];
			AMCDebug(@"Complete %ld of %ld", tmp + 1, [allFiles count]);
		}}
		
		AMCRelease(allFiles);
	}
	else
	{
		AMCDebug(@"Invalid path: %@", _operateDir);
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[_buttonBrowse setEnabled:YES];
	});
	[_buttonStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start" waitUntilDone:NO];
	AMCDebug(@"Thread ends");
	AMCRelease(_hdlThreadUpdateFileName);
}}


- (void)_filterImageFileIn:(NSString*)dir
				  fileName:(NSString*)file
			   fileManager:(NSFileManager*)fileManager
{
	NSString *extension = [[file pathExtension] lowercaseString];
	BOOL shouldOperateThisFile = NO;
	
//	AMCDebug(@"Check file %@ wth extension %@", file, extension);
	
	if ([extension isEqualToString:@"jpg"])
	{
		if ([self _isJpgChecked])
		{
			shouldOperateThisFile = YES;
		}
	}
	else if ([extension isEqualToString:@"jpeg"])
	{
		if ([self _isJpgChecked])
		{
			extension = @"jpg";
			shouldOperateThisFile = YES;
		}
	}
	else if ([extension isEqualToString:@"png"])
	{
		if ([self _isPngChecked])
		{
			shouldOperateThisFile = YES;
		}
	}
	else if ([extension isEqualToString:@"bmp"])
	{
		if ([self _isBmpChecked])
		{
			shouldOperateThisFile = YES;
		}
	}
	else if ([extension isEqualToString:@"gif"])
	{
		if ([self _isGifChecked])
		{
			shouldOperateThisFile = YES;
		}
	}
	else
	{}
	
	/* operation */
	if (shouldOperateThisFile)
	{
		NSString *fullPath = [NSString stringWithFormat:@"%@/%@",
							  dir, file];
		NSString *md5 = [self _MD5OfFile:fullPath fileManager:fileManager];
		
//		AMCDebug(@"file %@ MD5: %@", file, md5);
		if (md5)
		{
			[self _renameFile:file
				  inDirectory:dir
				withExtension:extension
				   asFileName:md5
				  fileManager:fileManager];
		}
		
		AMCRelease(fullPath);
		AMCRelease(md5);
	}
}


- (void)_renameFile:(NSString*)file
		inDirectory:(NSString*)dir
	  withExtension:(NSString*)extension
		 asFileName:(NSString*)newName
		fileManager:(NSFileManager*)fileMagager
{
	NSString *dateStr = [self _modificationTimeStringOfFile:[NSString stringWithFormat:@"%@/%@", dir, file] fileManager:fileMagager];
	
	if ([[NSString stringWithFormat:@"%@-%@.%@", dateStr, newName, extension] isEqualToString:file])
	{
		// nothing to be done
	}
	else
	{
		NSUInteger tmp = 0;
		NSString *fullPath;
		
		fullPath = [NSString stringWithFormat:@"%@/%@-%@.%@", dir, dateStr, newName, extension];
		
		while ([AMCTools isFileExist:fullPath])
		{
			tmp ++;
			AMCRelease(fullPath);
			fullPath = [NSString stringWithFormat:@"%@/%@-%@(%02ld).%@", dir, dateStr, newName, tmp, extension];
		}
		
		[fileMagager moveItemAtPath:[NSString stringWithFormat:@"%@/%@", dir, file]
							 toPath:fullPath
							  error:NULL];
	}
}


- (NSString*)_modificationTimeStringOfFile:(NSString*)filePath
							   fileManager:(NSFileManager*)fileMgr
{
	NSArray *fileParts = [filePath pathComponents];
	if ([fileParts count] < 2)
	{
		AMCRelease(fileParts);
		return @"";
	}
	else
	{
		NSString *fileTrunk = [fileParts objectAtIndex:[fileParts count] - 1];
		NSString *ret = nil;
		BOOL shoulDReCalc = NO;
		
		if ([AMCTools string:fileTrunk
	matchesRegularExpression:@"^(?:19|20|21)\\d\\d(?:0\\d|10|11|12)(?:(?:[0-2]\\d)|30|31)-(?:[01]\\d|2[0-3])(?:[0-5]\\d)00-[\\da-fA-F]{32}.*"])
		{
			shoulDReCalc = YES;
		}
		else if ([AMCTools string:fileTrunk
	matchesRegularExpression:@"^(?:19|20|21)\\d\\d(?:0\\d|10|11|12)(?:(?:[0-2]\\d)|30|31)-(?:[01]\\d|2[0-3])(?:[0-5]\\d)(?:[0-5]\\d)-[\\da-fA-F]{32}.*"])
		{
			shoulDReCalc = NO;
			ret = [fileTrunk substringToIndex:13];
		}
		else {
			shoulDReCalc = YES;
		}
		
		if (shoulDReCalc)
		{
			NSDate *date = (NSDate*)[[fileMgr attributesOfItemAtPath:filePath error:NULL] objectForKey:NSFileModificationDate];
			ret = [AMCTools timeStringForDate:date withDateFormat:@"YYYYMMdd-HHmmss"];
//			AMCDebug(@"Mod time for %@: %@", fileTrunk, ret);
		}
		
		return ret;
	}
}


- (NSString*)_MD5OfFile:(NSString*)filePath
			fileManager:(NSFileManager*)fileMgr
{
	unsigned char cMd5Value[MV_MD5_MAC_LEN];
	NSString *ret = nil;
	char *cFileCxt = 0;
	unsigned long long fileSize;
	int fd = 0;
	BOOL isOK = YES;
	
	// stat()
	fileSize = [[fileMgr attributesOfItemAtPath:filePath error:NULL] fileSize];
//	AMCDebug(@"Size of file: %@:\n%lld Bytes", filePath, fileSize);
	
	if (fileSize >= 0xFFFFFFFF)
	{
		AMCDebug(@"Error, file %@ too large", filePath);
		isOK = NO;
	}
	
	// open()
	if (isOK)
	{
		fd = open([filePath UTF8String], O_RDONLY);
		if (fd < 0)
		{
			AMCDebug(@"Failed to open file %@", filePath);
			isOK = NO;
		}
	}
	
	// mmap()
	if (isOK)
	{
		cFileCxt = mmap(NULL, (size_t)fileSize, PROT_READ, MAP_PRIVATE, fd, 0);
		if (MAP_FAILED == cFileCxt)
		{
			int errCopy = errno;
			AMCDebug(@"Failed to map file %@: %s", filePath, strerror(errCopy));
			isOK = NO;
		}
	}
	
	
	// calculate MD5 file
	if (isOK)
	{
		MD5((unsigned char*)cFileCxt, (unsigned int)fileSize, cMd5Value);
		ret = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			   cMd5Value[0], cMd5Value[1], cMd5Value[2], cMd5Value[3],
			   cMd5Value[4], cMd5Value[5], cMd5Value[6], cMd5Value[7],
			   cMd5Value[8], cMd5Value[9], cMd5Value[10], cMd5Value[11],
			   cMd5Value[12], cMd5Value[13], cMd5Value[14], cMd5Value[15]];
	}
	
	
	// close()
	if (fd > 0)
	{
		close(fd);
		fd = 0;
	}
	
	return ret;
}

- (void)_setProgressIdentifierWithIndex:(NSUInteger)index of:(NSUInteger)amount
{
	double value = ((double)index) / ((double)amount) * 100.0;
	
	if ([AMCTools isInMainThread])
	{
		[_progress setDoubleValue:value];
	}
	else
	{
		[self performSelectorOnMainThread:@selector(_setProgressDoubleNumber:)
									withObject:[NSNumber numberWithDouble:value]
								 waitUntilDone:NO];
	}
}

- (void)_setProgressDoubleNumber:(NSNumber*)doubleNumber
{
	[_progress setDoubleValue:[doubleNumber doubleValue]];
}


@end
