//
//  TopicTodayTableViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/16/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class IdeaTodayTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var activityIndicator = UIActivityIndicatorView()
    var ideaObjects = [PFObject(className: "Idea")]
    let activityIndicatorContainer = UIView()
    let refreshTable = UIRefreshControl()
    var hasUpvoted = [Bool](count: 100, repeatedValue: false)
    var shouldReloadTable = false
    
    
    func queryForIdeaObjects(){
        var query = PFQuery(className: "Idea")
        query.orderByAscending("createdAt")
        //query.cachePolicy = .NetworkElseCache
        query.orderByDescending("numberOfUpvotes")
        query.limit = 100
        query.whereKey("isPublic", equalTo: true)
        query.includeKey("owner")
        query.includeKey("usersWhoUpvoted")
        query.includeKey("topicPointer")
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let timeZone = NSTimeZone(abbreviation: "GMT")
        calendar.timeZone = timeZone!
        let components = NSDateComponents()
        components.day = -1
        let oneDayAgo = calendar.dateByAddingComponents(components, toDate: now, options: nil)
        //query.whereKey("createdAt", greaterThanOrEqualTo: oneDayAgo!)
        query.findObjectsInBackgroundWithTarget(self, selector: "ideaSelector:error:")
    }
    
    func ideaSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            //topicObjects = []
            ideaObjects = objects as! [PFObject]
        }else{
            println("Error: \(error.userInfo)")
        }
        stopActivityIndicator()
        refreshTable.endRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
       self.tabBarController!.tabBar.hidden = false
        
        if shouldReloadTable == true{
            tableView.reloadData()
            shouldReloadTable == false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 150
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0)
        tableView.registerClass(IdeaTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        startActivityIndicator()
        queryForIdeaObjects()
        
        self.refreshTable.attributedTitle = NSAttributedString(string: "")
        self.refreshTable.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshTable)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideaObjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! IdeaTableViewCell
        
        cell.frame = CGRectMake(0, 0, self.view.frame.width, 150)
    
        //MARK: - Number Of Upvotes Button Config
        if ideaObjects[indexPath.row]["numberOfUpvotes"] != nil{
            let idea = ideaObjects[indexPath.row]
            hasUpvoted[indexPath.row] = getUpvotes(idea, cell.numberOfUpvotesButton, cell)
        }
        
        cell.numberOfUpvotesButton.addTarget(self, action: "upvote:", forControlEvents: .TouchUpInside)
        cell.numberOfUpvotesButton.tag = indexPath.row
        
        
        //MARK: - Topic Label Config
        var labelWidth = cell.frame.width - cell.numberOfUpvotesButton.frame.width - 25
        cell.topicLabel.frame = CGRectMake(10, 5, labelWidth, 20)
        cell.topicLabel.font = UIFont(name: "Avenir-Bold", size: 13)
        cell.topicLabel.numberOfLines = 1
        cell.topicLabel.textColor = oneFiftyGrayColor
        
        if let topic = ideaObjects[indexPath.row]["topicPointer"] as? PFObject{
            
            let topicText = topic["title"] as! String
            
            cell.topicLabel.text = topicText
            
        }
        cell.topicLabel.tag = indexPath.row + 200
        
        //MARK: - Idea Label Config
        cell.ideaLabel.numberOfLines = 0
        cell.ideaLabel.frame = CGRectMake(25, cell.topicLabel.frame.maxY + 2, labelWidth - 15, 70)
        
        cell.ideaLabel.font = UIFont(name: "Avenir-Light", size: 10)
        cell.ideaLabel.textColor = UIColor.blackColor()
        
        if ideaObjects[indexPath.row]["content"] != nil{
            
            cell.ideaLabel.text = (ideaObjects[indexPath.row]["content"] as! String)
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
        cell.profileButton.frame = CGRectMake(10, 105, 40, 40)
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
        cell.timeStamp.frame = CGRectMake(cell.frame.maxX - 30, cell.usernameLabel.frame.minY, 20, 20)
        cell.timeStamp.font = UIFont(name: "Avenir", size: 10)
        cell.timeStamp.textColor = oneFiftyGrayColor
        cell.timeStamp.textAlignment = NSTextAlignment.Right
        
        
        
        
//        //MARK: - Share Button Config
//        var shareImage = UIImage(named: "ideaShare.png") as UIImage!
//        let shareButtonX = cell.numberOfUpvotesButton.frame.minX - 90
//        cell.shareButton.frame = CGRectMake(shareButtonX, cell.usernameLabel.frame.minY - 7, 20, 25)
//        cell.shareButton.setImage(shareImage, forState: .Normal)
//        cell.shareButton.addTarget(self, action: "shareTopic:", forControlEvents: .TouchUpInside)
//        cell.shareButton.tag = indexPath.row + 500
//        
//        
//        
//        //MARK: - Compose Button Config
//        var composeImage = UIImage(named: "ideaCompose.png") as UIImage!
//        cell.composeButton.frame = CGRectMake(cell.shareButton.frame.maxX + 15, cell.usernameLabel.frame.minY - 7, 20, 25)
//        cell.composeButton.setImage(composeImage, forState: .Normal)
//        cell.composeButton.addTarget(self, action: "composeForTopic:", forControlEvents: .TouchUpInside)
//        cell.composeButton.tag = indexPath.row + 600
//        
        
        
       return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let ideaDetailVC = IdeaDetailViewController()
        let passingIdea = ideaObjects[indexPath.row]
        let passingTopic = ideaObjects[indexPath.row]["topicPointer"] as! PFObject
        ideaDetailVC.activeIdea = passingIdea
        ideaDetailVC.activeTopic =  passingTopic
        shouldReloadTable = true
        self.navigationController?.pushViewController(ideaDetailVC, animated: true)
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
        
        println("activity Indicator Started")
        
        activityIndicatorContainer.frame = CGRectMake(0, 0, self.view.frame.width, 50)
        
        activityIndicatorContainer.backgroundColor = UIColor.whiteColor()
        activityIndicatorContainer.hidden = false
        self.view.addSubview(activityIndicatorContainer)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRectMake(0, 0, self.view.frame.width, 1000)
        activityIndicator.center = activityIndicatorContainer.center
        activityIndicatorContainer.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //tableView.hidden = true
        
        
    }
    
    func stopActivityIndicator(){
        
        activityIndicator.stopAnimating()
        activityIndicatorContainer.removeFromSuperview()
        tableView.hidden = false
        tableView.reloadData()
    }
    
    func profileTapped(sender: AnyObject){
        let profileVC = ProfileViewController()
        if ideaObjects[sender.view!.tag]["owner"] != nil{
            profileVC.activeUser = ideaObjects[sender.view!.tag]["owner"] as! PFUser
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func refresh(sender:AnyObject)
    {
        queryForIdeaObjects()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
