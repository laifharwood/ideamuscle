//
//  ComposeViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/8/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse



class ComposeViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate{
    
    var publicAlreadyEncountered = false
    var tableView: UITableView = UITableView()
    var activeComposeTopicObject = PFObject(className: "Topic")
    
    let grayCheckmarkImage = UIImage(named: "checkmarkGray")
    let redCheckmarkImage = UIImage(named: "checkmarkRed")
    var publicBoolArray = [false, false, false, false, false, false, false, false, false, false]
    var topicLabel = UILabel()
    var numberOfPublic = 0
    var saveDraftContainer = UIView()
    var shouldStartEditing = true
    var draftObject = PFObject(className: "Draft")
    var isADraft = Bool()
    var hasAddedTopic = Bool()
    let invisibleView = UIView()
    
    
    
    //MARK: - UIViews for text views
    var frameOne = UIView()
    var frameTwo = UIView()
    var frameThree = UIView()
    var frameFour = UIView()
    var frameFive = UIView()
    var frameSix = UIView()
    var frameSeven = UIView()
    var frameEight = UIView()
    var frameNine = UIView()
    var frameTen = UIView()
    
    var frameArray = [UIView]()
    
    
    var textViewOne = UITextView()
    var textViewTwo = UITextView()
    var textViewThree = UITextView()
    var textViewFour = UITextView()
    var textViewFive = UITextView()
    var textViewSix = UITextView()
    var textViewSeven = UITextView()
    var textViewEight = UITextView()
    var textViewNine = UITextView()
    var textViewTen = UITextView()
    
    var textViewArray = [UITextView]()
    var textViewValues = ["", "", "", "", "", "", "", "", "", ""]
    
    var submitButton = UIButton()
    
    
    
   
    override func viewDidAppear(animated: Bool) {
        
        if activeComposeTopicObject["title"] != nil{
        topicLabel.text = activeComposeTopicObject["title"] as? String
        }
        
        if shouldStartEditing == true{
            textViewOne.becomeFirstResponder()
        }

   }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = twoHundredGrayColor
        
        textViewOne.delegate = self
        textViewTwo.delegate = self
        textViewThree.delegate = self
        textViewFour.delegate = self
        textViewFive.delegate = self
        textViewSix.delegate = self
        textViewSeven.delegate = self
        textViewEight.delegate = self
        textViewNine.delegate = self
        textViewTen.delegate = self
        
        textViewOne.text = textViewValues[0]
        textViewTwo.text = textViewValues[1]
        textViewThree.text = textViewValues[2]
        textViewFour.text = textViewValues[3]
        textViewFive.text = textViewValues[4]
        textViewSix.text = textViewValues[5]
        textViewSeven.text = textViewValues[6]
        textViewEight.text = textViewValues[7]
        textViewNine.text = textViewValues[8]
        textViewTen.text = textViewValues[9]
        
        
        // MARK: - Top Bar Config
        var topBar = UIView()
        topBar.frame = CGRectMake(0, 0, self.view.frame.width, 64)
        topBar.backgroundColor = seventySevenGrayColor
        self.view.addSubview(topBar)
        
            // MARK: - Compose Title
            var title = UILabel()
            title.text = "Compose 10 Ideas"
            title.font = UIFont(name: "Avenir", size: 13)
            title.textColor = UIColor.whiteColor()
            title.frame = CGRectMake(topBar.frame.width/2 - 60, topBar.frame.height/2, 120, 16)
            topBar.addSubview(title)
            title.textAlignment = NSTextAlignment.Center
        
            //MARK: - Cancel Button
            var cancelButton = UIButton()
            cancelButton.frame = CGRectMake(0, topBar.frame.height/2, 60, 16)
            cancelButton.setTitle("Cancel", forState: .Normal)
            cancelButton.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 15)
            cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            cancelButton.addTarget(nil, action: "cancel:", forControlEvents: .TouchUpInside)
            topBar.addSubview(cancelButton)
        
            //MARK: - Small Logo Right
            var logoView = UIImageView(image: smallLogo)
            logoView.frame = CGRectMake(topBar.frame.width - 40, topBar.frame.height/2 - 7.5, 35, 35)
            topBar.addSubview(logoView)
        
        //MARK: - Topic Title Bar
        var topicTitleBar = UIView()
        topicTitleBar.frame = CGRectMake(0, topBar.frame.maxY + 10, self.view.frame.width, 60)
        topicTitleBar.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(topicTitleBar)
        
            //MARK: - Topic Title Label
            topicLabel = UILabel(frame: CGRectMake(2.5, 2.5, topicTitleBar.frame.width - 5, topicTitleBar.frame.height - 5))
            if activeComposeTopicObject["title"] != nil{
                topicLabel.text = activeComposeTopicObject["title"] as? String
            }
            topicLabel.textColor = UIColor.blackColor()
            topicLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
            topicLabel.numberOfLines = 3
            topicLabel.textAlignment = NSTextAlignment.Center
            topicTitleBar.addSubview(topicLabel)
            
       //MARK: - Table View Config
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRectMake(0, topicTitleBar.frame.maxY + 5, self.view.frame.width, self.view.frame.height - 129)
        //tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 70
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        //tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0)
        self.view.addSubview(tableView)
        
        //MARK: - Save Draft Popup
        saveDraftContainer.frame = CGRectMake(0, self.view.frame.maxY, self.view.frame.width, 140)
        saveDraftContainer.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(saveDraftContainer)
        
        let deleteDraftButton = UIButton(frame: CGRectMake(5, 5, self.view.frame.width - 10, 40))
        let saveDraftButton = UIButton(frame: CGRectMake(5, deleteDraftButton.frame.maxY + 5, self.view.frame.width - 10, 40))
        let cancelExitButton = UIButton(frame: CGRectMake(5, saveDraftButton.frame.maxY + 5, self.view.frame.width - 10, 40))
        
        deleteDraftButton.setTitle("Delete Draft", forState: .Normal)
        saveDraftButton.setTitle("Save Draft", forState: .Normal)
        cancelExitButton.setTitle("Cancel", forState: .Normal)
        
        deleteDraftButton.backgroundColor = oneFiftyGrayColor
        saveDraftButton.backgroundColor = oneFiftyGrayColor
        cancelExitButton.backgroundColor = twoHundredGrayColor
        
        deleteDraftButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        saveDraftButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        cancelExitButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        
        deleteDraftButton.layer.cornerRadius = 3
        saveDraftButton.layer.cornerRadius = 3
        cancelExitButton.layer.cornerRadius = 3
        
        
        deleteDraftButton.setTitleColor(redColor, forState: .Normal)
        saveDraftButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cancelExitButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        deleteDraftButton.addTarget(self, action: "deleteDraft:", forControlEvents: .TouchUpInside)
        saveDraftButton.addTarget(self, action: "saveDraft:", forControlEvents: .TouchUpInside)
        cancelExitButton.addTarget(self, action: "cancelExit:", forControlEvents: .TouchUpInside)
        
        saveDraftContainer.addSubview(deleteDraftButton)
        saveDraftContainer.addSubview(saveDraftButton)
        saveDraftContainer.addSubview(cancelExitButton)
        
        
        
    }
    
    func deleteDraft(sender: UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveDraft(sender: UIButton){
        if let user = PFUser.currentUser(){
            if let isPro = user["isPro"] as? Bool{
                if isPro == true{
                    //Save the draft
                    let draftObject = PFObject(className: "Draft")
                    draftObject["userPointer"] = user
                    draftObject["topicPointer"] = activeComposeTopicObject
                    draftObject["isPublicArray"] = publicBoolArray
                    draftObject.ACL?.setPublicReadAccess(false)
                    var ideaArray = [String]()
                    for textView in textViewArray{
                        ideaArray.append(textView.text)
                    }
                    draftObject["ideaArray"] = ideaArray
                    draftObject.saveEventually()
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                }else{
                    upgradeToSaveDraftAlert()
                }
            }else{
                upgradeToSaveDraftAlert()
            }
        }

    }
    
    func cancelExit(sender: UIButton){
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.saveDraftContainer.frame = CGRectMake(0, self.view.frame.maxY, self.view.frame.width, 140)
        })
        
        invisibleView.removeFromSuperview()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 16
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        //MARK: - Create Reusable Cell
        let cell = UITableViewCell()
        
        
        cell.backgroundColor = twoHundredGrayColor
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if indexPath.row < 10 {
        
        //MARK: - frameArray Initialize
        let frameArray = [frameOne, frameTwo, frameThree, frameFour, frameFive, frameSix, frameSeven, frameEight, frameNine, frameTen]
        
        for frame in frameArray{
            frame.frame = CGRectMake(0, 5, cell.frame.width, 60)
            frame.backgroundColor = seventySevenGrayColor
            
        }
        
        
        cell.addSubview(frameArray[indexPath.row])
        
        //MARK: - Number Label
        let numberArray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        var numberLabel = UILabel()
        numberLabel.frame = CGRectMake(5, frameArray[indexPath.row].frame.height/2 - 10, 20, 20)
        numberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        numberLabel.textColor = UIColor.whiteColor()
        numberLabel.text = "\(numberArray[indexPath.row])"
        frameArray[indexPath.row].addSubview(numberLabel)
        
        
        //MARK: - Text View
        self.textViewArray = [textViewOne, textViewTwo, textViewThree, textViewFour, textViewFive, textViewSix, textViewSeven, textViewEight, textViewNine, textViewTen]
        
        var index = 0
        
        for textView in textViewArray{
            
            textView.tag = index
            ++index
            
        }
        for textView in textViewArray{
            textView.frame = CGRectMake(numberLabel.frame.width + 5, 5, self.view.frame.width - numberLabel.frame.width - 70, frameArray[indexPath.row].frame.height - 10)
            textView.backgroundColor = UIColor.whiteColor()
            textView.layer.cornerRadius = 3
            textView.layer.masksToBounds = true
            textView.textColor = fiftyGrayColor
            textView.font = UIFont(name: "HelveticaNeue-Light", size: 10)
            textView.returnKeyType = UIReturnKeyType.Default
            textView.tintColor = redColor
            //textView.text = textViewValues[indexPath.row]
            
        }
        frameArray[indexPath.row].addSubview(textViewArray[indexPath.row])
        
        
        //MARK: - Make Public Label
        var mPLabelX = CGFloat()
        mPLabelX = textViewArray[indexPath.row].frame.maxX + (cell.frame.width - textViewArray[indexPath.row].frame.maxX)/2 - 25
        
        let makePublicLabel = UILabel(frame: CGRectMake(mPLabelX,5, 70, 15))
        makePublicLabel.text = "Make Public?"
        makePublicLabel.textColor = UIColor.whiteColor()
        makePublicLabel.font = UIFont(name: "HelveticaNeue-Light", size: 9)
        frameArray[indexPath.row].addSubview(makePublicLabel)
        
        
        //MARK: - Checkmark Button
        let checkmarkButton = UIButton(frame: CGRectMake(mPLabelX + 8.75, makePublicLabel.frame.maxY + 2.5, 35, 27.8))
            if publicBoolArray[indexPath.row] == false{
        checkmarkButton.setImage(grayCheckmarkImage, forState: .Normal)
            }else{
                checkmarkButton.setImage(redCheckmarkImage, forState: .Normal)
            }
            
        //checkmarkButton.setImage(redCheckmarkImage, forState: .Selected)
        checkmarkButton.tag = indexPath.row
        checkmarkButton.addTarget(self, action: "makePublic:", forControlEvents: .TouchUpInside)
        
        frameArray[indexPath.row].addSubview(checkmarkButton)
            
        }else if indexPath.row == 10{
            
            for view in cell.subviews{
                
                view.removeFromSuperview()
            }
            
            submitButton.frame = CGRectMake(cell.frame.width/2 - 75, 5, 150, 50)
            submitButton.setTitle("Submit", forState: .Normal)
            submitButton.setTitleColor(twoHundredGrayColor, forState: .Disabled)
            submitButton.setTitleColor(redColor, forState: .Normal)
            submitButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
            submitButton.backgroundColor = fiftyGrayColor
            submitButton.layer.cornerRadius = 2
            submitButton.addTarget(self, action: "submit:", forControlEvents: .TouchUpInside)
            checkForSumbitActive()
            
            
            cell.addSubview(submitButton)
            
            
            
        }else{
            
            for view in cell.subviews{
                
                view.removeFromSuperview()
            }
        }
        
    
        return cell
    }
    
    
    var activeTextView = 0
    
    
    
    func textViewDidEndEditing(textView: UITextView) {
    
        checkForSumbitActive()
        
    }
    
    func checkForSumbitActive(){
        
        if textViewOne.text != "" && textViewTwo.text != "" && textViewThree.text != "" && textViewFour.text != "" && textViewFive.text != "" && textViewSix.text != "" && textViewSeven.text != "" && textViewEight.text != "" && textViewNine.text != "" && textViewTen.text != ""{
            submitButton.enabled = true
            submitButton.alpha = 1
        }else{
            
            submitButton.enabled = false
            submitButton.alpha = 0.2
        }
        
        
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            
            textView.resignFirstResponder()
            
            if textView.tag < 10{
                var pathToScroll = NSIndexPath()
                pathToScroll = NSIndexPath(forRow: textView.tag + 1, inSection: 0)
                
                tableView.scrollToRowAtIndexPath(pathToScroll, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                if textView.tag < 9{
                textViewArray[textView.tag + 1].becomeFirstResponder()
                }
            }
            return false
        }else{
            
        
        return true
        
        }
        
        
    }
    
    func textViewDidChange(textView: UITextView) {
        checkForSumbitActive()
    }
    
    func setHasPosted(user: PFUser){
        user["hasPosted"] = true
        user.saveInBackground()
        
        let query = PFQuery(className: "LastPosted")
        query.whereKey("userPointer", equalTo: user)
        query.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            if error == nil{
                let lastPostedObject = object as PFObject!
                lastPostedObject.incrementKey("update")
                lastPostedObject.saveInBackground()
            }
        })
    }
    

    
    func submit(sender: UIButton!){
        
        if let user = PFUser.currentUser(){
            var counter = 0
            if let isPro = user["isPro"] as? Bool{
                if isPro == false{
                    setHasPosted(user)
                }
            }else{
                setHasPosted(user)
            }
            for textV in textViewArray{
                if publicBoolArray[counter] == true{
                    saveIdea(textV, user: user, isPublic: true)
                }else{
                    saveIdea(textV, user: user, isPublic: false)
                }
                ++counter
            }
            publicAlreadyEncountered = false
        
            if isADraft == true{
                    draftObject.deleteInBackgroundWithBlock({ (success, error) -> Void in
                    println("should dismiss")
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }else{
                println("should dismiss")
               self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func saveIdea(textV: UITextView, user: PFUser, isPublic: Bool){
        var ideaObject = PFObject(className: "Idea")
        ideaObject["content"] = textV.text
        ideaObject["topicPointer"] = activeComposeTopicObject
        ideaObject["owner"] = user
        if isPublic == true{
            ideaObject["isPublic"] = true
            ideaObject.ACL?.setPublicReadAccess(true)
            ideaObject.ACL?.setPublicWriteAccess(true)
        }else if isPublic == false{
            ideaObject["isPublic"] = false
            ideaObject.ACL?.setPublicWriteAccess(false)
            ideaObject.ACL?.setPublicReadAccess(false)
        }
        
        ideaObject.incrementKey("numberOfUpvotes")
        ideaObject.addObject(user, forKey: "usersWhoUpvoted")
        ideaObject.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success{
                
                var upvoteObject = PFObject(className: "Upvote")
                upvoteObject["userWhoUpvoted"] = user
                upvoteObject["ideaUpvoted"] = ideaObject
                upvoteObject.saveInBackground()
                
                if isPublic == true{
                    self.activeComposeTopicObject.incrementKey("numberOfIdeas")
                    self.activeComposeTopicObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success{
                            if self.hasAddedTopic == false{
                                self.addTopicsComposedFor(user)
                            }
                        }else{
                            
                        }
                    })
                }else{
                    if self.hasAddedTopic == false{
                        self.addTopicsComposedFor(user)
                    }
                }
            }
        })
        if isPublic == true{
            if publicAlreadyEncountered == false{
                
                activeComposeTopicObject["isPublic"] = true
                activeComposeTopicObject.ACL?.setPublicReadAccess(true)
                activeComposeTopicObject.ACL?.setPublicWriteAccess(true)
                activeComposeTopicObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success{
                        self.publicAlreadyEncountered = true
                    }
                })
            }
        }
    }
    
    func addTopicsComposedFor(user: PFUser){
        let topicComposedFor = PFObject(className: "TopicsComposedFor")
        topicComposedFor["userPointer"] = user
        topicComposedFor["topicPointer"] = activeComposeTopicObject
        topicComposedFor.ACL?.setPublicWriteAccess(false)
        topicComposedFor.ACL?.setPublicReadAccess(false)
        topicComposedFor.saveEventually()
        hasAddedTopic = true
    }
    
    func makePublic(sender: UIButton){
        if publicBoolArray[sender.tag] == false{
        if let user = PFUser.currentUser(){
            if let isPro = user["isPro"] as? Bool{
                if isPro{
                    canMakePublic(sender)
                }else if numberOfPublic < 1{
                    canMakePublic(sender)
                }else{
                    //Show Alert To Upgrade
                    println("should show alert")
                    upgradeAlert()
                }
            }else{
                if numberOfPublic < 1{
                    canMakePublic(sender)
                }else{
                    //Show Alert To Upgrade
                    println("should show alert")
                    upgradeAlert()
                }
            }
        }
        }else if publicBoolArray[sender.tag] == true{
            sender.setImage(grayCheckmarkImage, forState: .Normal)
            publicBoolArray[sender.tag] = false
            --numberOfPublic
        }
        
    }
    
    func canMakePublic(sender: UIButton){
            sender.setImage(redCheckmarkImage, forState: .Normal)
            publicBoolArray[sender.tag] = true
            ++numberOfPublic
    }
    
    func upgradeAlert(){
        let upgradeAlert: UIAlertController = UIAlertController(title: "Upgrade Required", message: "As a free user you are only allowed 1 public idea per group of 10. Upgrade to Pro to post unlimited public ideas.", preferredStyle: .Alert)
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
    
    func upgradeToSaveDraftAlert(){
        let upgradeAlert: UIAlertController = UIAlertController(title: "Upgrade Required", message: "You must upgrade to IdeaMuscle Pro to save drafts.", preferredStyle: .Alert)
        upgradeAlert.view.tintColor = redColor
        upgradeAlert.view.backgroundColor = oneFiftyGrayColor
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        upgradeAlert.addAction(cancelAction)
        
        let goToStore: UIAlertAction = UIAlertAction(title: "Go To Store", style: .Default, handler: { (action) -> Void in
            let storeVC = StoreViewController()
            self.shouldStartEditing = false
            let navVC = UINavigationController(rootViewController: storeVC)
            self.presentViewController(navVC, animated: true, completion: nil)
            
        })
        
        upgradeAlert.addAction(goToStore)
        self.presentViewController(upgradeAlert, animated: true, completion: nil)
    }
    
    
    
    func cancel(sender: UIButton!){
        
        //self.dismissViewControllerAnimated(true, completion: nil)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.endEditing(true)
            self.saveDraftContainer.frame = CGRectMake(0, self.view.frame.maxY - 140, self.view.frame.width, 140)
            self.view.bringSubviewToFront(self.saveDraftContainer)
        })
        
        invisibleView.frame = CGRectMake(0, UIApplication.sharedApplication().statusBarFrame.height, self.view.frame.width, saveDraftContainer.frame.minY - UIApplication.sharedApplication().statusBarFrame.height)
        invisibleView.backgroundColor = oneFiftyGrayColor
        invisibleView.alpha = 0.7
        self.view.addSubview(invisibleView)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
