//
//  ProfileViewController.swift
//  BeenHere
//
//  Created by Petko Haydushki on 18.12.17.
//  Copyright © 2017 Petko Haydushki. All rights reserved.
//

import UIKit

import Firebase
import FirebaseAuthUI

import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI

//Facebook
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Bolts

//Google
import GoogleSignIn



class ProfileViewController: UIViewController, FUIAuthDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    var data : Array = ["My Places","Wishlist","Share BeenHere","Sign out"]
    @IBOutlet weak var profileTableView: UITableView!
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
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var profileNameLabel: UILabel!
    
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
        
//        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID;
//        GIDSignIn.sharedInstance().delegate = self;
//        GIDSignIn.sharedInstance().uiDelegate = self;
//        print("viewDidLoad")
        
        
        
        if (Auth.auth().currentUser != nil)
        {
            // set sign out button 
        }
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2.0
        self.profileImageView.layer.masksToBounds  = true
        self.profileImageView.layer.borderColor = UIColor.black.cgColor
        self.profileImageView.layer.borderWidth = 2.0
        
        dowloadProfileInfo()
        
        self.title = "Places"
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ((Auth.auth().currentUser) == nil)
        {
            let authUI = FUIAuth.defaultAuthUI()
            let authViewController = authUI?.authViewController()
            self.present(authViewController!, animated: true, completion: nil)
            data = ["My Places","Wishlist","Share BeenHere","Sign in"]

        }
        else
        {
            data = ["My Places","Wishlist","Share BeenHere","Sign out"]
        }
    }
    
    func dowloadProfileInfo() -> Void {
        if (Auth.auth().currentUser != nil)
        {
            self.profileNameLabel.text = Auth.auth().currentUser?.displayName
            if (Auth.auth().currentUser?.photoURL != nil)
            {
                let task = URLSession.shared.dataTask(with: (Auth.auth().currentUser?.photoURL)!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    DispatchQueue.main.async() {    // execute on main thread
                        self.profileImageView.image = UIImage(data: data)
                    }
                }
                task.resume()
            }
        }
    }
    
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        
        if (FBSDKAccessToken.current()) != nil
        {
            print("User");
            
            dowloadProfileInfo()
            
            print("User displayName %@", user?.displayName! as Any)
            
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
    
    //MARK: - TableView Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        tableViewCellTapped(indexPathRow: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        
        cell.textLabel?.text = data[indexPath.row]
        
        return cell;
    }

    func tableViewCellTapped(indexPathRow : Int) -> Void {
        
        var message : String
        
        switch indexPathRow {
        case 0:
            message = "\("My Places") to be implemented"
        case 1:
            message = "\("Wishlist") to be implemented"
        case 2:
            message = "\("Share BeenHere") to be implemented"
        case 3:
            message = "Are you sure you want to sign out?"
        default:
            message = "What is this?"
        }
        let alert = UIAlertController(title: data[indexPathRow], message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        if (indexPathRow == 3)
        {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Sign out", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("Signing Out.")
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
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



