//
//  FeedViewController.swift
//  ParseStarterProject
//
//  Created by will ullian on 6/23/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

@available(iOS 8.0, *)
class ProfileTableViewController: UITableViewController {
    
    var userImage = [PFFile]()
    var reviewMessage = [""]
    
    @IBAction func friends(sender: AnyObject) {
        performSegueWithIdentifier("goToFriendsVC", sender: self)
    }
    @IBAction func mainFeed(sender: AnyObject) {
        performSegueWithIdentifier("goToMainFeedVC", sender: self)
        print("Print")
    }
    @IBAction func logOut(sender: AnyObject) {
        performSegueWithIdentifier("goToLogoutVC", sender: self)
        PFUser.logOutInBackground()
    }
    @IBAction func cameraBtn(sender: AnyObject) {
        performSegueWithIdentifier("goToPostImageVC", sender: self)
    }
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    let reuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.setToolbarHidden(false, animated: true)
        
        if PFUser.currentUser() == nil {
            PFUser.logInWithUsernameInBackground("test", password: "pass")
        }
        
        print(PFUser.currentUser()?.objectId)
        
        tableView.allowsSelection = false

        tableView.backgroundView = UIImageView(image: UIImage(named: "GoCloBackG.png"))

        let query = PFQuery(className: "Post")
        query.whereKey("userId", equalTo: (PFUser.currentUser()?.objectId)!)
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                print(error)
            } else if let objects = objects {
                for object in objects {
                    self.userImage.append(object["imageFile"] as! PFFile)
                    if let message = object["comment"] as? Array<String> {
                        for (var i = 0; i < message.count; i++) {
                            if message[i] == "" {
                                self.reviewMessage.append("")
                            } else {
                            self.reviewMessage.append(message[i])
                            }
                             
                        }

                    }
                    self.tableView.reloadData()
                }
            }
            self.reviewMessage.removeFirst()
        }
        
    print("Count \(userImage.count)")
    print(self.reviewMessage)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.userImage.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! cell
        myCell.backgroundColor = UIColor.clearColor()
        
        var currentRow = indexPath.row
        
        userImage[indexPath.row].getDataInBackgroundWithBlock { (data, error) -> Void in
            if error != nil {
                print(error)
            } else if let downloadedImage = UIImage(data: data!) {
                myCell.userImage.image = downloadedImage
            }
        }
        if currentRow <= self.reviewMessage.count {
        myCell.reviewLabel.text = self.reviewMessage[currentRow]
        } else {
            currentRow = self.reviewMessage.count
        }
        
        print("message \(self.reviewMessage[indexPath.row])")
        
        
        return myCell
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
