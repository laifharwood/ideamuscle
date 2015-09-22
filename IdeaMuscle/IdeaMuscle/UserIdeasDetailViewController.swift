//
//  UserIdeasDetailViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/20/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class UserIdeasDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var tableView: UITableView = UITableView()
    var activeTopic = PFObject(className: "Topic")
    var ideaObjects = [PFObject(className: "Idea")]
    var hasUpvoted = [Bool](count: 100, repeatedValue: false)
    var shouldReloadTable = false
    var activityIndicator = UIActivityIndicatorView()
    var topicLabelView = UIView()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        startActivityIndicator()
        ideaQuery()
        
        self.view.backgroundColor = oneFiftyGrayColor
        
        //MARK: - Topic Label
        let topicLabel = UILabel()
        topicLabelView.frame = CGRectMake(0, 69, self.view.frame.width, 70)
        topicLabelView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(topicLabelView)
        topicLabel.font = UIFont(name: "Avenir-Heavy", size: 12)
        topicLabel.textColor = UIColor.blackColor()
        topicLabel.numberOfLines = 0
        topicLabel.textAlignment = NSTextAlignment.Center
        topicLabel.frame = CGRectMake(5, 0, self.view.frame.width - 10, 70)
        if activeTopic["title"] != nil{
            topicLabel.text = activeTopic["title"] as? String
            //topicLabel.sizeToFit()
            print(topicLabel.frame.height)
            //let height = topicLabel.frame.height
            //topicLabel.frame = CGRectMake(0, 69, self.view.frame.width, height + 5)
        }
        
        topicLabelView.addSubview(topicLabel)
        
        // MARK: - Table View Configuration
        tableView.registerClass(TopicTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRectMake(0, topicLabelView.frame.maxY + 5, self.view.frame.width, self.view.frame.height - navigationController!.navigationBar.frame.height - 30 - 60)
        tableView.rowHeight = 120
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0)
        self.view.addSubview(tableView)
        
//        //MARK: - Share Button
//        var shareButton = UIButton()
//        shareButton.frame = CGRectMake(0, self.view.frame.maxY - 30, self.view.frame.width/2 - 0.5, 30)
//        var topicIsPublic = Bool()
//        if let isPublic = activeTopic["isPublic"] as? Bool{
//            if isPublic{
//                topicIsPublic = true
//            }else{
//                topicIsPublic = false
//            }
//        }else{
//            topicIsPublic = false
//        }
//        if topicIsPublic{
//            shareButton.setTitle("Share", forState: .Normal)
//            shareButton.backgroundColor = sixtyThreeGrayColor
//            shareButton.addTarget(self, action: "share:", forControlEvents: .TouchUpInside)
//            shareButton.titleLabel?.font = UIFont(name: "Helvetica-Light", size: 14)
//            self.view.addSubview(shareButton)
//        }
//        
//        //MARK: - Compose Button
//        var composeButton = UIButton()
//        composeButton.frame = CGRectMake(shareButton.frame.maxX + 1, self.view.frame.maxY - 30, self.view.frame.width/2 - 0.5, 30)
//        composeButton.setTitle("Compose", forState: .Normal)
//        composeButton.backgroundColor = sixtyThreeGrayColor
//        composeButton.addTarget(self, action: "compose:", forControlEvents: .TouchUpInside)
//        composeButton.titleLabel?.font = UIFont(name: "Helvetica-Light", size: 14)
//        self.view.addSubview(composeButton)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = true
        
        if shouldReloadTable == true{
            tableView.reloadData()
            shouldReloadTable == false
        }
    }
    
    func compose(sender: UIButton!){
        composeFromDetail(self, activeTopic: activeTopic, isNewTopic: false)
    }
    
    func ideaQuery(){
        if let user = PFUser.currentUser(){
            let query = PFQuery(className: "Idea")
            query.whereKey("topicPointer", equalTo: activeTopic)
            query.whereKey("owner", equalTo: user)
            query.includeKey("owner")
            query.cachePolicy = PFCachePolicy.NetworkElseCache
            //query.includeKey("usersWhoUpvoted")
            query.orderByAscending("createdAt")
            query.orderByDescending("numberOfUpvotes")
            query.limit = 1000
            query.findObjectsInBackgroundWithTarget(self, selector: "ideaSelector:error:")
        }
    }
    
    func ideaSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            ideaObjects = objects as! [PFObject]
            stopActivityIndicator()
        }else{
            print("Error: \(error.userInfo)")
        }
        
        
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return ideaObjects.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TopicTableViewCell
        
        cell.frame = CGRectMake(0, 0, self.view.frame.width, 120)
        
        //MARK: - Number Of Upvotes Button Config
        if ideaObjects[indexPath.row]["numberOfUpvotes"] != nil{
            let idea = ideaObjects[indexPath.row]
            if let isPublic = idea["isPublic"] as? Bool{
                if isPublic == true{
                    hasUpvoted[indexPath.row] = getUpvotes(idea, button: cell.numberOfUpvotesButton, cell: cell)
                }else if isPublic == false{
                    ideaIsNotPublic(cell)
                }
            }else{
                ideaIsNotPublic(cell)
            }
            cell.numberOfUpvotesButton.addTarget(self, action: "upvote:", forControlEvents: .TouchUpInside)
        }
        
        cell.numberOfUpvotesButton.tag = indexPath.row
        
        //MARK: - Idea Label Config
        cell.ideaTitleLabel.numberOfLines = 0
        cell.ideaTitleLabel.frame = CGRectMake(25, 5, cell.frame.width - cell.numberOfUpvotesButton.frame.width - 40, cell.frame.height - 10)
        cell.ideaTitleLabel.font = UIFont(name: "Avenir-Light", size: 14)
        cell.ideaTitleLabel.textColor = oneFiftyGrayColor
        if ideaObjects[indexPath.row]["content"] != nil{
            cell.ideaTitleLabel.text = (ideaObjects[indexPath.row]["content"] as! String)
        }
        

    
        
        //MARK: - TimeStamp
        var createdAt = NSDate()
        
        if ideaObjects[indexPath.row].createdAt != nil{
            createdAt = ideaObjects[indexPath.row].createdAt!
            cell.timeStamp.text = createdAt.timeAgoSimple
        }
        cell.timeStamp.frame = CGRectMake(cell.frame.maxX - 30, cell.numberOfUpvotesButton.frame.maxY + 3, 20, 20)
        cell.timeStamp.font = UIFont(name: "Avenir", size: 10)
        cell.timeStamp.textColor = oneFiftyGrayColor
        cell.timeStamp.textAlignment = NSTextAlignment.Right
        
        
        return cell
    }
    
    func ideaIsNotPublic(cell: TopicTableViewCell){
        cell.numberOfUpvotesButton.frame =  CGRectMake(cell.frame.maxX - (40) - 10, cell.frame.height/2 - 30, 40, 60)
        cell.numberOfUpvotesButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 10)
        cell.numberOfUpvotesButton.layer.cornerRadius = 3
        cell.numberOfUpvotesButton.backgroundColor = oneFiftyGrayColor
        cell.numberOfUpvotesButton.setTitle("Make Public", forState: .Normal)
        cell.numberOfUpvotesButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cell.numberOfUpvotesButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.numberOfUpvotesButton.titleLabel?.textAlignment = NSTextAlignment.Center
    }
    
    func makePublic(sender: UIButton){
        let idea = ideaObjects[sender.tag]
        idea.ACL?.setPublicReadAccess(true)
        idea.ACL?.setPublicWriteAccess(true)
        idea["isPublic"] = true
        idea.saveEventually()
        hasUpvoted[sender.tag] = getUpvotes(idea, button: sender, cell: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let ideaDetailVC = IdeaDetailViewController()
        shouldReloadTable = true
        let passingIdea = ideaObjects[indexPath.row]
        let passingTopic = ideaObjects[indexPath.row]["topicPointer"] as! PFObject
        passingTopic.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
            ideaDetailVC.activeIdea = passingIdea
            ideaDetailVC.activeTopic =  passingTopic
            self.navigationController?.pushViewController(ideaDetailVC, animated: true)
        }
    }
    
    func profileTapped(sender: AnyObject){
        let profileVC = ProfileViewController()
        if ideaObjects[sender.view!.tag]["owner"] != nil{
            profileVC.activeUser = ideaObjects[sender.view!.tag]["owner"] as! PFUser
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func upvote(sender: UIButton!){
        
        let ideaObject = ideaObjects[sender.tag]
        
        if let isPublic = ideaObject["isPublic"] as? Bool{
            if isPublic{
                if hasUpvoted[sender.tag] == true{
                    //Remove Upvote
                    upvoteGlobal(ideaObject, shouldUpvote: false, button: sender)
                    hasUpvoted[sender.tag] = false
                }else{
                    //Add Upvote
                    upvoteGlobal(ideaObject, shouldUpvote: true, button: sender)
                    hasUpvoted[sender.tag] = true
                }
            }else{
               makePublic(sender)
            }
        }else{
            makePublic(sender)
        }
        
    }
    
//    func upgradeAlert(){
//        let upgradeAlert: UIAlertController = UIAlertController(title: "Upgrade Required", message: "You must upgrade to Pro to make ideas public after posting.", preferredStyle: .Alert)
//        upgradeAlert.view.tintColor = redColor
//        upgradeAlert.view.backgroundColor = oneFiftyGrayColor
//        //Create and add the Cancel action
//        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
//        }
//        upgradeAlert.addAction(cancelAction)
//        
//        let goToStore: UIAlertAction = UIAlertAction(title: "Go To Store", style: .Default, handler: { (action) -> Void in
//            let storeVC = StoreViewController()
//            let navVC = UINavigationController(rootViewController: storeVC)
//            self.presentViewController(navVC, animated: true, completion: nil)
//            
//        })
//        
//        upgradeAlert.addAction(goToStore)
//        self.presentViewController(upgradeAlert, animated: true, completion: nil)
//    }
    
    func startActivityIndicator(){
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRectMake(self.view.frame.width/2 - 25, tableView.frame.minY + 5, 50, 50)
        //activityIndicator.center = self.view.center
        tableView.addSubview(activityIndicator)
        //self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator(){
        
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    

    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            
            let ideaObject = ideaObjects[indexPath.row] as PFObject
            ideaObjects.removeAtIndex(indexPath.row)
            ideaObject.deleteEventually()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

