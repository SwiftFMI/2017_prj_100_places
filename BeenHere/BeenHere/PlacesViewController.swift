//
//  FirstViewController.swift
//  BeenHere
//
//  Created by Petko Haydushki on 15.12.17.
//  Copyright © 2017 Petko Haydushki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import StoreKit

//Facebook
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Bolts

//Google
import GoogleSignIn



class PlacesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, FUIAuthDelegate, GIDSignInDelegate,
GIDSignInUIDelegate{
    
    fileprivate(set) var authUI: FUIAuth?
    fileprivate var authStateDidChangeHandle: AuthStateDidChangeListenerHandle?
    
    func signed(in user: User) {
        Database.database().reference(withPath: "people/\(user.uid)")
            .updateChildValues(["profile_picture": user.photoURL?.absoluteString ?? "",
                                "full_name": user.displayName ?? "Anonymous",
                                "_search_index": ["full_name": user.displayName?.lowercased(),
                                                  "reversed_full_name": user.displayName?.components(separatedBy: " ")
                                                    .reversed().joined(separator: "")]])
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    var downloadedImage : UIImage = UIImage()
    var data : Array = Array<UIImage>()
    
    @IBOutlet weak var downloadImageView: UIImageView!
    
    @IBOutlet weak var placesTableView: UITableView!
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIFacebookAuth(),
            ]
        
        // Auth Here
        let authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.providers = providers
        authUI?.delegate = self as FUIAuthDelegate
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID;
        GIDSignIn.sharedInstance().delegate = self;
        GIDSignIn.sharedInstance().uiDelegate = self;
        print("viewDidLoad")
        
        print("viewDidLoad \(Auth.auth().currentUser?.displayName)")
        downloadImagesFromStorage(s:self)
        
        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.size.width/2.0
        self.profilePhoto.layer.masksToBounds  = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        print("viewWillAppear \(Auth.auth().currentUser?.displayName)")
//        let firebaseAuth = Auth.auth()
//        do {
//            try firebaseAuth.signOut()
//        } catch let signOutError as NSError {
//            print ("Error signing out: %@") //,signOutError)
//        }
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        
        if (FBSDKAccessToken.current()) != nil
        {
            print("User");
            
            
            print("User displayName %@", user?.displayName! as Any)
            
            let task = URLSession.shared.dataTask(with: (user?.photoURL)!) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async() {    // execute on main thread
                    self.profilePhoto.image = UIImage(data: data)
                }
            }
            
            task.resume()
            print("\(FBSDKAccessToken.current().userID)")
            print("\(FBSDKAccessToken.current().tokenString)")
            print("\(FBSDKAccessToken.current().appID)")
            print("\(FBSDKAccessToken.current().debugDescription)")
        }
        else
        {
            print("User NOT");
        }
        switch error {
        case .some(let error as NSError) where UInt(error.code) == FUIAuthErrorCode.userCancelledSignIn.rawValue:
            print("User cancelled sign-in")
        case .some(let error as NSError) where error.userInfo[NSUnderlyingErrorKey] != nil:
            print("Login error: \(error.userInfo[NSUnderlyingErrorKey]!)")
        case .some(let error):
            print("Login error: \(error.localizedDescription)")
        case .none:
            if let user = user {
                signed(in: user)
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        if Auth.auth().currentUser != nil {
//            let appDelegateTemp = UIApplication.shared.delegate as? AppDelegate
//            appDelegateTemp?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
//            dismiss(animated: true, completion: nil)
//            return
//        }
        print("User \(Auth.auth().currentUser)")
//        authUI = FUIAuth.defaultAuthUI()
//        authUI?.delegate = self
//        authUI?.isSignInWithEmailHidden = true
//        let providers: [FUIAuthProvider] = [FUIGoogleAuth(), FUIFacebookAuth()]
//        authUI?.providers = providers
//        
//        let authViewController: UINavigationController? = authUI?.authViewController()
//        authViewController?.navigationBar.isHidden = true
//        present(authViewController!, animated: true, completion: nil)
    }
    

    //: MARK - TableView Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        print("didSelectRowAt \(indexPath)");
        
        if ((Auth.auth().currentUser) == nil)
        {
            let authUI = FUIAuth.defaultAuthUI()
            let authViewController = authUI?.authViewController()
            self.present(authViewController!, animated: true, completion: nil)
        }
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

func application(_ app: UIApplication, open url: URL,
                 options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
    let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
    if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
        return true
    }
    // other URL handling goes here.
    print("firstViewController::application")
    return false
}


func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
    // handle user and error as necessary
    if error != nil {
        
        print("error: \(error?.localizedDescription)")
        
    } else {
        
        print("user is in")
        
    }
    print("TEST")
    print("%@",User.description())
    print("%@",error?.localizedDescription)

}

func downloadImagesFromStorage (s : PlacesViewController)-> Void {
    
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
            s.data.insert(UIImage(data: data!)!, at: (s.data.count))
            if (s.data.count == 2)
            {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            s.placesTableView.reloadData()
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
            s.data.insert(UIImage(data: data!)!, at: (s.data.count))
            if (s.data.count == 2)
            {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            s.placesTableView.reloadData()
        }
    }
    s.title = "Places"
    if (Auth.auth().currentUser != nil)
    {
        s.usernameLabel.text = Auth.auth().currentUser?.displayName
        
        let task = URLSession.shared.dataTask(with: (Auth.auth().currentUser?.photoURL)!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() {    // execute on main thread
                s.profilePhoto.image = UIImage(data: data)
            }
        }
        task.resume()
    }
}

//https://firebasestorage.googleapis.com/v0/b/beenhere-ph.appspot.com/o/krushuna.jpg?alt=media&token=c7e39688-bfe9-4b9b-9b4c-32e8d8cf91cb

