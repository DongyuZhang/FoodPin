//
//  DiscoverTableViewController.swift
//  FoodPin
//
//  Created by Dongyu Zhang on 10/8/18.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {

    var restaurants: [CKRecord] = []
    
    //Add a Spinner to reduce perceived waiting time
    var spinner = UIActivityIndicatorView()
    
    private var imageCache = NSCache<CKRecordID, NSURL>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spinner.activityIndicatorViewStyle = .gray
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        //Define the layout constraint for the spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150.0),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        //Activate the Spinner
        spinner.startAnimating()
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //Configure Navigation Bar Appearance
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Rubik-Meduim", size: 40.0){
            navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor(red: 231, green: 76, blue: 60),
                NSAttributedStringKey.font: customFont
            ]
        }
        fetchRecordsFromCloud()
        
        //pull to refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: UIControlEvents.valueChanged)
    }

    @objc func fetchRecordsFromCloud() {
        // Remove existing records before refreshing
        restaurants.removeAll()
        tableView.reloadData()
        
        //Fetch Data using convenience API
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        //Create the Query Operation with the query
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name", "type", "location", "phone", "description"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50
        queryOperation.recordFetchedBlock = {
            (record) -> Void in
            self.restaurants.append(record)
        }
        queryOperation.queryCompletionBlock = {
            (cursor, error) -> Void in
            if let error = error {
                print("Failed to get data from iCloud - \(error.localizedDescription)")
                return
            }
            print("Completed the download of cloud data")
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if let refreshControl = self.refreshControl{
                    if refreshControl.isRefreshing{
                        refreshControl.endRefreshing()
                    }
                }
                self.spinner.stopAnimating()
            }
        }
        
        publicDatabase.add(queryOperation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiscoverTableViewCell.self), for: indexPath) as! DiscoverTableViewCell

        // Configure the cell...
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let restaurant = restaurants[indexPath.row]
        cell.nameLabel.text = restaurant.object(forKey: "name") as? String
        cell.typeLabel.text = restaurant.object(forKey: "type") as? String
        cell.locationLabel.text = restaurant.object(forKey: "location") as? String
        cell.phoneLabel.text = restaurant.object(forKey: "phone") as? String
        cell.descriptionLabel.text = restaurant.object(forKey: "description") as? String
        /*
        if let image = restaurant.object(forKey: "image"), let imageAsset = image as? CKAsset{
            if let imageData = try? Data.init(contentsOf: imageAsset.fileURL){
                cell.imageView?.image = UIImage(data: imageData)
            }
        }
         */
        // Lazy Loading images
        // set default image
        cell.featuredImageView.image = UIImage(named: "photo")
        
        // check if this image can be found from cache
        if let imageFileURL = imageCache.object(forKey: restaurant.recordID){
            //fetch image from cache
            print("Get Image from cache")
            if let imageData = try?Data.init(contentsOf: imageFileURL as URL){
                cell.featuredImageView.image = UIImage(data: imageData)
            }
        }
        else{
            // fetch images from cloud in background
            let publicDatabase = CKContainer.default().publicCloudDatabase
            let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [restaurant.recordID])
            fetchRecordsImageOperation.desiredKeys = ["image"]
            fetchRecordsImageOperation.queuePriority = .veryHigh
            fetchRecordsImageOperation.perRecordCompletionBlock = {
                (record, recordID, error) -> Void in
                if let error = error{
                    print("Failed to get restaurant image: \(error.localizedDescription)")
                    return
                }
                if let restaurantRecord = record, let image = restaurantRecord.object(forKey: "image"), let imageAsset = image as? CKAsset{
                    if let imageData = try?Data.init(contentsOf: imageAsset.fileURL){
                        // replace the placeholder image with the retreived image
                        DispatchQueue.main.async {
                            cell.featuredImageView.image = UIImage(data: imageData)
                            cell.setNeedsLayout()
                        }
                        
                        //add retrieved image to Cache
                        self.imageCache.setObject(imageAsset.fileURL as NSURL, forKey: restaurant.recordID)
                    }
                }
                
            }
            publicDatabase.add(fetchRecordsImageOperation)
        }
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
