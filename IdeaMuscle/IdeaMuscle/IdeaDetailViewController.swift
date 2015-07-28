//
//  IdeaDetailViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/22/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import ParseUI
import Parse
import Social
import MessageUI

class IdeaDetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate {
    
    var activeIdea = PFObject(className: "Idea")
    var activeTopic = PFObject(className: "Topic")
    var commentObjects = [PFObject(className: "Comment")]
    var hasUpvoted = Bool()
    var ideaTextView = UITextView()
    var commentTextFieldContainter = UIView()
    var commentTextField = UITextField()
    var commentsTableView = UITableView()
    var composeButton = UIButton()
    var postCommentButton = UIButton()
    var characterCountLabel = UILabel()
    var ideaOwner = PFUser()
    var shareContainer = UIView()
    let gestureRecTextField = UITapGestureRecognizer()
    var ideaIsPublic = Bool()
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
  
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if var isPublic = activeIdea["isPublic"] as? Bool{
            if isPublic{
                ideaIsPublic = true
            }else{
                ideaIsPublic = false
            }
        }else{
            ideaIsPublic = false
        }
        
        reloadView()
        self.view.backgroundColor = UIColor.whiteColor()
        self.ideaTextView.delegate = self
        
//        if activeTopic["title"] == nil{
//            activeTopic = activeIdea["topicPointer"] as! PFObject
//        }

    }
    
    func reloadView(){
        
        if ideaIsPublic == true{
            self.commentsTableView.registerClass(IdeaDetailTableViewCell.self, forCellReuseIdentifier: "Cell")
            self.commentsTableView.dataSource = self
            self.commentsTableView.delegate = self
            self.commentsTableView.rowHeight = 85
            self.commentsTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
            self.commentTextField.delegate = self
            commentsQuery()
        }
        
        let topicContainerY = self.navigationController?.navigationBar.frame.maxY
        
        //MARK: Logo
        
        
        //MARK: - Topic Label
        var topicLabel = UILabel()
        if activeTopic["title"] != nil{
            topicLabel.text = activeTopic["title"] as? String
        }
        topicLabel.font = UIFont(name: "Avenir-Heavy", size: 12)
        topicLabel.textColor = UIColor.blackColor()
        topicLabel.numberOfLines = 0
        topicLabel.textAlignment = NSTextAlignment.Center
        topicLabel.frame = CGRectMake(5, topicContainerY!, self.view.frame.width - 10, 60)
        self.view.addSubview(topicLabel)
        
        //MARK: - Upvote Button
        var numberOfUpvotesButton = UIButton()
        numberOfUpvotesButton.addTarget(self, action: "upvote:", forControlEvents: .TouchUpInside)
        numberOfUpvotesButton.frame =  CGRectMake(5, topicLabel.frame.maxY + 5, 40, 60)
        if activeIdea["numberOfUpvotes"] != nil{
            
            if ideaIsPublic{
                hasUpvoted = getUpvotes(activeIdea, numberOfUpvotesButton, nil)
            }else{
                ideaIsNotPublic(numberOfUpvotesButton)
            }
        }
        
        self.view.addSubview(numberOfUpvotesButton)
        
        //MARK: - Avatar Button
        var avatarButton = UIImageView()
        
        if let ideaOwner = activeIdea["owner"] as? PFUser{
            getAvatar(ideaOwner, avatarButton, nil)
        }
        avatarButton.frame = CGRectMake(5, numberOfUpvotesButton.frame.maxY + 5, 40, 40)
        avatarButton.layer.cornerRadius = 20
        avatarButton.layer.masksToBounds = true
        let gestureRec = UITapGestureRecognizer(target: self, action: "ownerProfileTapped:")
        avatarButton.addGestureRecognizer(gestureRec)
        avatarButton.userInteractionEnabled = true
        self.view.addSubview(avatarButton)
        
        //MARK: - Username Label
        var usernameLabel = UILabel(frame: CGRectMake(5, avatarButton.frame.maxY + 5, 40, 20))
        if ideaOwner["username"] != nil{
            usernameLabel.text = ideaOwner["username"] as? String
        }
        usernameLabel.font = UIFont(name: "Avenir", size: 10)
        usernameLabel.textColor = oneFiftyGrayColor
        self.view.addSubview(usernameLabel)
        
        //MARK: - Idea Text View
        ideaTextView.frame = CGRectMake(numberOfUpvotesButton.frame.maxX + 5, topicLabel.frame.maxY + 5, self.view.frame.width - 55, 125)
        if activeIdea["content"] != nil{
            ideaTextView.text = activeIdea["content"] as! String
        }
        ideaTextView.font = UIFont(name: "Avenir-Light", size: 12)
        ideaTextView.layer.borderColor = oneFiftyGrayColor.CGColor
        ideaTextView.layer.borderWidth = 1
        ideaTextView.layer.cornerRadius = 3
        ideaTextView.userInteractionEnabled = true
        ideaTextView.scrollEnabled = true
        ideaTextView.editable = false
        self.view.addSubview(ideaTextView)
        
        //MARK: - Comments Table View
        if ideaIsPublic{
            let commentDescriptionLabel = UILabel(frame: CGRectMake(ideaTextView.frame.minX, ideaTextView.frame.maxY + 2, 65, 20))
            commentDescriptionLabel.text = "Comments:"
            commentDescriptionLabel.font = UIFont(name: "Helvetica-Light", size: 11)
            self.view.addSubview(commentDescriptionLabel)
            
            commentsTableView.frame = CGRectMake(ideaTextView.frame.minX, commentDescriptionLabel.frame.maxY, ideaTextView.frame.width, 200)
            self.view.addSubview(commentsTableView)
        }
        
        
        //MARK: - Share Button
        var shareButton = UIButton()
        shareButton.frame = CGRectMake(0, self.view.frame.maxY - 30, self.view.frame.width/2 - 0.5, 30)
        if ideaIsPublic{
            shareButton.setTitle("Share", forState: .Normal)
            shareButton.backgroundColor = sixtyThreeGrayColor
            shareButton.addTarget(self, action: "share:", forControlEvents: .TouchUpInside)
            shareButton.titleLabel?.font = UIFont(name: "Helvetica-Light", size: 14)
            self.view.addSubview(shareButton)
        }
        
        //MARK: - Compose Button
        composeButton.frame = CGRectMake(shareButton.frame.maxX + 1, self.view.frame.maxY - 30, self.view.frame.width/2 - 0.5, 30)
        composeButton.setTitle("Compose", forState: .Normal)
        composeButton.backgroundColor = sixtyThreeGrayColor
        composeButton.addTarget(self, action: "compose:", forControlEvents: .TouchUpInside)
        composeButton.titleLabel?.font = UIFont(name: "Helvetica-Light", size: 14)
        self.view.addSubview(composeButton)
        
        if ideaIsPublic{
        
            //MARK: - Comment container and Text Field
            commentTextFieldContainter.backgroundColor = oneFiftyGrayColor
            commentTextFieldContainter.frame = CGRectMake(0, composeButton.frame.minY - 40, self.view.frame.width, 40)
            self.view.addSubview(commentTextFieldContainter)
            
            commentTextField.layer.cornerRadius = 3
            commentTextField.backgroundColor = UIColor.whiteColor()
            commentTextField.font = UIFont (name: "Avenir", size: 10)
            commentTextField.frame = CGRectMake(5, 5, self.view.frame.width - 55, commentTextFieldContainter.frame.height - 10)
            commentTextField.placeholder = "  Write a comment"
            commentTextField.tintColor = redColor
            let paddingView = UIView(frame: CGRectMake(0, 0, 50, commentTextField.frame.height))
            commentTextField.rightView = paddingView
            commentTextField.rightViewMode = UITextFieldViewMode.Always
            //commentTextField.returnKeyType = UIReturnKeyType.Done
            if let user = PFUser.currentUser(){
                if let isPro = user["isPro"] as? Bool{
                    if isPro == false{
                        
                        gestureRecTextField.addTarget(self, action: "upgradeAlert:")
                        gestureRecTextField.delegate = self
                        commentTextField.addGestureRecognizer(gestureRecTextField)
                    }
                }
            }
            
            
            commentTextFieldContainter.addSubview(commentTextField)
            
            //MARK: - Post comment button
            postCommentButton.frame = CGRectMake(commentTextField.frame.maxX + 5, commentTextFieldContainter.frame.height/2 - 10, 40, 20)
            postCommentButton.setTitle("Post", forState: .Normal)
            postCommentButton.titleLabel!.font = UIFont(name: "Helvetica-Light", size: 13)
            postCommentButton.addTarget(self, action: "postComment:", forControlEvents: .TouchUpInside)
            postCommentButton.enabled = false
            postCommentButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            commentTextFieldContainter.addSubview(postCommentButton)
            
            //MARK: - character Count Label
            characterCountLabel.frame = CGRectMake(commentTextField.frame.maxX - 42, commentTextFieldContainter.frame.height/2 - 10, 100, 20)
            characterCountLabel.font = UIFont(name: "Helvetica-Light", size: 11)
            characterCountLabel.textColor = fiftyGrayColor
            characterCountLabel.text = "\(characterCount)" + "/118"
            commentTextFieldContainter.addSubview(characterCountLabel)
            
            //MARK: - Share Container and Buttons
            shareContainer.frame = CGRectMake(0, self.view.frame.maxY + 105, self.view.frame.width, 180)
            shareContainer.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(shareContainer)
            
            let twitterShareButton = UIButton()
            let facebookShareButton = UIButton()
            let emailShareButton = UIButton()
            let cancelShareButton = UIButton()
            
            twitterShareButton.frame = CGRectMake(5, 0, shareContainer.frame.width - 10, 40)
            facebookShareButton.frame = CGRectMake(5, twitterShareButton.frame.maxY + 5, shareContainer.frame.width - 10, 40)
            emailShareButton.frame = CGRectMake(5, facebookShareButton.frame.maxY + 5, shareContainer.frame.width - 10, 40)
            cancelShareButton.frame = CGRectMake(5, emailShareButton.frame.maxY + 5, shareContainer.frame.width - 10, 40)
            
            twitterShareButton.backgroundColor = fiftyGrayColor
            facebookShareButton.backgroundColor = fiftyGrayColor
            emailShareButton.backgroundColor = fiftyGrayColor
            cancelShareButton.backgroundColor = fiftyGrayColor
            
            twitterShareButton.setTitle("Twitter", forState: .Normal)
            facebookShareButton.setTitle("Facebook", forState: .Normal)
            emailShareButton.setTitle("Email", forState: .Normal)
            cancelShareButton.setTitle("Cancel", forState: .Normal)
            
            twitterShareButton.addTarget(self, action: "shareTwitter:", forControlEvents: .TouchUpInside)
            facebookShareButton.addTarget(self, action: "shareFacebook:", forControlEvents: .TouchUpInside)
            emailShareButton.addTarget(self, action: "shareEmail:", forControlEvents: .TouchUpInside)
            cancelShareButton.addTarget(self, action: "shareCancel:", forControlEvents: .TouchUpInside)
            
            shareContainer.addSubview(twitterShareButton)
            shareContainer.addSubview(facebookShareButton)
            shareContainer.addSubview(emailShareButton)
            shareContainer.addSubview(cancelShareButton)
        }
        
    }
    
    func ideaIsNotPublic(button: UIButton){
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 10)
        button.layer.cornerRadius = 3
        button.backgroundColor = oneFiftyGrayColor
        button.setTitle("Make Public", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        button.titleLabel?.textAlignment = NSTextAlignment.Center
    }
    
    func makePublic(button: UIButton){
        if let user = PFUser.currentUser(){
            if let isPro = user["isPro"] as? Bool{
                if isPro{
                    let idea = activeIdea
                    idea.ACL?.setPublicReadAccess(true)
                    idea.ACL?.setPublicWriteAccess(true)
                    idea["isPublic"] = true
                    ideaIsPublic = true
                    idea.saveEventually()
                    hasUpvoted = getUpvotes(idea, button, nil)
                    reloadView()
                }else{
                    upgradeAlertMakePublic()
                }
            }else{
                upgradeAlertMakePublic()
            }
        }
    }
    
    func upgradeAlertMakePublic(){
        let upgradeAlert: UIAlertController = UIAlertController(title: "Upgrade Required", message: "You must upgrade to Pro to make ideas public after posting", preferredStyle: .Alert)
        upgradeAlert.view.tintColor = redColor
        upgradeAlert.view.backgroundColor = oneFiftyGrayColor
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        upgradeAlert.addAction(cancelAction)
        
        let goToStore: UIAlertAction = UIAlertAction(title: "Go To Store", style: .Default, handler: { (action) -> Void in
            let storeVC = StoreViewController()
            let navVC = UINavigationController(rootViewController: storeVC)
            self.presentViewController(navVC, animated: true, completion: nil)
            
        })
        
        upgradeAlert.addAction(goToStore)
        self.presentViewController(upgradeAlert, animated: true, completion: nil)
    }
    
    func upgradeAlert(sender: UITextField){
        upgradeAlertShow()
    }
    
    func upgradeAlertShow(){
        let upgradeAlert: UIAlertController = UIAlertController(title: "Upgrade Required", message: "You must upgrade to Pro to comment on ideas.", preferredStyle: .Alert)
        upgradeAlert.view.tintColor = redColor
        upgradeAlert.view.backgroundColor = oneFiftyGrayColor
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        upgradeAlert.addAction(cancelAction)
        
        let goToStore: UIAlertAction = UIAlertAction(title: "Go To Store", style: .Default, handler: { (action) -> Void in
            let storeVC = StoreViewController()
            let navVC = UINavigationController(rootViewController: storeVC)
            self.presentViewController(navVC, animated: true, completion: nil)
            
        })
        
        upgradeAlert.addAction(goToStore)
        self.presentViewController(upgradeAlert, animated: true, completion: nil)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if let user = PFUser.currentUser(){
            if let isPro = user["isPro"] as? Bool{
                if isPro == false{
                    return false
                }else{
                    return true
                }
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    func shareTwitter(sender: UIButton!){
        shareContainer.frame = CGRectMake(0, self.view.frame.maxY + 180, self.view.frame.width, 180)
        let twitterComposeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        
        let ideaString = activeIdea["content"] as! String
        let stringCount = count(ideaString)
        let characterAllowance = 117
        if stringCount > characterAllowance{
            let twitterString = ideaString.substringWithRange(Range<String.Index>(start: ideaString.startIndex, end: advance(ideaString.startIndex, characterAllowance)))
            twitterComposeVC.setInitialText(twitterString)
        }else{
            twitterComposeVC.setInitialText(ideaString)
        }
        let deeplink = HOKDeeplink(route: "ideas/:ideaId", routeParameters: ["ideaId": activeIdea.objectId!])
        
        Hoko.deeplinking().generateSmartlinkForDeeplink(deeplink, success: { (smartlink) -> Void in
            var url = NSURL()
            url = NSURL(string: smartlink)!
            twitterComposeVC.addURL(url)
            self.presentViewController(twitterComposeVC, animated: true, completion: nil)
            
        }) { (error) -> Void in
        }
    }
    
    func shareFacebook(sender: UIButton!){
        shareContainer.frame = CGRectMake(0, self.view.frame.maxY + 180, self.view.frame.width, 180)
        let facebookComposeVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        let ideaString = activeIdea["content"] as! String
        let deeplink = HOKDeeplink(route: "ideas/:ideaId", routeParameters: ["ideaId": activeIdea.objectId!])
        Hoko.deeplinking().generateSmartlinkForDeeplink(deeplink, success: { (smartlink) -> Void in
            var url = NSURL()
            url = NSURL(string: smartlink)!
            facebookComposeVC.addURL(url)
            //Doesn't work anymore
            //facebookComposeVC.setInitialText(ideaString)
            self.presentViewController(facebookComposeVC, animated: true, completion: nil)
            
            }) { (error) -> Void in
        }
    }
    
    func shareEmail(sender: UIButton!){
        shareContainer.frame = CGRectMake(0, self.view.frame.maxY + 180, self.view.frame.width, 180)
        
        let emailVC = MFMailComposeViewController()
        emailVC.mailComposeDelegate = self
        let ideaString = activeIdea["content"] as! String
        let deeplink = HOKDeeplink(route: "ideas/:ideaId", routeParameters: ["ideaId": activeIdea.objectId!])
        
        Hoko.deeplinking().generateSmartlinkForDeeplink(deeplink, success: { (smartlink) -> Void in
            let user = PFUser.currentUser()!
            let username = user["username"] as! String
            let body = ideaString + " " + smartlink
            
            emailVC.setSubject(username + " has sent you an idea from IdeaMuscle")
            emailVC.setMessageBody(body, isHTML: true)
            emailVC.navigationBar.tintColor = redColor
            
            self.presentViewController(emailVC, animated: true, completion: nil)
            
            }) { (error) -> Void in
        }
        
        
        
    }
    
    func shareCancel(sender: UIButton!){
        shareContainer.frame = CGRectMake(0, self.view.frame.maxY + 180, self.view.frame.width, 180)
        println("share Cancel")
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! IdeaDetailTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.frame = CGRectMake(0, 0, tableView.frame.width, 85)
        
        //MARK: - Username Label
        cell.usernameLabel.frame = CGRectMake(5, 5, 200, 20)
        if commentObjects[indexPath.row]["owner"] != nil{
            
            let owner = commentObjects[indexPath.row]["owner"] as! PFObject
            
            cell.usernameLabel.text = owner["username"] as? String
        }
        
        cell.usernameLabel.font = UIFont(name: "Avenir-Heavy", size: 12)
        cell.usernameLabel.textColor = fiftyGrayColor
        let gestureRec = UITapGestureRecognizer(target: self, action: "profileTapped:")
        cell.usernameLabel.addGestureRecognizer(gestureRec)
        cell.usernameLabel.userInteractionEnabled = true
        cell.usernameLabel.tag = indexPath.row
        
        //MARK: - Time Ago Stamp
        var createdAt = NSDate()
        
        if commentObjects[indexPath.row].createdAt != nil{
            createdAt = commentObjects[indexPath.row].createdAt!
            cell.timeAgoStampLabel.text = createdAt.timeAgoSimple
        }
        cell.timeAgoStampLabel.frame = CGRectMake(cell.frame.maxX - 50, 5, 40, 20)
        cell.timeAgoStampLabel.font = UIFont(name: "Avenir", size: 9)
        cell.timeAgoStampLabel.textColor = oneFiftyGrayColor
        
        
        //MARK: - Comment Label
        cell.commentLabel.numberOfLines = 0
        cell.commentLabel.frame = CGRectMake(5, cell.usernameLabel.frame.maxY, cell.frame.width - 10, 55)
        
        if commentObjects[indexPath.row]["content"] != nil{
            
            cell.commentLabel.text = commentObjects[indexPath.row]["content"] as? String
        }
        cell.commentLabel.font = UIFont(name: "Avenir", size: 10)
        cell.commentLabel.textColor = oneFiftyGrayColor
        
        
        return cell
    }
    
    
    func commentsQuery(){
        
        var query = PFQuery(className: "Comment")
        query.whereKey("ideaPointer", equalTo: activeIdea)
        query.orderByAscending("createdAt")
        query.includeKey("owner")
        query.includeKey("createdAt")
        query.findObjectsInBackgroundWithTarget(self, selector: "commentSelector:error:")
    }
    
    func commentSelector(objects: [AnyObject]!, error: NSError!){
        
        if error == nil{
            commentObjects = objects as! [PFObject]
            commentsTableView.reloadData()
        }else{
            println("Error: \(error.userInfo)")
        }
        //stopActivityIndicator()
        //refreshTable.endRefreshing()
    }
    
    func ownerProfileTapped(sender: UIButton!){
        
        let profileVC = ProfileViewController()
        ideaOwner = activeIdea["owner"] as! PFUser
        profileVC.activeUser = ideaOwner
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func profileTapped(sender: AnyObject){
        let profileVC = ProfileViewController()
        if commentObjects[sender.view!.tag]["owner"] != nil{
        profileVC.activeUser = commentObjects[sender.view!.tag]["owner"] as! PFUser
        navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
        commentTextFieldContainter.frame = CGRectMake(0, composeButton.frame.minY - 40, self.view.frame.width, 40)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        commentTextFieldContainter.frame = CGRectMake(0, composeButton.frame.minY - 40, self.view.frame.width, 40)
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        if tabBarController != nil{
        self.tabBarController!.tabBar.hidden = true
        }
        
        if let user = PFUser.currentUser(){
            if let isPro = user["isPro"] as? Bool{
                if isPro == true{
                    gestureRecTextField.enabled = false
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(){
        
            
            commentTextFieldContainter.frame = CGRectMake(0, keyboardSize.minY - 40, self.view.frame.width, 40)
        }
    }
    

    
    func keyboardWillHide(notification: NSNotification) {
        //
    }
    
    
    
    func compose(sender: UIButton!){

        composeFromDetail(self, activeTopic, false)
    }
    
    func upvote(sender: UIButton!){
        
        if ideaIsPublic == true{
        
            if hasUpvoted == true{
                //Remove Upvote
                        upvoteGlobal(activeIdea, false, sender)
                        hasUpvoted = false
            }else{
                //Add Upvote
                    upvoteGlobal(activeIdea, true, sender)
                    hasUpvoted = true
            }
        }else{
            makePublic(sender)
        }
    }
    
    
    func share(sender: UIButton!){

       shareContainer.frame = CGRectMake(0, self.view.frame.maxY - 180, self.view.frame.width, 180)
        self.view.bringSubviewToFront(shareContainer)
        
    }
    
    func postComment(sender: UIButton!){
        println("comment Posted")
        
        if commentTextField != ""{
            
            var comment = PFObject(className: "Comment")
            comment["content"] = commentTextField.text
            comment["ideaPointer"] = activeIdea
            if PFUser.currentUser() != nil{
            comment["owner"] = PFUser.currentUser()
            }
            comment.saveInBackgroundWithTarget(self, selector: "commentSave:error:")
            
        }
        
        commentTextField.resignFirstResponder()
        commentTextField.text = ""
        characterCount = 0
        characterCountLabel.text = "\(characterCount)" + "/118"
        postCommentButton.enabled = false
        postCommentButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)

        
        commentTextFieldContainter.frame = CGRectMake(0, composeButton.frame.minY - 40, self.view.frame.width, 40)
    }
    
    func commentSave(wasSuccesful: Bool, error: NSError?){
        
        if error == nil{
            
            commentsQuery()
        }else{
            println("Error: \(error!.userInfo)")
            
        }
    }
    
    var characterCount = 0
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if string == "" {
            if characterCount > 0{
                
                --characterCount
                characterCountLabel.text = "\(characterCount)" + "/118"
                if characterCount == 0{
                    postCommentButton.enabled = false
                    postCommentButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                }
                return true
            }else{
                
                return false
            }
            
            
        }else if characterCount == 118{
            return false
        }else if string == " "{
            if characterCount > 0{
                
                ++characterCount
                characterCountLabel.text = "\(characterCount)" + "/118"
                postCommentButton.enabled = true
                postCommentButton.setTitleColor(redColor, forState: .Normal)
                return true
            }else{
                return false
            }
            
            
            
        }else{
            ++characterCount
            characterCountLabel.text = "\(characterCount)" + "/118"
            postCommentButton.enabled = true
            postCommentButton.setTitleColor(redColor, forState: .Normal)
            return true
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
