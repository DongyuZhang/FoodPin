//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by Dongyu Zhang on 9/24/2018.
//

import UIKit

class RestaurantDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var restaurant: Restaurant = Restaurant()
    
    // MARK: - View controller life style
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
