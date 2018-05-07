//
//  PostImageViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Horatious on 1/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//


import UIKit
import Parse

@available(iOS 8.0, *)
class PostImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        })))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    
    var userProfilePicture = [PFFile]()
    var profilePicture = [PFFile]()
    var characterLabel: UILabel = UILabel()
    var backButton: UIButton = UIButton()
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var chooseImageBtn: UIButton!
    @IBOutlet var imageToPost: UIImageView!
    
    @IBAction func chooseImage(sender: AnyObject) {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.dismissViewControllerAnimated(true, completion:nil)
        imageToPost.image = image
        
    }
    
    @IBOutlet var message: UITextField!
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 25
    }
    
    func textFieldDidEdit(sender: UITextField) {
        for (var i = 0; i <= sender.text?.characters.count; i++) {
        self.characterLabel.text = "\(i)"
        }
        
    }
    @IBAction func postImage(sender: AnyObject) {
        
        activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let post = PFObject(className: "Post")
        
        post["message"] = message.text
        post["userId"] = PFUser.currentUser()!.objectId!
        post["comment"] = ""
        
        let acl = PFACL()
        acl.publicReadAccess = true
        acl.publicWriteAccess = true
        post.ACL = acl
        
        let imageData = UIImageJPEGRepresentation(imageToPost.image!, 0.1)
        let imageFile = PFFile(name: "image.png", data: imageData!)
        
        post["imageFile"] = imageFile
        post["profilePicture"] = self.profilePicture[0]
        
        post.saveInBackgroundWithBlock{(success, error) -> Void in
            
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if error == nil {
                
                self.displayAlert("Image Posted!", message: "Your image has been posted successfully")
                self.imageToPost.image = UIImage(named: "GoCloMan.png")
                self.message.text = ""
                
            } else {
                
                self.displayAlert("Uh Oh", message: "Something went wrong")
                
            }
        }
        
        
    }
    func goBack() {
        performSegueWithIdentifier("goToProfileViewVC", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.setToolbarHidden(true, animated: true)
        backButton.frame = CGRectMake(0, 10, 80, 20)
        backButton.setTitle("Back", forState: .Normal)
        backButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        backButton.alpha = 0.4
        backButton.addTarget(self, action: Selector("goBack"), forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        
        message.delegate = self
        message.addTarget(self, action: "textFieldDidEdit:", forControlEvents: UIControlEvents.EditingChanged)
        
        characterLabel.frame = CGRectMake(message.frame.maxX-25, message.frame.midY - 15, 30, message.frame.size.height)
        characterLabel.text = "00"
        self.view.addSubview(characterLabel)
        
        let currentProfilePicQuery = PFQuery(className: "_User")
        currentProfilePicQuery.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId!)!)
        currentProfilePicQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                print(error)
            } else if let objects = objects {
                for object in objects {
                    if let images = object["profilePicture"] as? PFFile {
                        images.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                            self.profilePicture.append(PFFile(name: "profileImage.png", data: imageData!)!)
                        })

                    }
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
