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

class IdeaDetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
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
  
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.commentsTableView.registerClass(IdeaDetailTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.commentsTableView.dataSource = self
        self.commentsTableView.delegate = self
        self.commentsTableView.rowHeight = 85
        self.commentsTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        self.view.backgroundColor = UIColor.whiteColor()
        let topicContainerY = self.navigationController?.navigationBar.frame.maxY
        self.ideaTextView.delegate = self
        self.commentTextField.delegate = self
        
        commentsQuery()
        
        //MARK: - Topic Label
        var topicLabel = UILabel()
        if activeTopic["title"] != nil{
        topicLabel.text = activeTopic["title"] as? String
        }
//        topicLabel.userInteractionEnabled = false
//        topicLabel.editable = false
        topicLabel.font = UIFont(name: "Avenir-Heavy", size: 13)
        topicLabel.textColor = oneFiftyGrayColor
        topicLabel.numberOfLines = 0
        topicLabel.textAlignment = NSTextAlignment.Center
//        topicLabel.scrollEnabled = true
//        let maxWidth : CGFloat = self.view.frame.width - 34.7
//        let size = topicLabel.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.max))
//        topicLabel.sizeToFit()
//        self.automaticallyAdjustsScrollViewInsets = false
        topicLabel.frame = CGRectMake(5, topicContainerY!, self.view.frame.width - 10, 60)
        //println(size.height)
        self.view.addSubview(topicLabel)
        
        //MARK: - Upvote Button
        var numberOfUpvotesButton = UIButton()
        var numberOfUpvotes = Int()
        if activeIdea["numberOfUpvotes"] != nil{
            numberOfUpvotes = activeIdea["numberOfUpvotes"] as! Int
            let numberString = abbreviateNumber(numberOfUpvotes)
            numberOfUpvotesButton.setTitle(numberString as String, forState: .Normal)
            if let currentUser = PFUser.currentUser(){
                if activeIdea.objectForKey("usersWhoUpvoted")?.containsObject(currentUser) == true{
                    numberOfUpvotesButton.setTitleColor(redColor, forState: .Normal)
                    numberOfUpvotesButton.tintColor = redColor
                    hasUpvoted = true
                }else{
                    numberOfUpvotesButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    numberOfUpvotesButton.tintColor = UIColor.whiteColor()
                    hasUpvoted = false
                }
            }
        }else{
            numberOfUpvotesButton.setTitle("0", forState: .Normal)
            numberOfUpvotesButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
        
        numberOfUpvotesButton.frame =  CGRectMake(5, topicLabel.frame.maxY + 5, 40, 60)
        let arrowImage = UIImage(named: "upvoteArrow")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        numberOfUpvotesButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 10)
        numberOfUpvotesButton.setImage(arrowImage, forState: .Normal)
        let spacing = CGFloat(20)
        let imageSize = numberOfUpvotesButton.imageView!.image!.size
        let titleSize = numberOfUpvotesButton.titleLabel!.frame.size
        numberOfUpvotesButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, 0, 0)
        numberOfUpvotesButton.imageEdgeInsets = UIEdgeInsetsMake(-45, 0.0, 0.0, -titleSize.width)
        numberOfUpvotesButton.layer.cornerRadius = 3
        numberOfUpvotesButton.backgroundColor = oneFiftyGrayColor
        numberOfUpvotesButton.addTarget(self, action: "upvote:", forControlEvents: .TouchUpInside)
        self.view.addSubview(numberOfUpvotesButton)
        
        //MARK: - Avatar Button
        var ideaOwner = PFUser()
        var ownerAvatarFile = PFFile()
        var ownerImage = UIImage()
        var ownerUsername = String()
        var avatarButton = UIButton()
        if activeIdea["owner"] != nil{
            ideaOwner = activeIdea["owner"] as! PFUser
            if ideaOwner["avatar"] != nil{
                ownerAvatarFile = ideaOwner["avatar"] as! PFFile
                
                ownerAvatarFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil{
                        
                        ownerImage = UIImage(data: data!)!
                        ownerImage = cropToSquare(image: ownerImage)
                        ownerImage = ownerImage.convertToGrayScale()
                        avatarButton.setImage(ownerImage, forState: .Normal)
                        
                    }else{
                        
                        println("Error: \(error!.userInfo)")
                        
                    }
                })
            }
            
            
        }
        
        avatarButton.frame = CGRectMake(5, numberOfUpvotesButton.frame.maxY + 5, 40, 40)
        avatarButton.layer.cornerRadius = 20
        avatarButton.layer.masksToBounds = true
        avatarButton.addTarget(self, action: "ownerProfileTapped:", forControlEvents: .TouchUpInside)
        self.view.addSubview(avatarButton)
        
        //MARK: - Username Label
        var usernameLabel = UILabel(frame: CGRectMake(5, avatarButton.frame.maxY + 5, 40, 20))
        
        if ideaOwner["username"] != nil{
            
            usernameLabel.text = ideaOwner["username"] as? String
        }
        
        usernameLabel.font = UIFont(name: "Avenir-Light", size: 9)
        usernameLabel.textColor = fiftyGrayColor
        self.view.addSubview(usernameLabel)
        
        //MARK: - Idea Text View
        
        ideaTextView.frame = CGRectMake(numberOfUpvotesButton.frame.maxX + 5, topicLabel.frame.maxY + 5, self.view.frame.width - 55, 125)
        if activeIdea["content"] != nil{
            
            ideaTextView.text = activeIdea["content"] as! String
        }
        
        ideaTextView.font = UIFont(name: "Avenir", size: 11)
        ideaTextView.layer.borderColor = oneFiftyGrayColor.CGColor
        ideaTextView.layer.borderWidth = 1
        ideaTextView.layer.cornerRadius = 3
        ideaTextView.userInteractionEnabled = true
        ideaTextView.scrollEnabled = true
        ideaTextView.editable = false
        self.view.addSubview(ideaTextView)
        
        //MARK: - Comments Table View
        let commentDescriptionLabel = UILabel(frame: CGRectMake(ideaTextView.frame.minX, ideaTextView.frame.maxY + 2, 65, 20))
        commentDescriptionLabel.text = "Comments:"
        commentDescriptionLabel.font = UIFont(name: "Helvetica-Light", size: 11)
        self.view.addSubview(commentDescriptionLabel)
        
        commentsTableView.frame = CGRectMake(ideaTextView.frame.minX, commentDescriptionLabel.frame.maxY, ideaTextView.frame.width, 200)
        self.view.addSubview(commentsTableView)
        
        
        //MARK: - Share Button
        var shareButton = UIButton()
        shareButton.frame = CGRectMake(0, self.view.frame.maxY - 30, self.view.frame.width/2 - 0.5, 30)
        shareButton.setTitle("Share", forState: .Normal)
        shareButton.backgroundColor = sixtyThreeGrayColor
        shareButton.addTarget(self, action: "share:", forControlEvents: .TouchUpInside)
        shareButton.titleLabel?.font = UIFont(name: "Helvetica-Light", size: 14)
        self.view.addSubview(shareButton)
        
        //MARK: - Compose Button
        composeButton.frame = CGRectMake(shareButton.frame.maxX + 1, self.view.frame.maxY - 30, self.view.frame.width/2 - 0.5, 30)
        composeButton.setTitle("Compose", forState: .Normal)
        composeButton.backgroundColor = sixtyThreeGrayColor
        composeButton.addTarget(self, action: "compose:", forControlEvents: .TouchUpInside)
        composeButton.titleLabel?.font = UIFont(name: "Helvetica-Light", size: 14)
        self.view.addSubview(composeButton)
        
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
        
        
        
        // Do any additional setup after loading the view.
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
            //topicObjects = []
            println("got Objects")
            commentObjects = objects as! [PFObject]
            commentsTableView.reloadData()
        }else{
            println("Error: \(error.userInfo)")
        }
        //stopActivityIndicator()
        //refreshTable.endRefreshing()
    }
    
    func ownerProfileTapped(sender: UIButton!){
        
        
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
        self.tabBarController!.tabBar.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(){
            
            commentTextFieldContainter.frame = CGRectMake(0, self.view.frame.height - keyboardSize.height - 40, self.view.frame.width,40)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //
    }
    
    
    func compose(sender: UIButton!){
        println("compose")
        
        
    
    }
    
    func upvote(sender: UIButton!){
        
        if hasUpvoted == true{
            //Remove Upvote
            if let user = PFUser.currentUser(){
                activeIdea.removeObject(user, forKey: "usersWhoUpvoted")
                activeIdea.incrementKey("numberOfUpvotes", byAmount: -1)
                activeIdea.saveInBackground()
                
                var upvoteObjectQuery = PFQuery(className: "Upvote")
                upvoteObjectQuery.whereKey("userWhoUpvoted", equalTo: user)
                upvoteObjectQuery.whereKey("ideaUpvoted", equalTo: activeIdea)
                
                var upvoteObject = PFObject(className: "Upvote")
                
                upvoteObjectQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                    if error != nil{
                        
                    }else{
                        upvoteObject = object! as PFObject
                        upvoteObject.deleteInBackground()
                    }
                    let title = self.activeIdea["numberOfUpvotes"] as! Int
                    let numberString = abbreviateNumber(title)
                    sender.setTitle(numberString as String, forState: .Normal)
                    sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    sender.tintColor = UIColor.whiteColor()
                })
                
            }
            hasUpvoted = false
        }else{
            //Add Upvote
            if let user = PFUser.currentUser(){
                activeIdea.addObject(user, forKey: "usersWhoUpvoted")
                activeIdea.incrementKey("numberOfUpvotes")
                activeIdea.saveInBackground()
                
                var upvoteObject = PFObject(className: "Upvote")
                upvoteObject.setObject(user, forKey: "userWhoUpvoted")
                upvoteObject.setObject(activeIdea, forKey: "ideaUpvoted")
                upvoteObject.saveInBackground()
                
                let title = activeIdea["numberOfUpvotes"] as! Int
                let numberString = abbreviateNumber(title)
                sender.setTitle(numberString as String, forState: .Normal)
                sender.setTitleColor(redColor, forState: .Normal)
                sender.tintColor = redColor
                hasUpvoted = true
                
            }
        }
    }
    
    
    func share(sender: UIButton!){
        println("share")
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
