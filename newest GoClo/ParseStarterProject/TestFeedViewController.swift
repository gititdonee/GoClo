//
//  TestFeedViewController.swift
//  ParseStarterProject-Swift
//
//  Created by will ullian on 1/21/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

@available(iOS 8.0, *)
class TestFeedViewController: UIViewController, UIGestureRecognizerDelegate, UITextViewDelegate {
    
    var image: UIImageView = UIImageView()
    var overlay: UIImageView = UIImageView()
    var topBar: UILabel = UILabel()
    var textView: UITextView = UITextView()
    var currentUserProfilePic: UIImageView = UIImageView()
    var postedUserProfilePic: UIImageView = UIImageView()
    var sendButton: UIButton = UIButton()
    var backButton: UIButton = UIButton()
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    var displayedObjectID = ""
    
    var receivedImages = [PFFile]()
    var receivedImagesObjID = [""]
    var reviewedBy = [""]
    var receivedMessages = [""]
    var receivedComments = [""]
    var userProfilePicture = [PFFile]()
    var postedImageProfilePicture = [PFFile]()
    var receivedUserIds = [""]
    
    
    var gesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    var swipeGestureUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    var swipeGestureDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    
    
    var updateImageCount = 0
    var updateProfilePicCount = 0
    
    var followedUser = ""
    
    var activityIndicator = UIActivityIndicatorView()
    
    func displayAlert(title: String, message: String){
        
        if #available(iOS 8.0, *) {
            let alert =  UIAlertController(title: title, message: message ,preferredStyle:UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.topBar.center.y = -self.topBar.frame.height/2
                    self.image.center.y = self.screenHeight/2 - self.topBar.frame.height/2
                    self.textView.center.y = self.screenHeight-self.textView.frame.size.height/2 - 5
                    self.currentUserProfilePic.center.y = self.screenHeight - self.currentUserProfilePic.frame.size.height/2
                    self.sendButton.center.y = self.screenHeight - self.sendButton.frame.size.height/2 - 10
                })
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = ""
    }
    
    func goBack() {
        performSegueWithIdentifier("goToProfileViewVC", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        self.navigationController!.setToolbarHidden(true, animated: true)
        
        backButton.frame = CGRectMake(0, 10, 80, 20)
        backButton.setTitle("Profile", forState: .Normal)
        backButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        backButton.alpha = 0.4
        backButton.addTarget(self, action: Selector("goBack"), forControlEvents: .TouchUpInside)
        
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        imageViewBackground.image = UIImage(named: "GoCloBackG.png")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.view.addSubview(imageViewBackground)
        self.view.sendSubviewToBack(imageViewBackground)
        
        
        print(PFUser.currentUser())
        
        
        self.topBar.frame = CGRectMake(0, self.topBar.frame.size.height, screenWidth, 40)
        self.topBar.backgroundColor = UIColor.clearColor()
        self.topBar.textAlignment = NSTextAlignment.Center
        view.addSubview(self.topBar)
        
        textView.frame = CGRectMake(50, screenHeight, screenWidth-90, self.topBar.frame.size.height-10)
        textView.text = "Post a review"
        textView.layer.borderColor = UIColor.grayColor().CGColor
        textView.alpha = 0.7
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1
        textView.layer.zPosition = 1
        textView.textContainer.maximumNumberOfLines = 3
        textView.textContainer.lineBreakMode = .ByClipping
        textView.delegate = self
        view.addSubview(textView)
        
        currentUserProfilePic.frame = CGRectMake(textView.frame.minX - 45, screenHeight, 35, 35)
        currentUserProfilePic.image = UIImage(named: "GoCloMan.png")
        currentUserProfilePic.layer.zPosition = 1
        currentUserProfilePic.layer.cornerRadius = currentUserProfilePic.frame.size.width/2
        currentUserProfilePic.clipsToBounds = true
        currentUserProfilePic.contentMode = .ScaleAspectFill
        view.addSubview(currentUserProfilePic)
        
        postedUserProfilePic.frame = CGRectMake(screenWidth-65, 2.5, 35, 35)
        postedUserProfilePic.image = UIImage(named: "GoCloMan.png")
        postedUserProfilePic.layer.zPosition = 1
        postedUserProfilePic.layer.cornerRadius = postedUserProfilePic.frame.size.width/2
        postedUserProfilePic.clipsToBounds = true
        postedUserProfilePic.contentMode = .ScaleAspectFill
        view.addSubview(postedUserProfilePic)
        
        sendButton.frame = CGRectMake(textView.frame.maxX, screenHeight, 40, 20)
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        //sendButton.titleLabel?.font = UIFont(name: sendButton.titleLabel?.font, size: 12)
        sendButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sendButton.addTarget(self, action: "send", forControlEvents: .TouchUpInside)
        view.addSubview(sendButton)
        
        gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
        image.userInteractionEnabled = true
        swipeGestureUp = UISwipeGestureRecognizer(target: self, action: Selector("wasSwiped:"))
        swipeGestureUp.direction = .Up
        swipeGestureDown = UISwipeGestureRecognizer(target: self, action: Selector("wasSwiped:"))
        swipeGestureDown.direction = .Down
        gesture.requireGestureRecognizerToFail(swipeGestureDown)
        gesture.requireGestureRecognizerToFail(swipeGestureUp)
        self.image.addGestureRecognizer(swipeGestureUp)
        self.image.addGestureRecognizer(swipeGestureDown)
        self.image.addGestureRecognizer(gesture)
        image.frame = CGRectMake(0, self.topBar.frame.maxY, self.screenWidth, self.screenHeight - self.topBar.frame.size.height)
        
        image.image = UIImage(named: "GoCloBackG.png")
        overlay.frame = CGRectMake(image.frame.minX, image.frame.minY, self.screenWidth, image.frame.size.height)
        view.addSubview(overlay)
        view.addSubview(backButton)
        
        let getReviewedByQuery = PFQuery(className: "Post")
        getReviewedByQuery.whereKey("reviewedBy", containsString: PFUser.currentUser()?.objectId!)
        getReviewedByQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                print(error)
            } else if let objects = objects {
                for object in objects {
                    self.reviewedBy.append(object["reviewedBy"] as! (String))
                }
            }
            print("Revied by \(self.reviewedBy)")
        }
        
        let currentProfilePicQuery = PFQuery(className: "_User")
        currentProfilePicQuery.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId!)!)
        currentProfilePicQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                print(error)
            } else if let objects = objects {
                for object in objects {
                    if let images = object["profilePicture"] as? PFFile {
                        self.userProfilePicture.append(images)
                    }
                }
            }
        }
        
        let getPostUserIdQuery = PFQuery(className: "Post")
        getPostUserIdQuery.whereKeyExists("userId")
        getPostUserIdQuery.orderByAscending("createdAt")
        getPostUserIdQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                print(error)
            } else if let objects = objects {
                for object in objects {
                    self.receivedUserIds.append((object["userId"] as? String)!)
                }
            }
            
        }
        
        
        let getFollowedUsersQuery = PFQuery(className: "followers")
        getFollowedUsersQuery.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
        getFollowedUsersQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects {
                for object in objects {
                    self.followedUser = object["following"] as! String
                }
            }
        }
        
        let query = PFQuery(className: "Post")
        query.orderByAscending("createdAt")
        query.whereKey("reviewedBy", notEqualTo: (PFUser.currentUser()?.objectId!)!)
        //query.whereKey("userId", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects {
                for object in objects {
                    if let images = object["imageFile"] as? PFFile {
                        self.receivedImages.append(images)
                        self.receivedImagesObjID.append(object.objectId!)
                        self.receivedMessages.append(object["message"] as! (String))
                        self.postedImageProfilePicture.append((object["profilePicture"] as? PFFile)!)
                    }
                }
            }
            self.updateImage()
            print(self.receivedImages)
            
        }
        
        self.view.addSubview(image)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func send() {
        
        let query = PFQuery(className:"Post")
        print("OBJ ID = \(self.receivedImagesObjID[self.updateImageCount])")
        query.getObjectInBackgroundWithId(self.receivedImagesObjID[self.updateImageCount]) {
            (currentObject: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let currentObject = currentObject {
                print("Success")
                currentObject.addUniqueObject("\(self.textView.text)", forKey: "comment")
                currentObject.addUniqueObject((PFUser.currentUser()?.objectId)!, forKey: "commentedBy")
                currentObject.saveInBackground()
            }
        }
        print("Send")
        
    }
    
    func updateImage() {
        
        
        
        print("updateImageCount \(updateImageCount)")
        print("Received updateImageCount \(self.receivedImages.count)")
        print("Current User \(PFUser.currentUser()?.objectId)")
        print("Posted Profile \(postedImageProfilePicture.count)")
        
        if self.updateImageCount < self.receivedImages.count {
            self.activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
            self.activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            self.receivedImages[self.updateImageCount].getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                if let displayedImage = UIImage(data: imageData!) {
                    self.image.image = displayedImage
                    self.topBar.text = self.receivedMessages[self.updateImageCount]
                }
            })
            self.postedImageProfilePicture[self.updateImageCount].getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                if let displayedImage = UIImage(data: imageData!) {
                    self.postedUserProfilePic.image = displayedImage
                }
            })
            
        } else {
            updateImageCount--
        }
        self.updateImageCount++
        
        
        let imageData = UIImagePNGRepresentation(UIImage(named: "GoCloMan.png")!)
        let imageFile = PFFile(name:"default.png", data:imageData!)
        
        let currentUserProfilePicQuery = PFUser.query()
        currentUserProfilePicQuery!.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            if error != nil {
                print(error)
            }
            if let object = object {
                if self.userProfilePicture.isEmpty {
                    self.userProfilePicture.append(imageFile!)
                } else {
                    self.userProfilePicture[0].getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                        if let displayedImage = UIImage(data: imageData!) {
                            self.currentUserProfilePic.image = displayedImage
                        } else {
                            self.currentUserProfilePic.image = UIImage(named: "GoCloMan.png")
                        }
                    })
                }
            }
            print(self.userProfilePicture.count)
            
        })
        self.activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    func wasSwiped(gesture: UISwipeGestureRecognizer) {
        
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.Up:
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.topBar.center.y = -self.topBar.frame.height/2
                self.image.center.y = self.screenHeight/2 - self.topBar.frame.height/2
                self.textView.center.y = self.screenHeight-self.textView.frame.size.height/2 - 5
                self.currentUserProfilePic.center.y = self.screenHeight - self.currentUserProfilePic.frame.size.height/2 - 2.5
                self.sendButton.center.y = self.screenHeight - self.sendButton.frame.size.height/2 - 10
                self.postedUserProfilePic.center.y = -self.topBar.frame.height/2 - 2.5
                self.backButton.center.y = -self.topBar.frame.height/2 - 2.5
            })
            print("Swiped up")
        case UISwipeGestureRecognizerDirection.Down:
            print("Swiped down")
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.topBar.center.y = self.topBar.frame.height/2
                self.image.center.y = self.screenHeight/2 + self.topBar.frame.height/2
                self.textView.center.y = self.screenHeight + self.textView.frame.height/2+5
                self.currentUserProfilePic.center.y = self.screenHeight + self.currentUserProfilePic.frame.size.height/2 + 2.5
                self.sendButton.center.y = self.screenHeight + self.sendButton.frame.size.height/2 + 10
                self.postedUserProfilePic.center.y = self.topBar.frame.height/2
                self.backButton.center.y = self.topBar.frame.height/2
                
            })
        default:
            break
        }
        
        
    }
    
    func wasDragged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(self.view)
        let label = gesture.view!
        let screenWidth = self.view.bounds.width
        
        let distFromCenter = abs((screenWidth/2 - abs(translation.x))/(screenWidth/2))
        let overlayAlpha = 1 - distFromCenter
        
        self.image.alpha = distFromCenter
        self.overlay.alpha = overlayAlpha
        label.center.x = screenWidth/2 + translation.x
        
        if label.center.x < screenWidth/2 {
            self.overlay.backgroundColor = UIColor.greenColor()
        } else if label.center.x > screenWidth/2{
            self.overlay.backgroundColor = UIColor.redColor()
        }
        
        self.overlay.center = label.center
        if gesture.state == UIGestureRecognizerState.Ended {
            
            if label.center.x < 100 {
                let query = PFQuery(className:"Post")
                print("OBJ ID = \(self.receivedImagesObjID[self.updateImageCount])")
                query.getObjectInBackgroundWithId(self.receivedImagesObjID[self.updateImageCount]) {
                    (currentObject: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else if let currentObject = currentObject {
                        print("Success")
                        currentObject.addUniqueObject("accepted", forKey: "acceptedOrRejected")
                        currentObject.addUniqueObject((PFUser.currentUser()?.objectId)!, forKey: "reviewedBy")
                        currentObject.saveInBackground()
                    }
                }
            } else if label.center.x > self.view.bounds.width - 100 {
                
                let query = PFQuery(className:"Post")
                print("OBJ ID = \(self.receivedImagesObjID[self.updateImageCount])")
                query.getObjectInBackgroundWithId(self.receivedImagesObjID[self.updateImageCount]) {
                    (currentObject: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else if let currentObject = currentObject {
                        print("Success")
                        currentObject.addUniqueObject("rejected", forKey: "acceptedOrRejected")
                        currentObject.addUniqueObject((PFUser.currentUser()?.objectId)!, forKey: "reviewedBy")
                        currentObject.saveInBackground()
                    }
                }
            }
            
            label.center.x = screenWidth/2
            self.overlay.alpha = 0
            self.image.alpha = 1
            updateImage()
            
            
        }
    }
    
}
