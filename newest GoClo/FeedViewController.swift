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
class FeedViewController: UITableViewController {
    
    var messages = [String]()
    var usernames = [String]()
    var imageFiles = [PFFile]()
    var users = [String: String]()
    var imageReview = [String:Int]()
    
    var reviewedImages = [String]()
    var allImages = [String]()
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    let reuseIdentifier = "reuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        
        // turn buttons into labels and give them addTarget
        tableView.backgroundView = UIImageView(image: UIImage(named: "GoCloBackG.png"))
        
        let query = PFUser.query()
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if let users = objects {
                
                self.messages.removeAll(keepCapacity: true)
                self.users.removeAll(keepCapacity: true)
                self.imageFiles.removeAll(keepCapacity: true)
                self.usernames.removeAll(keepCapacity: true)
                
                for object in users {
                    if let user = object as? PFUser {
                        self.users[user.objectId!] = user.username
                    }
                }
            }
            
            let getFollowedUsersQuery = PFQuery(className: "followers")
            
            getFollowedUsersQuery.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!) //pfuser.currentuser().objectId
            
            getFollowedUsersQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                
                if let objects = objects {
                    
                    for object in objects {
                        
                        let followedUser = object["following"] as! String
                        
                        let query = PFQuery(className: "Post")
                        query.whereKey("userId", equalTo: followedUser)
                        query.orderByDescending("createdAt")
                        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                            if let objects = objects {
                                
                                for object in objects {
                                    
                                    self.allImages.append(object.objectId!)
                                    self.imageReview[object.objectId!] = object["Review"] as? Int
                                    self.messages.append(object["message"] as! String)
                                    
                                    self.imageFiles.append(object["imageFile"] as! PFFile)
                                    
                                    self.usernames.append(self.users[object["userId"] as! String]!)
                                    
                                    self.tableView.reloadData()
                                    
                                }
                                print("All: \(self.imageFiles.count)")
                            }
                        })
                    }
                }
            }
        })
        print("Reviewed: \(self.reviewedImages)")
        
    }
    
    // Drag the accept button over the image to give it the review (2 means accept)
    // Its possible to fix the issue by creating two arrays, one with all the images objectIds and one with only the reviewed image's objectIds, and check if the allImage array has the objectId of a reviewed image, and then if it does, it increments the allImage array by one to get the next objectId for the (query2.getObjectInBackgroundWithId) function, and order the queries by descending("createdAt") meaning each cell with each review would give each image its own review instead of all the images.
    
    func acceptDragged(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translationInView(self.view)
        let movingBtn = gesture.view!
        let screenWidth = self.view.bounds.width
        
        movingBtn.center.x = screenWidth-40 + translation.x
        movingBtn.center.y = 100 + translation.y
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            if movingBtn.center.x <= screenWidth-120 {
                
                movingBtn.hidden = true
                
                let query = PFQuery(className: "Post")
                query.orderByDescending("createdAt")
                query.getObjectInBackgroundWithId(self.allImages.first!, block: { (object, error) -> Void in
                    if error != nil {
                        print(error)
                    } else if let object = object {
                        
                        if self.imageReview[self.allImages.first!] == 0 {
                            
                            object["Review"] = 3
                            object.saveInBackground()
                            self.reviewedImages.append(object.objectId!)
                            print("Object Id \(object.objectId!)")
                            self.allImages.removeFirst()
                            print("allImages[0] again \(self.allImages[0])")
                            
                        }
                    }
                })
                print("Reviewed again: \(self.reviewedImages)")
                print("All again: \(self.allImages)")
                print("allImages[0] \(self.allImages[0])")
            }
            
        }
        
    }
    
    // Drag the neutral button over the image to give it the review (1 means neutral)
    
    func neutralDragged(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translationInView(self.view)
        let movingBtn = gesture.view!
        let screenWidth = self.view.bounds.width
        
        movingBtn.center.x = screenWidth-40 + translation.x
        movingBtn.center.y = 170 + translation.y
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            if movingBtn.center.x <= screenWidth-120 {
                
                movingBtn.hidden = true
                
                let query = PFQuery(className: "Post")
                query.orderByDescending("createdAt")
                query.getObjectInBackgroundWithId(self.allImages.first!, block: { (object, error) -> Void in
                    if error != nil {
                        print(error)
                    } else if let object = object {
                        
                        if self.imageReview[self.allImages.first!] == 0 {
                        
                        object["Review"] = 2
                        object.saveInBackground()
                        self.allImages.removeFirst()
                        print("Neutral")
                            
                        }
                    }
                })
                
                
            }
            
        }
        
    }
    
    // Drag the deny button over the image to give it the review (0 means deny)
    
    func denyDragged(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translationInView(self.view)
        let movingBtn = gesture.view!
        let screenWidth = self.view.bounds.width
        
        movingBtn.center.x = screenWidth-40 + translation.x
        movingBtn.center.y = 240 + translation.y
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            if movingBtn.center.x <= screenWidth-120 {
                
                movingBtn.hidden = true
                
                let query = PFQuery(className: "Post")
                query.orderByDescending("createdAt")
                query.getObjectInBackgroundWithId(self.allImages.first!, block: { (object, error) -> Void in
                    if error != nil {
                        print(error)
                    } else if let object = object {
                        if self.imageReview[self.allImages.first!] == 0 {
                        object["Review"] = 1
                        object.saveInBackground()
                        self.allImages.removeFirst()
                        print("Denied")
                        }
                    }
                })
                
                
            }
            
        }
        
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
        return usernames.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! cell
        myCell.backgroundColor = UIColor.clearColor()
        /*
        myCell.postProfilePic.layer.cornerRadius = myCell.postProfilePic.frame.size.width / 2
        myCell.postProfilePic.contentMode = UIViewContentMode.ScaleAspectFill
        myCell.postProfilePic.clipsToBounds = true
        myCell.postProfilePic.image = UIImage(named: "goCloMan.png")
        
        imageFiles[indexPath.row].getDataInBackgroundWithBlock { (data, error) -> Void in
            if let downloadedImage = UIImage(data: data!) {
                myCell.postedImage.image = downloadedImage
            }
        }
        
        myCell.username.text = usernames[indexPath.row]
        myCell.postedMessage.text = messages[indexPath.row]
        
        let gesture1 = UIPanGestureRecognizer(target: self, action: Selector("acceptDragged:"))
        let gesture2 = UIPanGestureRecognizer(target: self, action: Selector("neutralDragged:"))
        let gesture3 = UIPanGestureRecognizer(target: self, action: Selector("denyDragged:"))
        
        myCell.acceptBtn.addGestureRecognizer(gesture1)
        myCell.acceptBtn.userInteractionEnabled = true
        
        myCell.neutralBtn.addGestureRecognizer(gesture2)
        myCell.neutralBtn.userInteractionEnabled = true
        
        myCell.denyBtn.addGestureRecognizer(gesture3)
        myCell.denyBtn.userInteractionEnabled = true
        
        //myCell.acceptBtn.layer.cornerRadius = myCell.acceptBtn.bounds.size.width / 2
        myCell.neutralBtn.layer.cornerRadius = myCell.neutralBtn.frame.size.width / 2
        myCell.denyBtn.layer.cornerRadius = myCell.denyBtn.frame.size.width / 2
        myCell.acceptBtn.clipsToBounds = true
        myCell.acceptBtn.layer.masksToBounds = true
        myCell.neutralBtn.clipsToBounds = true
        myCell.denyBtn.clipsToBounds = true
        
        myCell.acceptBtn.setImage(UIImage(named: "redcircle.svg"), forState: UIControlState.Normal)
        
        
        myCell.acceptBtn.setTitle("Accept", forState: .Normal)
        myCell.neutralBtn.setTitle("Neutral", forState: .Normal)
        myCell.denyBtn.setTitle("Deny", forState: .Normal)
        */
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
