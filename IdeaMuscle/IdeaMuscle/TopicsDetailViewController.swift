//
//  TopicsDetailViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/5/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse


class TopicsDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView = UITableView()
    var activeTopic = PFObject(className: "Topic")
    var ideaObjects = [PFObject(className: "Idea")]
    var hasUpvoted = [Bool](count: 100, repeatedValue: false)
    var shouldReloadTable = false
    var activityIndicator = UIActivityIndicatorView()
    let activityIndicatorContainer = UIView()
    var shareContainer = UIView()
    let reportViewContainer = UIView()
    let invisibleView = UIView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        startActivityIndicator()
        ideaQuery()
        
        self.view.backgroundColor = oneFiftyGrayColor
        
        //MARK: - Topic Label
        var topicLabel = UILabel()
        var topicLabelView = UIView()
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
        }

        topicLabelView.addSubview(topicLabel)
        
        // MARK: - Table View Configuration
        tableView.registerClass(TopicTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRectMake(0, topicLabelView.frame.maxY + 5, self.view.frame.width, self.view.frame.height - navigationController!.navigationBar.frame.height - 30 - 60)
        tableView.rowHeight = 120
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        self.view.addSubview(tableView)
        
        //MARK: - Share Button
        var shareButton = UIButton()
        shareButton.frame = CGRectMake(0, self.view.frame.maxY - 30, self.view.frame.width/2 - 0.5, 30)
        if let user = PFUser.currentUser(){
            if let isPublic =  activeTopic["isPublic"] as? Bool{
                if isPublic{
                    shareButton.setTitle("Share", forState: .Normal)
                    shareButton.backgroundColor = sixtyThreeGrayColor
                    shareButton.addTarget(self, action: "share:", forControlEvents: .TouchUpInside)
                    shareButton.titleLabel?.font = UIFont(name: "Helvetica-Light", size: 14)
                    self.view.addSubview(shareButton)
                }
            }
        }
        
        //MARK: - Compose Button
        var composeButton = UIButton()
        composeButton.frame = CGRectMake(shareButton.frame.maxX + 1, self.view.frame.maxY - 30, self.view.frame.width/2 - 0.5, 30)
        composeButton.setTitle("Compose", forState: .Normal)
        composeButton.backgroundColor = sixtyThreeGrayColor
        composeButton.addTarget(self, action: "compose:", forControlEvents: .TouchUpInside)
        composeButton.titleLabel?.font = UIFont(name: "Helvetica-Light", size: 14)
        self.view.addSubview(composeButton)
        

        
        longPressToTableViewGlobal(self, tableView, reportViewContainer)
    }
    

    

    

    


    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = true
        
        if shouldReloadTable == true{
            tableView.reloadData()
            shouldReloadTable == false
        }
    }
    
    func compose(sender: UIButton!){
        composeFromDetail(self, activeTopic, false)
    }
    
    func ideaQuery(){
        
        let query = PFQuery(className: "Idea")
        query.whereKey("topicPointer", equalTo: activeTopic)
        query.whereKey("isPublic", equalTo: true)
        query.includeKey("owner")
        //query.includeKey("usersWhoUpvoted")
        query.orderByAscending("createdAt")
        query.cachePolicy = PFCachePolicy.NetworkElseCache
        query.orderByDescending("numberOfUpvotes")
        query.limit = 500
        getIdeasToHideGlobal(query)
        query.findObjectsInBackgroundWithTarget(self, selector: "ideaSelector:error:")
        
    }
    
    func ideaSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            ideaObjects = objects as! [PFObject]
        }else{
            println("Error: \(error.userInfo)")
        }
        stopActivityIndicator()
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
            hasUpvoted[indexPath.row] = getUpvotes(idea, cell.numberOfUpvotesButton, cell)
        }
        cell.numberOfUpvotesButton.addTarget(self, action: "upvote:", forControlEvents: .TouchUpInside)
        cell.numberOfUpvotesButton.tag = indexPath.row
        
        //MARK: - Idea Label Config
        cell.ideaTitleLabel.numberOfLines = 0
        cell.ideaTitleLabel.frame = CGRectMake(25, 5, cell.frame.width - cell.numberOfUpvotesButton.frame.width - 40, 70)
        cell.ideaTitleLabel.font = UIFont(name: "Avenir-Light", size: 12)
        cell.ideaTitleLabel.textColor = oneFiftyGrayColor
        if ideaObjects[indexPath.row]["content"] != nil{
            cell.ideaTitleLabel.text = (ideaObjects[indexPath.row]["content"] as! String)
        }
        
        //MARK: - Profile Button
        var pfUser = PFUser()
        if ideaObjects[indexPath.row]["owner"] != nil{
            pfUser = ideaObjects[indexPath.row]["owner"] as! PFUser
            if PFUser.currentUser() == pfUser{
                cell.profileButton.layer.borderColor = redColor.CGColor
                cell.profileButton.layer.borderWidth = 2
            }else{
                cell.profileButton.layer.borderColor = UIColor.whiteColor().CGColor
                cell.profileButton.layer.borderWidth = 0
            }
            
            getAvatar(pfUser, nil, cell.profileButton)
            
        }
        
        cell.profileButton.tag = indexPath.row
        let gestureRec = UITapGestureRecognizer(target: self, action: "profileTapped:")
        cell.profileButton.addGestureRecognizer(gestureRec)
        cell.profileButton.userInteractionEnabled = true
        cell.profileButton.frame = CGRectMake(10, 75, 40, 40)
        cell.profileButton.layer.cornerRadius = 20
        cell.profileButton.layer.masksToBounds = true
        
        //MARK: - Username Label Config
        var usernameLabelWidth = CGFloat()
        usernameLabelWidth = 190
        cell.usernameLabel.frame = CGRectMake(cell.profileButton.frame.maxX + 2, cell.profileButton.frame.maxY - cell.profileButton.frame.height/2, usernameLabelWidth, 20)
        cell.usernameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        cell.usernameLabel.textColor = twoHundredGrayColor
        if ideaObjects[indexPath.row]["owner"] != nil{
            let username = pfUser["username"] as! String
            cell.usernameLabel.text = username
        }
        
        cell.usernameLabel.tag = indexPath.row + 400
        
        //MARK: - TimeStamp
        var createdAt = NSDate()
        
        if ideaObjects[indexPath.row].createdAt != nil{
            createdAt = ideaObjects[indexPath.row].createdAt!
            cell.timeStamp.text = createdAt.timeAgoSimple
        }
        cell.timeStamp.frame = CGRectMake(cell.frame.maxX - 40, cell.usernameLabel.frame.minY, 30, 20)
        cell.timeStamp.font = UIFont(name: "Avenir", size: 10)
        cell.timeStamp.textColor = oneFiftyGrayColor
        cell.timeStamp.textAlignment = NSTextAlignment.Right
        

        return cell
    }
    
    func cellLongPress(sender: UILongPressGestureRecognizer){
        cellLongPressGlobal(sender, tableView, self, self.reportViewContainer, self.invisibleView)
    }
    
    func hideIdea(sender: UIButton){
        
        let row = sender.tag
        if let currentUser = PFUser.currentUser(){
            let idea = ideaObjects[row]
            currentUser.addObject(idea.objectId!, forKey: "ideasToHideId")
            currentUser.saveEventually()
        }
        
        hideInvisibleAndReportViewLocal()
        ideaObjects.removeAtIndex(row)
        let indexPath = NSIndexPath(forRow: row, inSection: 0)
        let pathArray = [indexPath]
        tableView.deleteRowsAtIndexPaths(pathArray, withRowAnimation: UITableViewRowAnimation.Bottom)
    }
    
    func hideAndReport(sender: UIButton){
        hideAndReportGlobal(ideaObjects, sender, self, self.hideIdea)
    }
    
    func cancelHide(sender: UIButton){
        
        hideInvisibleAndReportViewLocal()
    }
    
    func hideInvisibleAndReportViewLocal(){
        
        invisibleView.removeFromSuperview()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.reportViewContainer.frame = CGRectMake(0, self.tabBarController!.tabBar.frame.maxY, self.view.frame.width, 100)
        })
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let ideaDetailVC = IdeaDetailViewController()
        shouldReloadTable = true
        let passingIdea = ideaObjects[indexPath.row]
        let passingTopic = ideaObjects[indexPath.row]["topicPointer"] as! PFObject
        passingTopic.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
            if error == nil{
                ideaDetailVC.activeIdea = passingIdea
                ideaDetailVC.activeTopic =  passingTopic
                self.navigationController?.pushViewController(ideaDetailVC, animated: true)
            }
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
        
        if hasUpvoted[sender.tag] == true{
            //Remove Upvote
            upvoteGlobal(ideaObject, false, sender)
            hasUpvoted[sender.tag] = false
        }else{
            //Add Upvote
            upvoteGlobal(ideaObject, true, sender)
            hasUpvoted[sender.tag] = true
        }
    }
    
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
    
    func share(sender: UIButton!){
        let topicString = activeTopic["title"] as! String
        let stringCount = count(topicString)
        let characterAllowance = 117
        var stringToShare = String()
        
        if stringCount > characterAllowance{
            let twitterString = topicString.substringWithRange(Range<String.Index>(start: topicString.startIndex, end: advance(topicString.startIndex, characterAllowance)))
            stringToShare = twitterString
        }else{
            stringToShare = topicString
        }
        
        let deeplink = HOKDeeplink(route: "topics/:topicId", routeParameters: ["topicId": activeTopic.objectId!])
        Hoko.deeplinking().generateSmartlinkForDeeplink(deeplink, success: { (smartlink) -> Void in
            
            if let url = NSURL(string: smartlink){
                let objectsToShare = [stringToShare, url]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
            }) { (error) -> Void in
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
