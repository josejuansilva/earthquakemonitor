//
//  QuakeModel.swift
//  EarthquakeMonitor
//
//  Created by Jose Juan Silva Gamiño on 05/03/15.
//  Copyright (c) 2015 Jose Juan Silva Gamiño. All rights reserved.
//

import Foundation
class QuakeModel{
    let filemgr = NSFileManager.defaultManager()
    func getData(completionHandler: ((NSData!, NSError!) -> Void)!) -> Void {
        let url: NSURL = NSURL(string: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson")!
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                return completionHandler(nil, error)
            }
            else {
                return completionHandler(data , nil)
            }
        })
        task.resume()
    }
    
    func dataFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        return documentsDirectory.stringByAppendingPathComponent("earthquakesdata.json") as String
    }
    
    func saveFile (file:NSData){
        let path = dataFilePath()
        if filemgr.createFileAtPath(path, contents: file, attributes: nil) == false{
            println("failed to save file")
        }
        else{
            println("file saved")
        }
    }
    
    func loadFile()->NSData?{
        let path = dataFilePath()
        if let data = filemgr.contentsAtPath(path){
            println("data file readed")
            return data
        }
        else {
            println("could not read file")
            return nil
        }
    }
    
    
}