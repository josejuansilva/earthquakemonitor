//
//  DetailViewController.swift
//  EarthquakeMonitor
//
//  Created by Jose Juan Silva Gamiño on 05/03/15.
//  Copyright (c) 2015 Jose Juan Silva Gamiño. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var magnitude: UILabel!
    @IBOutlet weak var depth: UILabel!
    @IBOutlet weak var date: UILabel!
    var quake =  Quake()
    var detailItem: AnyObject? {
        didSet {
            quake = detailItem as Quake
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let quake = detailItem as? Quake{
            let latitude = NSString(format:"%.2f", (quake.latitude! as NSString).doubleValue)
            let longitude = NSString(format:"%.2f", (quake.longitude! as NSString).doubleValue)
            let magnitude = NSString(format:"%.2f", (quake.mag! as NSString).doubleValue)
            let depth = NSString(format:"%.2f", (quake.depth! as NSString).doubleValue)
            let timestamp = ((quake.time! as NSString).doubleValue) / 1000
            let date = NSDate(timeIntervalSince1970:timestamp)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm:ss a"
            let strDate = dateFormatter.stringFromDate(date)
            self.location.text = quake.place!
            self.latitude.text = "Latitude: \(latitude)"
            self.longitude.text = "Longitude: \(longitude)"
            self.magnitude.text = "Magnitude: \(magnitude) degrees"
            self.depth.text = "Depth: \(depth) Km"
            self.date.text = "Date: " + strDate
            let lat = (quake.latitude! as NSString).doubleValue
            let lon = (quake.longitude! as NSString).doubleValue
            let location = CLLocationCoordinate2D(
                latitude: lat,
                longitude: lon
            )
            let span = MKCoordinateSpanMake(0.5, 0.5)
            let region = MKCoordinateRegion(center: location, span: span)
            self.mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.setCoordinate(location)
            annotation.title = "Location: \(quake.place!)"
            annotation.subtitle = "Magnitude: \(quake.mag!)"
            mapView.addAnnotation(annotation)
            formatLabelsText()
        }
  
        
    }
    func formatLabelsText(){
        let blueTextAttribute = [NSForegroundColorAttributeName: UIColor.blueColor()]
        
        var string = latitude.text! as NSString
        var attributedLatitudeString = NSMutableAttributedString(string: string)
        attributedLatitudeString.addAttributes(blueTextAttribute, range: string.rangeOfString("Latitude:"))
        latitude.attributedText = attributedLatitudeString
        
        string = longitude.text! as NSString
        var attributedLongitudeString = NSMutableAttributedString(string: string)
        attributedLongitudeString.addAttributes(blueTextAttribute, range: string.rangeOfString("Longitude:"))
        longitude.attributedText = attributedLongitudeString
        
        string = magnitude.text! as NSString
        var attributedMagnitudeString = NSMutableAttributedString(string: string)
        attributedMagnitudeString.addAttributes(blueTextAttribute, range: string.rangeOfString("Magnitude:"))
        magnitude.attributedText = attributedMagnitudeString
        
        string = depth.text! as NSString
        var attributedDepthString = NSMutableAttributedString(string: string)
        attributedDepthString.addAttributes(blueTextAttribute, range: string.rangeOfString("Depth:"))
        depth.attributedText = attributedDepthString
        
        
        string = date.text! as NSString
        var attributedDateString = NSMutableAttributedString(string: string)
        attributedDateString.addAttributes(blueTextAttribute, range: string.rangeOfString("Date:"))
        date.attributedText = attributedDateString
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

