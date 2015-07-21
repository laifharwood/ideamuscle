//
//  ProfileViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/25/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var activeUser = PFUser()
    var worldRank = Int()
    var worldRankLabel = UILabel()
    var isFollowing = Bool()
    var followButton = UIButton()
    var following = [PFObject(className: "following")]
    var activityIndicator = UIActivityIndicatorView()
    let worldRankTitleLabel = UILabel()
    var ideaTableView = UITableView()
    var ideaObjects = [PFObject(className: "Idea")]
    var hasUpvoted = [Bool](count: 100, repeatedValue: false)
    var totalUsersLabel = UILabel()
    var shouldReloadTable = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        //startActivityIndicator()
        //worldRankQuery()
        totalUsersQuery()
        queryForIdeaObjects()
        if activeUser != PFUser.currentUser(){
        followingQuery()
        }
        
        ideaTableView.delegate = self
        ideaTableView.dataSource = self
        ideaTableView.registerClass(ProfileIdeaCell.self, forCellReuseIdentifier: "Cell")
        ideaTableView.rowHeight = 100
        ideaTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        
        
        //MARK: - Avatar
        var imageView = UIImageView()
        imageView.frame = CGRectMake(self.view.frame.width/2 - 50, 80, 100, 100)
        getAvatar(activeUser, imageView, nil)
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        self.view.addSubview(imageView)
        
        //MARK: - Username
        var username = String()
        var usernameLabel = UILabel(frame: CGRectMake(5, imageView.frame.maxY + 2, self.view.frame.width - 10, 20))
        usernameLabel.textAlignment = NSTextAlignment.Center
        if activeUser["username"] != nil{
            
            usernameLabel.text = activeUser["username"] as? String
        }
        usernameLabel.font = UIFont(name: "Avenir-Light", size: 14)
        usernameLabel.textColor = fiftyGrayColor
        self.view.addSubview(usernameLabel)
        
        //MARK: - World Rank Label
        worldRankTitleLabel.frame = CGRectMake(self.view.frame.width/3 - 50 - 30, usernameLabel.frame.maxY + 2, 100, 20)
        worldRankTitleLabel.text = "World Ranking"
        worldRankTitleLabel.font = UIFont(name: "Helvetica", size: 14)
        worldRankTitleLabel.textColor = UIColor.blackColor()
        worldRankTitleLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(worldRankTitleLabel)
        
        
        worldRankLabel.frame = CGRectMake(self.view.frame.width/3 - 75 - 20, worldRankTitleLabel.frame.maxY + 3, 60, 20)
        //worldRankLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        //worldRankLabel.textColor = redColor
        //worldRankLabel.frame = CGRectMake(self.view.frame.width/3 - 75 - 30, worldRankTitleLabel.frame.maxY - 3, 150, 40)
        worldRankLabel.font = UIFont(name: "HelveticaNeue", size: 11)
        worldRankLabel.textAlignment = NSTextAlignment.Center
        let gestureRec = UITapGestureRecognizer(target: self, action: "viewRank:")
        worldRankLabel.addGestureRecognizer(gestureRec)
        worldRankLabel.userInteractionEnabled = true
        worldRankLabel.text = "View Rank"
        worldRankLabel.backgroundColor = oneFiftyGrayColor
        worldRankLabel.textColor = UIColor.whiteColor()
        worldRankLabel.layer.cornerRadius = 3
        self.view.addSubview(worldRankLabel)
        
        //MARK: - Total User Label
        totalUsersLabel.frame = CGRectMake(worldRankLabel.frame.maxX + 3, worldRankLabel.frame.minY, 150, 20)
        totalUsersLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        totalUsersLabel.textColor = oneFiftyGrayColor
        totalUsersLabel.textAlignment = NSTextAlignment.Left
        self.view.addSubview(totalUsersLabel)
        
        //MARK: - Follow Button
        followButton.frame = CGRectMake(self.view.frame.width/3 * 2 - 40 + 30, worldRankTitleLabel.frame.minY, 80, 40)
        let currentUser = PFUser.currentUser()
        followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        followButton.addTarget(self, action: "follow:", forControlEvents: .TouchUpInside)
        followButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        followButton.layer.cornerRadius = 3
        
        if activeUser != currentUser{
        self.view.addSubview(followButton)
        }
        
        //MARK: - Idea title label
        let ideaTitleLabel = UILabel(frame: CGRectMake(10, followButton.frame.maxY + 15, self.view.frame.width - 20, 20))
        if usernameLabel.text != nil{
        ideaTitleLabel.text = usernameLabel.text! + "'s Ideas:"
        }
        ideaTitleLabel.font = UIFont(name: "Helvetica-Light", size: 10)
        ideaTitleLabel.textColor = UIColor.blackColor()
        ideaTitleLabel.textAlignment = NSTextAlignment.Left
        self.view.addSubview(ideaTitleLabel)
        
        //Table View Config
        ideaTableView.frame = CGRectMake(0, ideaTitleLabel.frame.maxY, self.view.frame.width, self.view.frame.height - followButton.frame.maxY - 20)
        self.view.addSubview(ideaTableView)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = true
        if shouldReloadTable == true{
            ideaTableView.reloadData()
            shouldReloadTable == false
        }
    }
    
    func viewRank(sender: AnyObject){
        if let user = PFUser.currentUser(){
            if let isPro = user["isPro"] as? Bool{
                if isPro == true{
                    self.worldRankLabel.backgroundColor = UIColor.whiteColor()
                    worldRankLabel.text = ""
                    startActivityIndicator()
                    worldRankQuery()
                }else{
                    upgradeAlert()
                }
            }else{
                upgradeAlert()
            }
        }
        
        
    }
    
    func upgradeAlert(){
        let upgradeAlert: UIAlertController = UIAlertController(title: "Upgrade Required", message: "An upgrade to IdeaMuscle Pro is required to view World Rankings", preferredStyle: .Alert)
        upgradeAlert.view.tintColor = redColor
        upgradeAlert.view.backgroundColor = oneFiftyGrayColor
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        upgradeAlert.addAction(cancelAction)
        
        let goToStore: UIAlertAction = UIAlertAction(title: "Go To Store", style: .Default, handler: { (action) -> Void in
            let storeVC = StoreViewController()
            //let navVC = UINavigationController(rootViewController: storeVC)
            //self.presentViewController(navVC, animated: true, completion: nil)
            self.navigationController?.pushViewController(storeVC, animated: true)
            
        })
        
        upgradeAlert.addAction(goToStore)
        self.presentViewController(upgradeAlert, animated: true, completion: nil)
    }
    
    func follow(sender: UIButton!){
        if isFollowing == true{
            //Unfollow
                followGlobal(activeUser, false)
                self.followButton.setTitle("Follow", forState: .Normal)
                self.followButton.backgroundColor = redColor
                self.isFollowing = false
            
        }else{
            //Follow
                followGlobal(activeUser, true)
                self.followButton.setTitle("Following", forState: .Normal)
                self.followButton.backgroundColor = oneFiftyGrayColor
                isFollowing = true
        }
        
    }
    
    func worldRankQuery(){
        
        var leaderboardObjectQuery = PFQuery(className: "Leaderboard")
        var leaderboardOjbect = PFObject(className: "LeaderBoard")
        leaderboardObjectQuery.whereKey("userPointer", equalTo: activeUser)
        leaderboardObjectQuery.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if error == nil{
                var numberOfUpvotes = Int()
                leaderboardOjbect = object!
                if leaderboardOjbect["numberOfUpvotes"] != nil{
                numberOfUpvotes = leaderboardOjbect["numberOfUpvotes"] as! Int
                }else{
                    numberOfUpvotes = 0
                }
                var worldRankQuery = PFQuery(className: "Leaderboard")
                worldRankQuery.whereKey("numberOfUpvotes", greaterThan: numberOfUpvotes)
                worldRankQuery.countObjectsInBackgroundWithBlock({ (rank, error) -> Void in
                    if error == nil{
                        self.worldRank = Int(rank) + 1
                        self.worldRankLabel.font = UIFont(name: "HelveticaNeue", size: 20)
                        self.worldRankLabel.textColor = redColor
                        self.worldRankLabel.frame = CGRectMake(self.totalUsersLabel.frame.minX - 155, self.totalUsersLabel.frame.minY, 150, 20)
                        self.worldRankLabel.textAlignment = NSTextAlignment.Right
                        self.worldRankLabel.text = abbreviateNumber(self.worldRank) as String
                        self.worldRankLabel.userInteractionEnabled = false
                        
                        self.stopActivityIndicator()
                        
                    }
                })

            }
        }
        
    }
    
    func followingQuery(){
        if let currentUser = PFUser.currentUser(){
        var relation = PFRelation()
        var query = PFQuery()
        relation = currentUser.relationForKey("following")
        query = relation.query()!
        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error == nil{
                
                self.following = objects as! [PFObject]
                if contains(self.following, self.activeUser){
                    self.followButton.setTitle("Following", forState: .Normal)
                    self.followButton.backgroundColor = oneFiftyGrayColor
                    self.isFollowing = true
                }else{
                    self.followButton.setTitle("Follow", forState: .Normal)
                    self.followButton.backgroundColor = redColor
                    self.isFollowing = false
                }
            }
        })
        }
    }
    
    func totalUsersQuery(){
        
        let query = PFQuery(className: "TotalUsers")
        query.getObjectInBackgroundWithId("RjDIi23LNW", block: { (object, error) -> Void in
            if error == nil{
                let totalUsersObject = object!
                var totalUsersInt = Int()
                totalUsersInt = totalUsersObject["numberOfUsers"] as! Int
                self.totalUsersLabel.text = "out of " + (abbreviateNumber(totalUsersInt) as String) + " users"
            }
        })
    }
    
    func queryForIdeaObjects(){
        var query = PFQuery(className: "Idea")
        query.orderByDescending("numberOfUpvotes")
        query.limit = 100
        query.whereKey("isPublic", equalTo: true)
        query.whereKey("owner", equalTo: activeUser)
        query.includeKey("topicPointer")
        query.includeKey("usersWhoUpvoted")
        query.findObjectsInBackgroundWithTarget(self, selector: "ideaSelector:error:")
    }
    
    func ideaSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            ideaObjects = objects as! [PFObject]
        }else{
            println("Error: \(error.userInfo)")
            
        }
        //stopActivityIndicator()
        //refreshTable.endRefreshing()
        ideaTableView.reloadData()
    }

    func startActivityIndicator(){
        
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.frame = CGRectMake(worldRankLabel.frame.width/2 - 10, 0, 20, 20)
        activityIndicator.backgroundColor = UIColor.whiteColor()
        worldRankLabel.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        
    }
    
    func stopActivityIndicator(){
        self.activityIndicator.stopAnimating()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideaObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! ProfileIdeaCell
        cell.frame = CGRectMake(0, 0, self.view.frame.width, 100)
        
        //MARK: - Number Of Upvotes Button Config
        if ideaObjects[indexPath.row]["numberOfUpvotes"] != nil{
            let idea = ideaObjects[indexPath.row]
            hasUpvoted[indexPath.row] = getUpvotes(idea, cell.numberOfUpvotesButton, cell)
        }
        
        cell.numberOfUpvotesButton.addTarget(self, action: "upvote:", forControlEvents: .TouchUpInside)
        cell.numberOfUpvotesButton.tag = indexPath.row
        
        //MARK: - Topic Label
        var labelWidth = cell.frame.width - cell.numberOfUpvotesButton.frame.width - 25
        cell.topicLabel.frame = CGRectMake(10, 5, labelWidth, 20)
        cell.topicLabel.font = UIFont(name: "Avenir-Heavy", size: 12)
        cell.topicLabel.numberOfLines = 1
        cell.topicLabel.textColor = UIColor.blackColor()
        
        if let topic = ideaObjects[indexPath.row]["topicPointer"] as? PFObject{
            let topicText = topic["title"] as! String
            cell.topicLabel.text = topicText
        }
        cell.topicLabel.tag = indexPath.row
        
        //MARK: - Idea Label
        cell.ideaLabel.numberOfLines = 0
        cell.ideaLabel.frame = CGRectMake(25, cell.topicLabel.frame.maxY + 2, labelWidth - 15, 70)
        cell.ideaLabel.font = UIFont(name: "Avenir-Light", size: 10)
        cell.ideaLabel.textColor = fiftyGrayColor
        if ideaObjects[indexPath.row]["content"] != nil{
            cell.ideaLabel.text = (ideaObjects[indexPath.row]["content"] as! String)
        }
       
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    

}
