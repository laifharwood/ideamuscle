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



class ViewController: UIViewController{
    
    var twitterLoginButton = UIButton()
    var facebookLoginButton = UIButton()
    var proceedWithoutLoginButton = UIButton()
    var logo = UIImage()
    var activityIndicator = UIActivityIndicatorView()
    let permissions = ["public_profile", "email", "user_friends"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        //MARK: - Logo Configuration
        logo = UIImage(named: "IdeaMuscleLogo.png")!
        let logoView = UIImageView(image: logo)
        logoView.frame = CGRectMake(self.view.frame.width/2 - 100, 30, 200, 232)
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
        twitterLoginButton.frame = CGRectMake(self.view.frame.width/2 - 100, logoView.frame.maxY + 75, 200, 40)
        //twitterLoginButton.center = self.view.center
        twitterLoginButton.backgroundColor = fiftyGrayColor
        let twitterLogoImage = UIImage(named: "twitter")
        twitterLoginButton.setImage(twitterLogoImage, forState: .Normal)
        twitterLoginButton.imageEdgeInsets = UIEdgeInsetsMake(5, 140, 5, 28.74)
        twitterLoginButton.titleEdgeInsets = UIEdgeInsetsMake(10, -160, 10, 0)
        twitterLoginButton.addTarget(self, action: "login:", forControlEvents: .TouchUpInside)
        if PFUser.currentUser() == nil{
        self.view.addSubview(twitterLoginButton)
        }else{
            self.view.addSubview(activityIndicator)
            startActivityIndicator()
        }
        
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
        if PFUser.currentUser() == nil{
            self.view.addSubview(facebookLoginButton)
        }else{
            self.view.addSubview(activityIndicator)
            startActivityIndicator()
        }
        
        
        
        //MARK: - Proceed Without Login Button Configuration
        proceedWithoutLoginButton.setTitle("Proceed Without Login", forState: .Normal)
        proceedWithoutLoginButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        proceedWithoutLoginButton.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
        proceedWithoutLoginButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 10)
        proceedWithoutLoginButton.frame = CGRectMake((self.view.frame.width/2) - 100, twitterLoginButton.frame.minY + 75, 200, 20)
        proceedWithoutLoginButton.addTarget(self, action: "proceedWithoutAccount:", forControlEvents: .TouchUpInside)
        //self.view.addSubview(proceedWithoutLoginButton)
        
        
        
    }
    
    func loginFacebook(sender: UIButton!){
        
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
        
        startActivityIndicator()
    
        
        PFTwitterUtils.logInWithBlock { (user, error) -> Void in
            
            if (error != nil){
                
              //No Twitter Account Setup On Phone. Show Alert
                
                self.stopActivityIndicator()
                
                let noTwitterAccountController: UIAlertController = UIAlertController(title: "No Twitter Account Linked", message: "You must have a twitter account setup on your phone. Go to your Settings App/Twitter/Sign In or Create New Account", preferredStyle: .Alert)
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
                    var twitterUsername = PFTwitterUtils.twitter()?.screenName
                    PFUser.currentUser()?.username = twitterUsername
                    PFUser.currentUser()?.saveInBackground()
                    
                    //Perform Segue
                    self.getAvatar()
                    self.goToTabBar()
                    
                    
                }else{
                    
                    //Could Not Link User
                    
                    let couldNotLinkTwitterAccountController: UIAlertController = UIAlertController(title: "Could Not Link Twitter Account", message: "There was an error in linking your Twitter Account, Please Try Again.", preferredStyle: .Alert)
                    //Create and add the Cancel action
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .Cancel) { action -> Void in
                    }
                    couldNotLinkTwitterAccountController.addAction(cancelAction)
                    //Present the AlertController
                    self.presentViewController(couldNotLinkTwitterAccountController, animated: true, completion: nil)
                    
                    
                }
            })
                
                
            
            
            
                
            }
        }
    }
    
    func proceedWithoutAccount(sender: UIButton!){
        
        //goToTabBar()
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
    
    let tabBarController = UITabBarController()
    
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
    tabBarController.viewControllers = controllers
    
    
    let offset = UIOffsetMake(0, 1)
    
    let bulb = UIImage(named: "bulb")
    topicsController.tabBarItem = UITabBarItem(title: nil, image: bulb, tag: 1)
    topicsController.tabBarItem.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)
    topicsController.tabBarItem.setTitlePositionAdjustment(offset)
    topicsController.tabBarItem.title = "Ideas"
    
    
    let feed = UIImage(named: "feed")
    feedController.tabBarItem = UITabBarItem(title: nil, image: feed, tag: 2)
    feedController.tabBarItem.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)
    feedController.tabBarItem.setTitlePositionAdjustment(offset)
    feedController.tabBarItem.title = "Feed"
    
    let crown = UIImage(named: "crown")
    leaderboardController.tabBarItem = UITabBarItem(title: nil, image: crown, tag: 3)
    leaderboardController.tabBarItem.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)
    leaderboardController.tabBarItem.setTitlePositionAdjustment(offset)
    leaderboardController.tabBarItem.title = "Leaderboard"
    
    let more = UIImage(named: "more")
    moreController.tabBarItem = UITabBarItem(title: nil, image: more, tag: 4)
    moreController.tabBarItem.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)
    moreController.tabBarItem.setTitlePositionAdjustment(offset)
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
                    currentUser.saveInBackground()
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
                    currentUser.saveInBackground()
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
                        currentUser.saveInBackground()
                    }
                })
            }
        
        
        }
        
    
    
    stopActivityIndicator()
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    appDelegate.window?.rootViewController = tabBarController
    
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
        println("checking if Pro")
        if let user = PFUser.currentUser(){
            println("there is a current user")
            user.fetchInBackgroundWithBlock({ (object, error) -> Void in
                if let isProForever = user["isProForever"] as? Bool{
                    println("user has been fetched")
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
        if user["proExpiration"] != nil{
            println("proExpiration does not equal nil")
            //let timeNowObject = PFObject(withoutDataWithObjectId: "yhUEKpyRSg")
            var timeNowObject = PFObject(className: "TimeNow")
            let query = PFQuery(className: "TimeNow")
            query.getObjectInBackgroundWithId("yhUEKpyRSg", block: { (object, error) -> Void in
                if error == nil{
                    timeNowObject = object!
                    timeNowObject.incrementKey("update")
                    timeNowObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                        println("timeNowObject Saved")
                        if success{
                            timeNowObject.fetchInBackgroundWithBlock({ (object, error) -> Void in
                                println("timenow object fetched")
                                let timeNow = timeNowObject.updatedAt
                                let expiration = user["proExpiration"] as! NSDate
                                if timeNow!.isGreaterThanDate(expiration){
                                    println("user should not be pro")
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
    
    func startActivityIndicator(){
        
        facebookLoginButton.removeFromSuperview()
        twitterLoginButton.removeFromSuperview()
        
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        activityIndicator.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
    }
    
    func stopActivityIndicator(){
        self.activityIndicator.stopAnimating()
        self.view.addSubview(facebookLoginButton)
        self.view.addSubview(twitterLoginButton)
        //UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    
}

