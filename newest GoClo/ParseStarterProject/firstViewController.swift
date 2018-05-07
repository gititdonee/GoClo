/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

@available(iOS 8.0, *)
class firstViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let nameTxt: UITextField = UITextField()
    let passwordTxt: UITextField = UITextField()
    
    let registerLabel: UILabel = UILabel()
    let signUpBtn: UIButton = UIButton()
    let loginBtn: UIButton = UIButton()
    let chooseImgBtn: UIButton = UIButton()
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    var startImage: UIImageView = UIImageView()
    
    var activityindicator : UIActivityIndicatorView = UIActivityIndicatorView()
    
    var errorMessage = ""
    
    var signUpActive = false
    var chooseImageActive = false
    
    
    func pressed() {
        
        // self.performSegueWithIdentifier("goToSignUpVC", sender: self)
        
        if signUpActive == false {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.chooseImgBtn.alpha = 1
                self.registerLabel.text = "Already have an account?"
                self.signUpBtn.setTitle("Go back", forState: .Normal)
                self.loginBtn.setTitle("Sign Up", forState: .Normal)
            })
            signUpActive = true
            
        } else if signUpActive == true {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.chooseImgBtn.alpha = 0
                self.registerLabel.text = "Don't have an account yet?"
                self.signUpBtn.setTitle("Sign Up", forState: .Normal)
                self.loginBtn.setTitle("Login", forState: .Normal)
            })
            signUpActive = false
        }
    }
    
    func displayAlert(title: String, message: String){
        
        let alert =  UIAlertController(title: title, message: message ,preferredStyle:UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "ok", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func login() {
        
        if signUpActive == false {
            activityindicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityindicator.center.x = self.view.center.x
            activityindicator.center.y = self.view.center.y + 50
            activityindicator.hidesWhenStopped = true
            activityindicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityindicator)
            activityindicator.startAnimating()
            
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            PFUser.logInWithUsernameInBackground(self.nameTxt.text!, password: self.passwordTxt.text!, block: { (user, error) -> Void in
                self.activityindicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if user != nil{
                    
                    //loggin in
                    self.performSegueWithIdentifier("login", sender: self) //login
                    
                    
                }else{
                    
                    if let errrorString = error!.userInfo["error"] as? String{
                        self.errorMessage = errrorString
                        
                    }
                    
                    self.displayAlert("failed log in", message: self.errorMessage)
                    
                }
                
            })
            
        } else if signUpActive == true {
            
            if self.nameTxt.text == "" || self.passwordTxt.text == ""
            {
                displayAlert("error", message:"plese enter something")
                
            }else{
                activityindicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
                activityindicator.center = self.view.center
                activityindicator.hidesWhenStopped = true
                activityindicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                view.addSubview(activityindicator)
                activityindicator.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                
                let imageData = UIImageJPEGRepresentation(self.startImage.image!, 0.1)
                let imageFile = PFFile(name: "image.png", data: imageData!)
                
                let user = PFUser()
                user.username = nameTxt.text
                user.password = passwordTxt.text
                user["profilePicture"] = imageFile
                
                user.signUpInBackgroundWithBlock({ (sucess, error) -> Void in
                    self.activityindicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if error == nil{
                        
                        //signup
                        self.performSegueWithIdentifier("login", sender: self)
                        
                        
                    }else{
                        if let errorString = error!.userInfo["error"] as? String {
                            self.errorMessage = errorString
                            
                        }
                        self.displayAlert("failed sign up", message: self.errorMessage)
                    }
                    
                    
                    
                })
            }
            
            
        }
    }
    
 
    
    func textFieldDidNext(textField: UITextField) {
        if textField == nameTxt {
            resignFirstResponder()
            passwordTxt.becomeFirstResponder()
        }
        if textField == passwordTxt {
            login()
        }
    }
    
    func DismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func chooseImg()  {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion:nil)
        self.startImage.image = image
    }
    
    var blurEffectView = UIVisualEffectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startImage.frame = CGRectMake(screenWidth/2-60, 40, 120, 120)
        self.startImage.image = UIImage(named: "GoCloMan.png")
        self.view.addSubview(self.startImage)
        
        self.chooseImgBtn.frame = CGRectMake(screenWidth/2 - 80, self.startImage.frame.maxY + 10, 160, 40)
        self.chooseImgBtn.setTitle("Choose Profile Picture", forState: .Normal)
        self.chooseImgBtn.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 14)
        self.chooseImgBtn.addTarget(self, action: Selector("chooseImg"), forControlEvents: UIControlEvents.TouchUpInside)
        self.chooseImgBtn.alpha = 0
        
        let dismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(dismiss)
        
        // Setup Login Design
        
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        imageViewBackground.image = UIImage(named: "GoCloBackG.png")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.view.addSubview(imageViewBackground)
        self.view.sendSubviewToBack(imageViewBackground)
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            
            //Blur Effect
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            self.blurEffectView = UIVisualEffectView(effect: blurEffect)
            self.blurEffectView.alpha = 0.55
            //always fill the view
            self.blurEffectView.frame = self.view.bounds
            self.blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            // Vibrancy Effect
            let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
            let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
            vibrancyEffectView.frame = view.bounds
            
            // Name
            nameTxt.frame = CGRectMake(screenWidth/2-150, 200, screenWidth-75, 40)
            nameTxt.placeholder = "Username"
            nameTxt.layer.zPosition = 1
            nameTxt.returnKeyType = UIReturnKeyType.Next
            nameTxt.delegate = self
            nameTxt.addTarget(self, action: "textFieldDidNext:", forControlEvents: UIControlEvents.EditingDidEndOnExit)
            
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRectMake(0.0, nameTxt.frame.size.height - 1, nameTxt.frame.size.width, 1.0);
            bottomBorder.backgroundColor = UIColor.blackColor().CGColor
            nameTxt.layer.addSublayer(bottomBorder)
            
            // Password
            passwordTxt.frame = CGRectMake(screenWidth/2-150, nameTxt.frame.maxY+15, screenWidth-75, 40)
            passwordTxt.placeholder = "Password"
            passwordTxt.layer.zPosition = 1
            passwordTxt.returnKeyType = UIReturnKeyType.Done
            passwordTxt.secureTextEntry = true
            passwordTxt.delegate = self
            passwordTxt.addTarget(self, action: "textFieldDidNext:", forControlEvents: UIControlEvents.EditingDidEndOnExit)
            
            let bottomBorder2 = CALayer()
            bottomBorder2.frame = CGRectMake(0.0, passwordTxt.frame.size.height - 1, passwordTxt.frame.size.width, 1.0);
            bottomBorder2.backgroundColor = UIColor.blackColor().CGColor
            passwordTxt.layer.addSublayer(bottomBorder2)
            
            registerLabel.frame = CGRectMake(screenWidth/2-120, screenHeight - 40, screenWidth-60, 40)
            registerLabel.font = UIFont(name: "Arial", size: 14)
            signUpBtn.frame = CGRectMake(registerLabel.frame.minX + 70, screenHeight - 40, screenWidth-60, 40)
            signUpBtn.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 14)
            signUpBtn.addTarget(self, action: "pressed", forControlEvents: .TouchUpInside)
            registerLabel.text = "Don't have an account yet?"
            signUpBtn.setTitle("Sign Up", forState: .Normal)
            
            loginBtn.frame = CGRectMake(screenWidth/2 - 60, passwordTxt.frame.maxY + 10, 120, 40)
            loginBtn.setTitle("Login", forState: .Normal)
            loginBtn.addTarget(self, action: "login", forControlEvents: UIControlEvents.TouchUpInside)
            
            // Register
            
            
            // Add label to the vibrancy view
            vibrancyEffectView.contentView.addSubview(nameTxt)
            vibrancyEffectView.contentView.addSubview(passwordTxt)
            vibrancyEffectView.contentView.addSubview(loginBtn)
            vibrancyEffectView.contentView.addSubview(self.chooseImgBtn)
            vibrancyEffectView.contentView.addSubview(registerLabel)
            vibrancyEffectView.contentView.addSubview(signUpBtn)
            
            // Add the vibrancy view to the blur view
            self.blurEffectView.contentView.addSubview(vibrancyEffectView)
            
            self.view.addSubview(self.blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        }
        else {
            self.view.backgroundColor = UIColor.blackColor()
        }
        
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.blurEffectView.alpha = 0.95
        })
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.blurEffectView.alpha = 0.55
        })
        return true
    }

    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
