//
//  ProfileViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Horatious on 1/21/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {

    @IBOutlet weak var mainFeedBtn: UIButton!
    @IBOutlet weak var friendsBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(PFUser.currentUser()?.objectId)")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mainFeedBtnPressed(sender: AnyObject) {
    
        self.performSegueWithIdentifier("goToMainFeed", sender: self)
    }

    @IBAction func friendsBtnPressed(sender: AnyObject) {
    self.performSegueWithIdentifier("goToFriends", sender: self)
    }
    
    @IBAction func cameraBtnPressed(sender: AnyObject) {
        
        self.performSegueWithIdentifier("goToPostImage", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goToPostImage" {
            
            print("Success")
            
        } else if segue.identifier == "goToFriends" {
            let nav = segue.destinationViewController as! UINavigationController
            let destinationVC = nav.topViewController as! TableViewController
            destinationVC.currentUser = (PFUser.currentUser()?.objectId)!
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
