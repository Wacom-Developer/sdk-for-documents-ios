//
//  DirectoryWatcher.swift
//  SignProPDF
//
//  Created by Joss Giffard-Burley on 15/01/2015.
//  Copyright (c) 2015 Wacom. All rights reserved.
//

import UIKit

//============================================================================================================
/*

`DirectoryWatcher` monitors a directory on the file system and calls the provided block when the underlying 
filesystem changes

*/
@objc open class DirectoryWatcher: NSObject {
    //========================================================================================================
    // MARK: Private properties
    //========================================================================================================
    
    /// The polling interval
    fileprivate let pollInterval: TimeInterval = 0.2
    
    /// Directory retry count
    fileprivate let retryCount = 10
    
    /// Dispatch source used for directory monitor
    fileprivate var source: DispatchSourceFileSystemObject?
    
    /// Queue to use for monitor
    fileprivate var queue: DispatchQueue?
    
    /// Flag to indicate current state of the monitored dir
    open var directoryChanging = false
    
    /// The path to watch
    fileprivate var watchedPath: String = ""
    
    /// Block to call when change is detected
    fileprivate var callback: (() -> ())?
    
    /// Number of retries remaining
    fileprivate var retriesLeft = 0
    
    //========================================================================================================
    // MARK: Class methods
    //========================================================================================================
    
    /**
    Returns a DirectoryWatcher object and begins to monitor the path if startImmediately is true
    
    - parameter watchPath:        The directory path to monitor
    - parameter startImmediately: If this is true then start to monitor the directory immediately
    - parameter callback:         The block to call when a change is detected
    
    - returns: A newly created DirectoryWatcher object
    */
    open class func directoryWatcher(_ watchPath: String, startImmediately: Bool = true, callback: @escaping () -> ()) -> DirectoryWatcher {
        let rv = DirectoryWatcher(path: watchPath)
        rv.callback = callback
        
        if startImmediately {
            _ = rv.startWatching()
        }
        
        return rv
    }

    //========================================================================================================
    // MARK: Init methods
    //========================================================================================================
    
    /**
    Init with path
    
    - parameter path: The path to monitor
    */
    public init(path: String) {
        watchedPath = path
        queue = DispatchQueue(label: "DirectoryWatcherQueue", attributes: [])
    }    
    
    /**
    Dealloc
    */
    deinit {
        _ = stopWatching()
        callback = nil
    }
    
    //========================================================================================================
    // MARK: Public instance methods
    //========================================================================================================
    
    /**
    Start monitoring the watch directory
    
    - returns: true if started watching, false if already watching directory
    */
    open func startWatching() -> Bool {
        if source != nil {
            return false
        }
        
        let fileBuff = UnsafeMutablePointer<Int8>.allocate(capacity: 16384)
        (URL(fileURLWithPath: watchedPath) as NSURL).getFileSystemRepresentation(fileBuff, maxLength: 16384)
        let fd = open(fileBuff, O_EVTONLY)
        
        fileBuff.deallocate(capacity: 16384)
        if fd < 0 {
            return false
        }
        
        let cleanup:()->() = {
            close(Int32(fd))
        }
        
        let q = DispatchQueue.global(qos: .utility)

        
        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: DispatchSource.FileSystemEvent.write, queue: q)
        
        if source == nil {
            cleanup()
            return false
        }
        
        weak var weakSelf = self
        
        source!.setEventHandler(handler: { () -> Void in
            if let s = weakSelf {
                s.directoryDidChange()
            }
        })
        
        source!.setCancelHandler(handler: cleanup)
        source!.resume()
        
        return true
    }
    
    /**
    Stop monitoring the watch directory
    
    - returns: true if stopped watching false is not watching to start with
    */
    open func stopWatching() -> Bool {
        if source != nil {
            source!.cancel()
            source = nil
            return true
        }
        return false
    }
    
    /**
    Returns the path that is currently being monitored
    
    - returns: The monitored path
    */
    open func watchingPath() -> String {
        return watchedPath
    }
    
    //========================================================================================================
    // MARK: Private instance methods
    //========================================================================================================

    /**
    Returns the array of file hashes for the monitored directory
    
    - returns: An array of file hashes for the files within the current directory
    */
    fileprivate func directoryMetadata() -> [String] {
        let fm = FileManager.default
        let contents = (try! fm.contentsOfDirectory(atPath: watchedPath)) 
        
        var directoryMeta = [String]()
    
        let baseDir = URL(fileURLWithPath: watchedPath)
        for fileName in contents {
            let filePath = baseDir.appendingPathComponent(fileName)
            var fileSize = Int32(0)

            if let fileAttributes = try? fm.attributesOfItem(atPath: filePath.path) {
                if let f = (fileAttributes[FileAttributeKey.size] as AnyObject).int32Value {
                    fileSize = f
                }
            }
            
            let fileHash = NSString(format: "%@%ld", fileName, fileSize)
            directoryMeta.append(fileHash as String)

        }
        
        return directoryMeta
    }

    /**
    Checks for changes in the directory after the specified delay
    
    - parameter timeInterval: The time to wait
    */
    fileprivate func checkChangesAfterDelay(_ timeInterval: TimeInterval) {
        let directoryMeta = directoryMetadata()
        weak var weakSelf = self
        
        let poptime = DispatchTime.now() + Double(20000000) / Double(NSEC_PER_SEC)
        queue!.asyncAfter(deadline: poptime) { () -> Void in
            if let s = weakSelf {
                s.pollDirectoryForChangesWithMetadata(directoryMeta)
            }
        }
    }
    
    /**
    Poll the watched directory with the provided metadata
    
    - parameter oldDirectoryMetadata: The saved metadata
    */
    fileprivate func pollDirectoryForChangesWithMetadata(_ oldDirectoryMetadata: [String]) {
        let newDirectoryData = directoryMetadata()
       
        directoryChanging = !oldDirectoryMetadata.elementsEqual(newDirectoryData)
        
        // Reset retries if it's still changing
        retriesLeft = directoryChanging ? retryCount : retriesLeft
        
        if directoryChanging || 0 < retriesLeft {
            retriesLeft -= 1
            checkChangesAfterDelay(pollInterval)
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
                if let cb = self.callback {
                    cb()
                }
            })
        }
    }
    
    /**
    This is called when the directory changes
    */
    fileprivate func directoryDidChange() {
        if !directoryChanging {
            directoryChanging = true
            retriesLeft = retryCount
            checkChangesAfterDelay(pollInterval)
        }
    }
}

