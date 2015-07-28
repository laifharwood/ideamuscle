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
    var following = [PFUser()]
    var activityIndicator = UIActivityIndicatorView()
    let worldRankTitleLabel = UILabel()
    var ideaTableView = UITableView()
    var ideaObjects = [PFObject(className: "Idea")]
    var hasUpvoted = [Bool](count: 100, repeatedValue: false)
    var totalUsersLabel = UILabel()
    var shouldReloadTable = false
    var numberOfUpvotes = UILabel()
    var numberFollowing = UILabel()
    var numberOfFollowers = UILabel()

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
        queryNumberFollowing()
        queryNumberOfFollowers()
        queryNumberOfUpvotes()
        
        ideaTableView.delegate = self
        ideaTableView.dataSource = self
        ideaTableView.registerClass(ProfileIdeaCell.self, forCellReuseIdentifier: "Cell")
        ideaTableView.rowHeight = 100
        ideaTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        
        //MARK: - Top Background Container
        var topBackgroundContainer = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 250))
        topBackgroundContainer.backgroundColor = twoHundredGrayColor
        self.view.addSubview(topBackgroundContainer)
        
        
        
        
        //MARK: - Avatar
        var imageView = UIImageView()
        imageView.frame = CGRectMake(self.view.frame.width/2 - 50, 80, 100, 100)
        getAvatar(activeUser, imageView, nil)
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        topBackgroundContainer.addSubview(imageView)
        
    
        //MARK: - Number Of Section
        var width = CGFloat()
        var height = CGFloat()
        width = 60.0
        height = 30.0
        let upvotes = UILabel(frame: CGRectMake(20, imageView.frame.maxY + 3, width, height))
        let following = UILabel(frame: CGRectMake(self.view.frame.width/2 - width/2, imageView.frame.maxY + 3, width, height))
        let followers = UILabel(frame: CGRectMake(self.view.frame.maxX - width - 20, imageView.frame.maxY + 3, width, height))
        
        upvotes.font = UIFont(name: "HelveticaNeue", size: 12)
        following.font = UIFont(name: "HelveticaNeue", size: 12)
        followers.font = UIFont(name: "HelveticaNeue", size: 12)
        
        upvotes.text = "Upvotes"
        following.text = "Following"
        followers.text = "Followers"
        
        upvotes.textAlignment = NSTextAlignment.Center
        following.textAlignment = NSTextAlignment.Center
        followers.textAlignment = NSTextAlignment.Center
        
        upvotes.textColor = oneFiftyGrayColor
        following.textColor = oneFiftyGrayColor
        followers.textColor = oneFiftyGrayColor
    
        
        numberOfUpvotes.frame = CGRectMake(20, upvotes.frame.maxY - 8, width, height)
        numberFollowing.frame = CGRectMake(self.view.frame.width/2 - width/2, following.frame.maxY - 8, width, height)
        numberOfFollowers.frame = CGRectMake(self.view.frame.maxX - width - 20, followers.frame.maxY - 8, width, height)
        
        numberOfUpvotes.textAlignment = NSTextAlignment.Center
        numberFollowing.textAlignment = NSTextAlignment.Center
        numberOfFollowers.textAlignment = NSTextAlignment.Center
        
        numberOfUpvotes.textColor = fiftyGrayColor
        numberFollowing.textColor = fiftyGrayColor
        numberOfFollowers.textColor = fiftyGrayColor
        
        numberOfUpvotes.font = UIFont(name: "HelveticaNeue", size: 15)
        numberFollowing.font = UIFont(name: "HelveticaNeue", size: 15)
        numberOfFollowers.font = UIFont(name: "HelveticaNeue", size: 15)
        
        let followingGestureRec = UITapGestureRecognizer(target: self, action: "goToFollowing:")
        let followersGestureRec = UITapGestureRecognizer(target: self, action: "goToFollowers:")
        numberFollowing.addGestureRecognizer(followingGestureRec)
        following.addGestureRecognizer(followingGestureRec)
        numberOfFollowers.addGestureRecognizer(followersGestureRec)
        followers.addGestureRecognizer(followersGestureRec)
        following.userInteractionEnabled = true
        followers.userInteractionEnabled = true
        numberOfFollowers.userInteractionEnabled = true
        numberFollowing.userInteractionEnabled = true
        
        topBackgroundContainer.addSubview(upvotes)
        topBackgroundContainer.addSubview(numberOfUpvotes)
        topBackgroundContainer.addSubview(numberFollowing)
        topBackgroundContainer.addSubview(following)
        topBackgroundContainer.addSubview(numberOfFollowers)
        topBackgroundContainer.addSubview(followers)
        

        
        
        //MARK: - World Rank Label
        let worldRankContainer = UIView(frame: CGRectMake(0, topBackgroundContainer.frame.maxY + 2, self.view.frame.width/2 - 1, 80))
        worldRankContainer.backgroundColor = twoHundredGrayColor
        self.view.addSubview(worldRankContainer)
        
        worldRankLabel.frame = CGRectMake(worldRankContainer.frame.width/2 - 35, worldRankContainer.frame.height/2 - 10, 70, 20)
        worldRankLabel.font = UIFont(name: "HelveticaNeue", size: 11)
        worldRankLabel.textAlignment = NSTextAlignment.Center
        let gestureRec = UITapGestureRecognizer(target: self, action: "viewRank:")
        worldRankLabel.addGestureRecognizer(gestureRec)
        worldRankLabel.userInteractionEnabled = true
        worldRankLabel.text = "View Rank"
        worldRankLabel.backgroundColor = oneFiftyGrayColor
        worldRankLabel.textColor = UIColor.whiteColor()
        worldRankLabel.layer.cornerRadius = 3
        worldRankLabel.layer.masksToBounds = true
        worldRankContainer.addSubview(worldRankLabel)
        
        worldRankTitleLabel.frame = CGRectMake(5, worldRankLabel.frame.minY - 25, worldRankContainer.frame.width - 10, 20)
        worldRankTitleLabel.text = "World Ranking"
        worldRankTitleLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        worldRankTitleLabel.textColor = oneFiftyGrayColor
        worldRankTitleLabel.textAlignment = NSTextAlignment.Center
        worldRankContainer.addSubview(worldRankTitleLabel)
        
        //MARK: - Total User Label
        totalUsersLabel.frame = CGRectMake(5, worldRankLabel.frame.maxY + 5, worldRankContainer.frame.width - 10, 20)
        totalUsersLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        totalUsersLabel.textColor = oneFiftyGrayColor
        totalUsersLabel.textAlignment = NSTextAlignment.Center
        worldRankContainer.addSubview(totalUsersLabel)

        
        //MARK: - Idea title label
        let ideaTitleLabelContainter = UIView(frame: CGRectMake(0, worldRankContainer.frame.maxY + 2, self.view.frame.width, 30))
        ideaTitleLabelContainter.backgroundColor = fiftyGrayColor
        self.view.addSubview(ideaTitleLabelContainter)
        
        let ideaTitleLabel = UILabel(frame: CGRectMake(10, 0, self.view.frame.width - 20, 30))
        
        if let username = activeUser.username{
            self.title = username
            ideaTitleLabel.text = username + "'s Ideas:"
        }
        
        ideaTitleLabel.font = UIFont(name: "Helvetica-Light", size: 12)
        ideaTitleLabel.textColor = UIColor.whiteColor()
        ideaTitleLabel.textAlignment = NSTextAlignment.Left
        ideaTitleLabelContainter.addSubview(ideaTitleLabel)
        
        //MARK: - Follow Button
        let followButtonContainter = UIView(frame: CGRectMake(worldRankContainer.frame.maxX + 2, topBackgroundContainer.frame.maxY + 2, self.view.frame.width/2 - 1, 80))
        followButtonContainter.backgroundColor = twoHundredGrayColor
        self.view.addSubview(followButtonContainter)
        
        followButton.frame = CGRectMake(followButtonContainter.frame.width/2 - 40, worldRankContainer.frame.height/2 - 20, 80, 40)
        followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        followButton.addTarget(self, action: "follow:", forControlEvents: .TouchUpInside)
        followButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        followButton.layer.cornerRadius = 3
        
        if let currentUser = PFUser.currentUser(){
            if activeUser != currentUser{
            followButtonContainter.addSubview(followButton)
            }
        }
        
        
        
        
        
        //MARK: - Table View Config
        ideaTableView.frame = CGRectMake(0, ideaTitleLabelContainter.frame.maxY, self.view.frame.width, self.view.frame.height - ideaTitleLabelContainter.frame.maxY)
        self.view.addSubview(ideaTableView)
        
    }
    
    func queryNumberOfUpvotes(){
        let query = PFQuery(className: "Leaderboard")
        query.whereKey("userPointer", equalTo: activeUser)
        query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if error == nil{
                var leaderboardObject = PFObject(className: "Leaderboard")
                leaderboardObject = object!
                if let numberOfUpvotes = leaderboardObject["numberOfUpvotes"] as? Int{
                    let string = abbreviateNumber(numberOfUpvotes) as! String
                    self.numberOfUpvotes.text = string
                }else{
                    self.numberOfUpvotes.text = "0"
                }
            }
        }
    }
    
    func queryNumberFollowing(){
        if let numberFollowingNumber = activeUser["numberFollowing"] as? Int{
            let string = abbreviateNumber(numberFollowingNumber) as! String
            numberFollowing.text = string
        }else{
            numberFollowing.text = "0"
        }
    }
    
    func queryNumberOfFollowers(){
        let query = PFQuery(className: "NumberOfFollowers")
        query.whereKey("userPointer", equalTo: activeUser)
        query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if error == nil{
                var numberOfFollowersObject = PFObject(className: "NumberOfFollowers")
                numberOfFollowersObject = object!
                if let numberOfFollowers = numberOfFollowersObject["numberOfFollowers"] as? Int{
                    let string = abbreviateNumber(numberOfFollowers) as! String
                    self.numberOfFollowers.text = string
                }else{
                    self.numberOfFollowers.text = "0"
                }
            }
        }
    }
    
    
    
    func goToFollowing(sender: UITapGestureRecognizer){
        let followingVC = FollowingTableViewController()
        followingVC.activeUser = activeUser
        navigationController?.pushViewController(followingVC, animated: true)
    }
    
    func goToFollowers(sender: UITapGestureRecognizer){
       let followersVC = FollowersTableViewController()
        followersVC.activeUser = activeUser
        navigationController?.pushViewController(followersVC, animated: true)
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
                    self.worldRankLabel.backgroundColor = twoHundredGrayColor
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
            if let user = PFUser.currentUser(){
                followGlobal(activeUser, false, self)
                self.followButton.setTitle("Follow", forState: .Normal)
                self.followButton.backgroundColor = redColor
                self.isFollowing = false
            }
            
        }else{
            //Follow
            if let user = PFUser.currentUser(){
                followGlobal(activeUser, true, self)
                if let numberFollowing = user["numberFollowing"] as? Int{
                    if numberFollowing < 1000{
                        self.followButton.setTitle("Following", forState: .Normal)
                        self.followButton.backgroundColor = oneFiftyGrayColor
                        isFollowing = true
                    }
                }
            }
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
                
                self.following = objects as! [PFUser]
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
                self.totalUsersLabel.text = "out of " + (abbreviateNumber(totalUsersInt) as! String) + " users"
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
        
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        activityIndicator.frame = CGRectMake(worldRankLabel.frame.width/2 - 10, 0, 20, 20)
        activityIndicator.backgroundColor = twoHundredGrayColor
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
