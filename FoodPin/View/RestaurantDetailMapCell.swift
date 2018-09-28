//
//  RestaurantDetailMapCell.swift
//  FoodPin
//
//  Created by Dongyu Zhang on 9/26/18.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import MapKit

class RestaurantDetailMapCell: UITableViewCell {

    @IBOutlet var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(location: String){
        //Get Location
        let geoCoder = CLGeocoder()
        
        print(location)
        geoCoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let placemarks = placemarks{
                //Get the first Placemark returned
                let placemark = placemarks[0]
                
                //Add annotation
                let annotation = MKPointAnnotation()
                if let location = placemark.location{
                    annotation.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    //set up zoom level
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 250, 250)
                    self.mapView.setRegion(region, animated: false)
                }
            }
        }
        
    }

}
