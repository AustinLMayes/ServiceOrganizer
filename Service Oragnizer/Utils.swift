//
//  Utils.swift
//  Test
//
//  Created by Austin Mayes on 5/24/15.
//  Copyright (c) 2015 Austin Mayes. All rights reserved.
//

import Foundation
import AppKit

func stateToBool(value: NSCellStateValue) -> Bool {
    return value == NSOnState
}

func uniqueFileName(container:NSURL, desiredName:NSString, ext:NSString, manager:NSFileManager) -> String {
    var count:NSInteger = 1
    var name = desiredName
    while manager.fileExistsAtPath(container.path! + "/" + (name + ext).stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)) {
        count++
        name = desiredName + " " + count.description
    }
    
    return name + ext
}

func dateToFNString(date: NSDate, useMeridiem: Bool) -> String {
    var dateFormatter:NSDateFormatter = NSDateFormatter()
    
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
    
    var dtString = dateFormatter.stringFromDate(date).stringByReplacingOccurrencesOfString("/", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
    
    var dtStringArray = split(dtString) {$0 == " "}
    
    var dateString:String = removeLastCharFromString(dtStringArray.first!)
    var meridiem:String = dtStringArray.last!
    
    var fullString = (dateString + (useMeridiem ? (" (" + meridiem + ")") : ""))
    return fullString
}

func removeLastCharFromString(string: String) -> NSString {
    var stringLength = string.utf16Count
    var substringIndex = stringLength - 1
    return string.substringToIndex(advance(string.startIndex, substringIndex))
}

func groupFilesByDate(files: [NSURL]!, manager:NSFileManager) -> NSDictionary {
    // Mutable so we can add things
    var filesByDate:NSMutableDictionary = NSMutableDictionary()
    
    for file:NSURL in files {
        // File Creation Date
        var attributes:NSDictionary = manager.attributesOfItemAtPath(file.path!, error: nil)!
        var creationDate:NSDate = attributes.fileCreationDate()!
        
        // Get day without time for sorting
        var fileDay:NSDate = dateAtMidnight(creationDate)
        
        var arrayForDay:NSMutableArray? = filesByDate.objectForKey(fileDay) as? NSMutableArray
        
        if arrayForDay == nil {
            // Not in dictionary
            arrayForDay = NSMutableArray()
            filesByDate.setObject(arrayForDay!, forKey: fileDay)
        }
        arrayForDay?.addObject(file)
    }
    
    // We're done, make it immutable.
    return filesByDate.copy() as NSDictionary
}

func renameFiles(filesToRename:NSDictionary, manager:NSFileManager, fileTittle:NSString, ext:NSString) {
    for fileWithName in filesToRename {
        var file:NSURL = fileWithName.key as NSURL
        var container:NSURL = file.URLByDeletingLastPathComponent!
        var uncheckedName:NSString = fileWithName.value as NSString
        var uniqueName:NSString = uniqueFileName(container, fileTittle + " " + uncheckedName, ext, manager).stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        var newURL:NSURL = container.URLByAppendingPathComponent(uniqueName)
        
        manager.moveItemAtURL(file, toURL: newURL, error: nil)
    }
}

func dateAtMidnight(date: NSDate) -> NSDate {
    var cal:NSCalendar = NSCalendar.currentCalendar()
    
    var timeZone:NSTimeZone = NSTimeZone.systemTimeZone()
    cal.timeZone = timeZone
    
    var flags: NSCalendarUnit = .DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit
    var componenets:NSDateComponents = cal.components(flags, fromDate: date)
    
    // 00:00:00
    componenets.hour = 0
    componenets.minute = 0
    componenets.second = 0
    
    var result:NSDate = cal.dateFromComponents(componenets)!
    return result
}

func shoulUseMeridiem(filesOnDay: NSInteger) -> Bool {
    if filesOnDay >= 2 {
        return true
    } else {
        return false
    }
}

func createFileToNameDict(filesByDate: NSDictionary, manager:NSFileManager) -> NSDictionary {
    var filesWithNames:NSMutableDictionary = NSMutableDictionary()
    
    for filesByDay in filesByDate {
        var files:NSMutableArray = filesByDay.value as NSMutableArray
        
        for file in files {
            var fileCast:NSURL = file as NSURL
            // File Creation Date
            var attributes:NSDictionary = manager.attributesOfItemAtPath(fileCast.path!, error: nil)!
            var creationDate:NSDate = attributes.fileCreationDate()!
            
            var fileName:NSString = dateToFNString(creationDate, shoulUseMeridiem(files.count))
            
            filesWithNames.setObject(fileName, forKey: fileCast)
        }
    }
    return filesWithNames.copy() as NSDictionary
}

func loopThroughDirectoryAndCreateFileArray(path: NSURL, recursive: Bool, type: NSString, manager: NSFileManager) -> [NSURL]! {
    var resultArray: [NSURL]! = []
    
    var options = NSDirectoryEnumerationOptions()
        
    if !recursive {
        options = NSDirectoryEnumerationOptions.SkipsHiddenFiles | NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants
    } else {
        options = NSDirectoryEnumerationOptions.SkipsHiddenFiles
    }
        
    var files:NSDirectoryEnumerator = manager.enumeratorAtURL(path, includingPropertiesForKeys: [NSURLNameKey], options: options, errorHandler: nil)!
    
    
    
    for file in files.allObjects {
        var cast:NSURL = file as NSURL
        var fileName:AnyObject?
        cast.getResourceValue(&fileName, forKey: NSURLNameKey, error: nil)
        if fileName?.pathExtension == type.lowercaseString {
            resultArray.append(file as NSURL)
        }
    }

    return resultArray
}
