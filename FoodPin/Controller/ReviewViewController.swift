//
//  ReviewViewController.swift
//  FoodPin
//
//  Created by Dongyu Zhang on 9/28/18.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {

    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBOutlet var rateButtons: [UIButton]!
    
    @IBOutlet var closeButton: UIButton!
    
    var restaurant : RestaurantMO!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let restaurantImage = restaurant.image {
            backgroundImageView.image = UIImage(data: restaurantImage as Data)
        }
        
        // Applying the blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        let moveRightTransform = CGAffineTransform.init(translationX: 600, y: 0)
        let scaleUpTransform = CGAffineTransform.init(scaleX: 5.0, y: 5.0)
        let moveScaleTransform = scaleUpTransform.concatenating(moveRightTransform)

        // Make the button invisible and move off the screen
        for rateButton in rateButtons {
            rateButton.transform = moveScaleTransform
            rateButton.alpha = 0
        }
        
        let moveUpTransform = CGAffineTransform.init(translationX: 0, y: -800)
        closeButton.transform = moveUpTransform
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.4, delay: 0.15, options: [], animations: {
            for index in 0...self.rateButtons.count - 1{
                UIView.animate(withDuration: 0.4, delay: 0.1 + 0.05 * Double(index), options: [], animations: {
                    self.rateButtons[index].transform = .identity
                    self.rateButtons[index].alpha = 1.0
                }, completion: nil)
            }
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.5, options: [], animations: {
            self.closeButton.transform = .identity
        }, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
