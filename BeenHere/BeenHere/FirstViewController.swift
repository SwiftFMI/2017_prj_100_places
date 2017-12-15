//
//  FirstViewController.swift
//  BeenHere
//
//  Created by Petko Haydushki on 15.12.17.
//  Copyright © 2017 Petko Haydushki. All rights reserved.
//

import UIKit
import Firebase
import StoreKit

class FirstViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var downloadedImage : UIImage = UIImage()
    var data : Array = Array<UIImage>()
    
    @IBOutlet weak var downloadImageView: UIImageView!
    
    @IBOutlet weak var placesTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        
        let krushunaRef = storageRef.child("krushuna.jpg")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        krushunaRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
                print("Uh-oh, an error occurred! ")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            } else {
                // Data for "images/island.jpg" is returned
                print("Kryshuna")
                self.data.insert(UIImage(data: data!)!, at: (self.data.count))
                if (self.data.count == 2)
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                self.placesTableView.reloadData()   
            }
        }
        
        let alekoRef = storageRef.child("aleko.jpg")
        
        alekoRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
                print("Uh-oh, an error occurred! ")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            } else {
                // Data for "images/island.jpg" is returned
                print("Kryshuna")
                self.data.insert(UIImage(data: data!)!, at: (self.data.count))
                if (self.data.count == 2)
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                self.placesTableView.reloadData()
            }
        }
        
        self.title = "Places"
    }

    //: MARK - TableView Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        print("didSelectRowAt \(indexPath)");
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
        let myItem = data[indexPath.row] as UIImage!
        
        cell.imageView?.image = myItem
        
        return cell;
    }


}

//https://firebasestorage.googleapis.com/v0/b/beenhere-ph.appspot.com/o/krushuna.jpg?alt=media&token=c7e39688-bfe9-4b9b-9b4c-32e8d8cf91cb

