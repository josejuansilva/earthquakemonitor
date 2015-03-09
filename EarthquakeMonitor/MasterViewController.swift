//
//  MasterViewController.swift
//  EarthquakeMonitor
//
//  Created by Jose Juan Silva Gamiño on 05/03/15.
//  Copyright (c) 2015 Jose Juan Silva Gamiño. All rights reserved.
//
import UIKit
class MasterViewController: UITableViewController {
    var detailViewController: DetailViewController? = nil
    var objects = NSMutableArray()
    let model = QuakeModel()
    var quakes = [Quake]()
    let colors: [UIColor] = [UIColor(red: 0x66/255, green: 0x0FF/255, blue: 0x00/255, alpha: 1.0),
                            UIColor(red: 0x55/255, green: 0xD4/255, blue: 0x00/255, alpha: 1.0),
                            UIColor(red: 0xCC/255, green: 0x0FF/255, blue: 0x00/255, alpha: 1.0),
                            UIColor(red: 0x00/255, green: 0x80/255, blue: 0x00/255, alpha: 1.0),
                            UIColor(red: 0xFF/255, green: 0xFF/255, blue: 0x00/255, alpha: 1.0),
                            UIColor(red: 0xFF/255, green: 0xCC/255, blue: 0x00/255, alpha: 1.0),
                            UIColor(red: 0xFF/255, green: 0x066/255, blue: 0x00/255, alpha: 1.0),
                            UIColor(red: 0xFF/255, green: 0x002A/255, blue: 0x2A/255, alpha: 1.0),
                            UIColor(red: 0xFF/255, green: 0x00/255, blue: 0x00/255, alpha: 1.0),
                            UIColor(red: 0x80/255, green: 0x00/255, blue: 0x00/255, alpha: 1.0)]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshDataInvokedbyButton")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        model.getData({data, error -> Void in
            if (data != nil) {
                self.parseData(data)
                self.model.saveFile(data)
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            } else {
                if let dataFromFile = self.model.loadFile(){
                    self.parseData(dataFromFile)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showDataError("Using Stored Data",  detail: "Please Check Your Internet Connection")
                        self.tableView.reloadData()
                    })
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showDataError("Error Getting Data",  detail: "Please Check Your Internet Connection")
                    }) //end of not internet and not file
                }// end of not internet
             }
        })
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshDataInvokedbyPull"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    } //end of viewdidload
   
    func showDataError(title: String, detail: String){
        let alertController = UIAlertController(title: title, message: detail, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
  
    }
    func refreshDataInvokedbyButton() {
        refreshData(byPullToRefresh: false)
    }
    
    func refreshDataInvokedbyPull() {
        refreshData(byPullToRefresh: true)
    }
    
    func refreshData(byPullToRefresh: Bool = false){
        model.getData({data, error -> Void in
            if (data != nil) {
                self.quakes.removeAll()
                self.parseData(data)
                self.model.saveFile(data)
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    if (byPullToRefresh) {
                        self.refreshControl?.endRefreshing()
                    }
                })
            } else {
                if let dataFromFile = self.model.loadFile(){
                    self.quakes.removeAll()
                    self.parseData(dataFromFile)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showDataError("Using Stored Data",  detail: "Please Check Your Internet Connection")
                        self.tableView.reloadData()
                        if (byPullToRefresh) {
                            self.refreshControl?.endRefreshing()
                        }
                    })
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showDataError("Error Getting Data",  detail: "Please Check Your Internet Connection")
                    }) //end of not internet and not file
                }// end of not internet
            }
        })
   }
    
    
    func parseData(data: NSData){
        let json = JSON(data: data)
        let appArray = json["features"].arrayValue
        for appDict in appArray {
            var quake = Quake()
            quake.place = appDict["properties"]["place"].stringValue
            quake.mag =  appDict["properties"]["mag"].stringValue
            quake.time = appDict["properties"]["time"].stringValue
            quake.longitude = appDict["geometry"]["coordinates"][0].stringValue
            quake.latitude = appDict["geometry"]["coordinates"][1].stringValue
            quake.depth = appDict["geometry"]["coordinates"][2].stringValue
            self.quakes.append(quake)
        }
    }

    
    // MARK: - Segues
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            let cell = sender as UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)!
                let object = quakes[indexPath.row]
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     //   return objects.count
        return quakes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let location = quakes[indexPath.row].place
        let mag = quakes[indexPath.row].mag
        let magnitude = NSString(format:"%.2f", (mag! as NSString).doubleValue)
        cell.textLabel!.text = location!
        cell.detailTextLabel!.text = "\(magnitude) degrees"
        let magnitudeAsDouble = (mag! as NSString).doubleValue
        let intMagnitude = Int(floor(magnitudeAsDouble))
        cell.backgroundColor = colors[intMagnitude]
        return cell
    }
    
    
}

