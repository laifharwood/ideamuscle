//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

let tabBarControllerK = UITabBarController()

class ViewController: UIViewController{
    
    var twitterLoginButton = UIButton()
    var facebookLoginButton = UIButton()
    var logo = UIImage()
    var activityIndicator = UIActivityIndicatorView()
    let permissions = ["public_profile", "email", "user_friends"]
    var hasAgreed = false
    let agreeLabel = UILabel()
    let yesButton = UIButton()
    let viewAgreementButton = UIButton()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        //MARK: - Logo Configuration
        logo = UIImage(named: "bigLogo")!
        let logoView = UIImageView(image: logo)
        logoView.frame = CGRectMake(self.view.frame.width/2 - 89, 30, 178, 200)
        if PFUser.currentUser() == nil{
        self.view.addSubview(logoView)
        }else{
        activityIndicator.addSubview(logoView)
        }
        
        // MARK: - Twitter Login Button Configuration
        //let twitterColor : UIColor = UIColor(red: 0/255, green: 172/255, blue: 237/255, alpha: 1)
        twitterLoginButton.setTitle("Login with", forState: .Normal)
        twitterLoginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        twitterLoginButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        twitterLoginButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 20)
        twitterLoginButton.frame = CGRectMake(self.view.frame.width/2 - 100, logoView.frame.maxY + 25, 200, 40)
        twitterLoginButton.backgroundColor = fiftyGrayColor
        let twitterLogoImage = UIImage(named: "twitter")
        twitterLoginButton.setImage(twitterLogoImage, forState: .Normal)
        twitterLoginButton.imageEdgeInsets = UIEdgeInsetsMake(5, 140, 5, 28.74)
        twitterLoginButton.titleEdgeInsets = UIEdgeInsetsMake(10, -160, 10, 0)
        twitterLoginButton.addTarget(self, action: "login:", forControlEvents: .TouchUpInside)
        twitterLoginButton.layer.cornerRadius = 3
        
        
        facebookLoginButton.setTitle("Login with", forState: .Normal)
        facebookLoginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        facebookLoginButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        facebookLoginButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 20)
        facebookLoginButton.frame = CGRectMake(self.view.frame.width/2 - 100, twitterLoginButton.frame.maxY + 20, 200, 40)
        //twitterLoginButton.center = self.view.center
        facebookLoginButton.backgroundColor = fiftyGrayColor
        let facebookLogoImage = UIImage(named: "facebook")
        facebookLoginButton.setImage(facebookLogoImage, forState: .Normal)
        facebookLoginButton.imageEdgeInsets = UIEdgeInsetsMake(5, 140, 5, 28.74)
        facebookLoginButton.titleEdgeInsets = UIEdgeInsetsMake(10, -160, 10, 0)
        facebookLoginButton.addTarget(self, action: "loginFacebook:", forControlEvents: .TouchUpInside)
        facebookLoginButton.layer.cornerRadius = 3
        
        
        agreeLabel.frame = CGRectMake(5, facebookLoginButton.frame.maxY + 7, self.view.frame.width - 10, 60)
        agreeLabel.text = "Have you read and agree to the terms of the end user license agreement?"
        agreeLabel.font =  UIFont(name: "HelveticaNeue", size: 15)
        agreeLabel.textColor = fiftyGrayColor
        agreeLabel.textAlignment = NSTextAlignment.Center
        agreeLabel.numberOfLines = 0
        
        
        yesButton.frame = CGRectMake(facebookLoginButton.frame.minX, agreeLabel.frame.maxY + 5, 95, 50)
        yesButton.setTitle("Yes", forState: .Normal)
        yesButton.backgroundColor = redColor
        yesButton.addTarget(self, action: "agreed:", forControlEvents: .TouchUpInside)
        yesButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        yesButton.layer.cornerRadius = 3
        
        
        viewAgreementButton.frame = CGRectMake(yesButton.frame.maxX + 10, agreeLabel.frame.maxY + 5, 95, 50)
        viewAgreementButton.setTitle("View Agreement", forState: .Normal)
        viewAgreementButton.backgroundColor = oneFiftyGrayColor
        viewAgreementButton.addTarget(self, action: "viewAgreement:", forControlEvents: .TouchUpInside)
        viewAgreementButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        viewAgreementButton.layer.cornerRadius = 3
        viewAgreementButton.titleLabel?.numberOfLines = 0
        viewAgreementButton.titleLabel?.textAlignment = NSTextAlignment.Center
        
        if PFUser.currentUser() == nil{
            self.view.addSubview(twitterLoginButton)
            self.view.addSubview(facebookLoginButton)
            self.view.addSubview(agreeLabel)
            self.view.addSubview(yesButton)
            self.view.addSubview(viewAgreementButton)
        }else{
            self.view.addSubview(activityIndicator)
            startActivityIndicator()
        }
    }
    
    func agreed(sender: UIButton){
        hasAgreed = true
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            sender.hidden = true
            self.agreeLabel.hidden = true
            self.viewAgreementButton.hidden = true
        })
    }
    
    func viewAgreement(sender: UIButton){
        let eulaVC = EulaViewController()
        self.presentViewController(eulaVC, animated: true, completion: nil)
    }
    
    func loginFacebook(sender: UIButton!){
        if hasAgreed{
            startActivityIndicator()
            PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: { (user, error) -> Void in
                
                if user == nil {
                    println("Uh oh. The user cancelled the Facebook login.")
                    self.stopActivityIndicator()
                }else if user!.isNew {
                    println("User signed up and logged in through Facebook!")
                    self.getUserFacebookInfo()
                    self.goToTabBar()
                }else{
                    println("User logged in through Facebook!")
                    self.getUserFacebookInfo()
                    self.goToTabBar()
                }
            })
        }else{
            promptForAgreement()
        }
    }
    
    func promptForAgreement(){
        let agreeAlert: UIAlertController = UIAlertController(title: "License Agreement", message: "You must agree to the end user license agreement to login.", preferredStyle: .Alert)
        agreeAlert.view.tintColor = redColor
        agreeAlert.view.backgroundColor = oneFiftyGrayColor
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .Cancel) { action -> Void in
        }
        agreeAlert.addAction(cancelAction)
        self.presentViewController(agreeAlert, animated: true, completion: nil)
    }
    
    func getUserFacebookInfo(){
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        //let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil, HTTPMethod: "Get")
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                println("Error: \(error)")
            }
            else
            {
                
                let username = result.valueForKey("name") as! String
                let userEmail = result.valueForKey("email") as! String
                let userID = result.valueForKey("id") as! String
                
                if let user = PFUser.currentUser(){
                    
                    user["username"] = username
                    user["lowercaseUsername"] = username.lowercaseString
                    user["email"] = userEmail
                    user["facebookID"] = userID
                    let fid = user["facebookID"] as! String
                    var imgURLString = "http://graph.facebook.com/" + fid + "/picture?type=large"
                    var imgURL = NSURL(string: imgURLString)
                    var imageData = NSData(contentsOfURL: imgURL!)
                    let imageFile: PFFile = PFFile(name: (PFUser.currentUser()!.objectId! + "profileImage.png"), data: imageData!)
                    imageFile.saveInBackground()
                    user.setObject(imageFile, forKey: "avatar")
                    user.saveInBackground()
                }
                
            }
        })
    }
    func login(sender: UIButton!){
        if hasAgreed{
            startActivityIndicator()
            PFTwitterUtils.logInWithBlock { (user, error) -> Void in
                
                if (error != nil){
                  //No Twitter Account Setup On Phone. Show Alert
                    self.stopActivityIndicator()
                    let noTwitterAccountController: UIAlertController = UIAlertController(title: "No Twitter Account Linked", message: "You must have a twitter account setup on your phone. Go to your Settings App/Twitter/Sign In or Create New Account", preferredStyle: .Alert)
                    noTwitterAccountController.view.tintColor = redColor
                    noTwitterAccountController.view.backgroundColor = oneFiftyGrayColor
                    //Create and add the Cancel action
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .Cancel) { action -> Void in
                    }
                    noTwitterAccountController.addAction(cancelAction)
                    //Present the AlertController
                    self.presentViewController(noTwitterAccountController, animated: true, completion: nil)
                }else if !(user != nil) {
                //User Cancelled
                self.stopActivityIndicator()
                }else{
                PFTwitterUtils.linkUser(PFUser.currentUser()!, block: { (success, error) -> Void in
                    if success{
                        
                        //Linked User SuccessFully.
                        if let twitterUsername = PFTwitterUtils.twitter()?.screenName{
                            if let user = PFUser.currentUser(){
                                user.username = twitterUsername
                                user["lowercaseUsername"] = twitterUsername.lowercaseString
                                user.saveEventually()
                            }
                        }
                        //Perform Segue
                        self.getAvatar()
                        self.goToTabBar()
                    }else{
                        //Could Not Link User
                        
                        let couldNotLinkTwitterAccountController: UIAlertController = UIAlertController(title: "Could Not Link Twitter Account", message: "There was an error in linking your Twitter Account, Please Try Again.", preferredStyle: .Alert)
                        couldNotLinkTwitterAccountController.view.tintColor = redColor
                        couldNotLinkTwitterAccountController.view.backgroundColor = oneFiftyGrayColor
                        //Create and add the Cancel action
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .Cancel) { action -> Void in
                            //Add Logout User
                            self.stopActivityIndicator()
                            logout()
                        }
                        couldNotLinkTwitterAccountController.addAction(cancelAction)
                        //Present the AlertController
                        self.presentViewController(couldNotLinkTwitterAccountController, animated: true, completion: nil)
                    }
                })
                }
            }
        }else{
            promptForAgreement()
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (PFUser.currentUser() == nil) {
            
        }else{
            
            startActivityIndicator()
            let userCurrent = PFUser.currentUser()!

            if userCurrent["facebookID"] != nil{
                getUserFacebookInfo()
            }else{
                getAvatar()
            }
            goToTabBar()
        }
    
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func goToTabBar(){
        
    checkIfPro()
    
    
    
    UITabBar.appearance().barTintColor = fiftyGrayColor
    UITabBar.appearance().tintColor = redColor
    
    let topicsController = TopicAndIdeaContainerViewController()
    let topicsNav = UINavigationController(rootViewController: topicsController)
    
    let feedController = FeedViewController()
    let feedNav = UINavigationController(rootViewController: feedController)
    
    let leaderboardController = LeaderboardViewController()
    let leaderboardNav = UINavigationController(rootViewController: leaderboardController)
    
    let moreController = MoreViewController()
    let moreNav = UINavigationController(rootViewController: moreController)
    
    let controllers = [topicsNav, feedNav, leaderboardNav, moreNav]
    tabBarControllerK.viewControllers = controllers
    
    
    let offset = UIOffsetMake(0, 1)
    
    let bulb = UIImage(named: "bulbTabBar")
    topicsController.tabBarItem = UITabBarItem(title: nil, image: bulb, tag: 1)
    topicsController.tabBarItem.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0)
    topicsController.tabBarItem.setTitlePositionAdjustment(offset)
    topicsController.tabBarItem.title = "Ideas"
    
    
    let feed = UIImage(named: "feed")
    feedController.tabBarItem = UITabBarItem(title: nil, image: feed, tag: 2)
    feedController.tabBarItem.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0)
    feedController.tabBarItem.setTitlePositionAdjustment(offset)
    feedController.tabBarItem.title = "Feed"
    
    let crown = UIImage(named: "crown")
    leaderboardController.tabBarItem = UITabBarItem(title: nil, image: crown, tag: 3)
    leaderboardController.tabBarItem.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0)
    leaderboardController.tabBarItem.setTitlePositionAdjustment(offset)
    leaderboardController.tabBarItem.title = "Leaderboard"
    
    let more = UIImage(named: "more")
    moreController.tabBarItem = UITabBarItem(title: nil, image: more, tag: 4)
    moreController.tabBarItem.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0)
    moreController.tabBarItem.setTitlePositionAdjustment(offset)
    if PFInstallation.currentInstallation().badge != 0{
        moreController.tabBarItem.badgeValue = abbreviateNumber(PFInstallation.currentInstallation().badge) as String
    }
    moreController.tabBarItem.title = "More"
    
        
        if let currentUser = PFUser.currentUser(){
                var isOnLeaderboard = Bool()
                if let isOnLeaderboard = currentUser["isOnLeaderboard"] as? Bool{
                }else{
                var leaderboardObject = PFObject(className: "Leaderboard")
                leaderboardObject["userPointer"] = currentUser
                leaderboardObject["numberOfUpvotes"] = 0
                leaderboardObject.ACL?.setPublicWriteAccess(true)
                leaderboardObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success{
                        currentUser["isOnLeaderboard"] = true
                        currentUser.saveEventually()
                    }
                })
                }
            var hasIncUserTotal = Bool()
            if let hasIncUserTotal = currentUser["hasIncTotalUserCount"] as? Bool{
            }else{
                let totalUsers = PFObject(withoutDataWithClassName: "TotalUsers", objectId: "RjDIi23LNW")
                totalUsers.incrementKey("numberOfUsers")
                totalUsers.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success{
                        currentUser["hasIncTotalUserCount"] = true
                        currentUser.saveEventually()
                    }
                })
            }
            var isInLastPosted = Bool()
            if let isInLastPosted = currentUser["isInLastPosted"] as? Bool{
            }else{
                var lastPostedObject = PFObject(className: "LastPosted")
                lastPostedObject["userPointer"] = currentUser
                lastPostedObject["update"] = 0
                lastPostedObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success{
                    currentUser["isInLastPosted"] = true
                    currentUser.saveEventually()
                }
                })
            }
            var isInNumberOfFollowers = Bool()
            if let isInNumberOfFollowers = currentUser["isInNumberOfFollowers"] as? Bool{
            }else{
                var numberOfFollowersObject = PFObject(className: "NumberOfFollowers")
                numberOfFollowersObject["userPointer"] = currentUser
                numberOfFollowersObject["numberOfFollowers"] = 0
                numberOfFollowersObject.ACL?.setPublicWriteAccess(true)
                numberOfFollowersObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success{
                        currentUser["isInNumberOfFollowers"] = true
                        currentUser.saveEventually()
                    }
                })
            }
            
            if let hasSetNotificationSettings = currentUser["hasSetNotificationSettings"] as? Bool{
                
            }else{
                currentUser["getCommentNotifications"] = true
                currentUser["getTopicNotifications"] = true
                currentUser["getUpvoteNotifications"] = true
                currentUser["hasSetNotificationSettings"] = true
            }
        }
        
        if let user = PFUser.currentUser(){
            let installation = PFInstallation.currentInstallation()
            installation.setObject(user, forKey: "user")
            installation.saveEventually()
        }
        
        
        
    stopActivityIndicator()
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    appDelegate.window?.rootViewController = tabBarControllerK
    
}

    func getAvatar(){
    
    if PFTwitterUtils.isLinkedWithUser(PFUser.currentUser()) {
        
        let screenName = PFTwitterUtils.twitter()?.screenName!
        
        let requestString = ("https://api.twitter.com/1.1/users/show.json?screen_name=" + screenName!)
        
        let verify: NSURL = NSURL(string: requestString)!
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: verify)
        
        PFTwitterUtils.twitter()?.signRequest(request)
        
        var response: NSURLResponse?
        var error: NSError?
        
        if let data: NSData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error){
        
        if error == nil {
            
            let result: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error)
            let urlString = result?.objectForKey("profile_image_url_https") as! String
            let hiResUrlString = urlString.stringByReplacingOccurrencesOfString("_normal", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let twitterPhotoUrl = NSURL(string: hiResUrlString)
            let imageData = NSData(contentsOfURL: twitterPhotoUrl!)
        
            let imageFile: PFFile = PFFile(name: (PFUser.currentUser()!.objectId! + "profileImage.png"), data: imageData!)
            imageFile.saveInBackground()
            if let user = PFUser.currentUser(){
                user.setObject(imageFile, forKey: "avatar")
                user.saveInBackground()
            }
            
        }
        }
    }
}
    
    func checkIfPro(){
        
        if let user = PFUser.currentUser(){
            
            user.fetchInBackgroundWithBlock({ (object, error) -> Void in
                if let isProForever = user["isProForever"] as? Bool{
                    
                    if isProForever == false{
                        self.checkProExpiration(user)
                    }
                }else{
                    self.checkProExpiration(user)
                }
            })
            
        }
    }
    
    func checkProExpiration(user: PFUser){
        if let isPro = user["isPro"] as? Bool{
        if isPro == true{
            
            //let timeNowObject = PFObject(withoutDataWithObjectId: "yhUEKpyRSg")
            var timeNowObject = PFObject(className: "TimeNow")
            let query = PFQuery(className: "TimeNow")
            query.getObjectInBackgroundWithId("yhUEKpyRSg", block: { (object, error) -> Void in
                if error == nil{
                    timeNowObject = object!
                    timeNowObject.incrementKey("update")
                    timeNowObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success{
                            timeNowObject.fetchInBackgroundWithBlock({ (object, error) -> Void in
                                let timeNow = timeNowObject.updatedAt
                                let expiration = user["proExpiration"] as! NSDate
                                if timeNow!.isGreaterThanDate(expiration){
                                    user["isPro"] = false
                                    user.saveInBackground()
                                }
                            })
                        }
                    })
                }
            })
        }
        }
    }
    
    func startActivityIndicator(){
        
        facebookLoginButton.removeFromSuperview()
        twitterLoginButton.removeFromSuperview()
        agreeLabel.removeFromSuperview()
        yesButton.removeFromSuperview()
        viewAgreementButton.removeFromSuperview()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        activityIndicator.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        
    }
    
    func stopActivityIndicator(){
        self.activityIndicator.stopAnimating()
        self.view.addSubview(facebookLoginButton)
        self.view.addSubview(twitterLoginButton)
        self.view.addSubview(agreeLabel)
        self.view.addSubview(yesButton)
        self.view.addSubview(viewAgreementButton)
    }
    
    
}

