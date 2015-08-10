//
//  FriendsLeaderboardTableViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/30/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class WorldLeaderboardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var activityIndicator = UIActivityIndicatorView()
    var rankIndicator = UIActivityIndicatorView()
    let activityIndicatorContainer = UIView()
    var tableView = UITableView()
    var leaderboardObjects = [PFObject(className: "Leaderboard")]
    var followingObjects = [PFObject(className: "following")]
    var currenUserLeaderBoard = PFObject(className: "Leaderboard")
    var currentUserNumberOfUpvotesButton = UIButton()
    let bottomContainer = UIView()
    var worldRankLabel = UILabel()
    var worldRankTitleLabel = UILabel()
    var totalUsersLabel = UILabel()
    let refreshTable = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        //MARK: - Bottom container
        bottomContainer.backgroundColor = twoHundredGrayColor
        let y = self.view.frame.height - 213
        bottomContainer.frame = CGRectMake(0, y, self.view.frame.width, 70)
        self.view.addSubview(bottomContainer)
        
        //MARK: - User Avatar
        let imageView = UIImageView()
        imageView.frame = CGRectMake(5, 15, 40, 40)
        if PFUser.currentUser() != nil{
            getAvatar(PFUser.currentUser()!, imageView, nil)
        }
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        bottomContainer.addSubview(imageView)
        

        
        //MARK: - TableView Did Load
        tableView.rowHeight = 70
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0)
        tableView.registerClass(LeaderboardTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 213)
        self.view.addSubview(tableView)
        
        refreshTable.attributedTitle = NSAttributedString(string: "")
        refreshTable.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshTable)
        
        startActivityIndicator()
        queryForLeaderboardObjects()

        
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return leaderboardObjects.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! LeaderboardTableViewCell
        cell.frame = CGRectMake(0, 0, view.frame.width, 70)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        //MARK: - Profile Buttons
        var pfUser = PFUser()
        if leaderboardObjects[indexPath.row]["userPointer"] != nil{
            pfUser = leaderboardObjects[indexPath.row]["userPointer"] as! PFUser
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
        cell.profileButton.userInteractionEnabled = true
        cell.profileButton.frame = CGRectMake(10, 15, 40, 40)
        cell.profileButton.layer.cornerRadius = 20
        cell.profileButton.layer.masksToBounds = true
        let gestureRec = UITapGestureRecognizer(target: self, action: "profileTapped:")
        cell.profileButton.addGestureRecognizer(gestureRec)
        
        //MARK: - Username Label
        var usernameLabelWidth = CGFloat()
        usernameLabelWidth = 190
        cell.usernameLabel.frame = CGRectMake(cell.profileButton.frame.maxX + 2, cell.profileButton.frame.maxY - cell.profileButton.frame.height/2, usernameLabelWidth, 20)
        cell.usernameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        cell.usernameLabel.textColor = twoHundredGrayColor
        if leaderboardObjects[indexPath.row]["userPointer"] != nil{
            let user = leaderboardObjects[indexPath.row]["userPointer"] as! PFUser
            if user["username"] != nil{
                let username = user["username"] as! String
                cell.usernameLabel.text = username
            }
            
        }
        cell.usernameLabel.tag = indexPath.row
        
        //MARK: - Rank Label
        cell.rankLabel.frame = CGRectMake(cell.profileButton.frame.maxX + 2, cell.usernameLabel.frame.minY - 32, 60, 30)
        cell.rankLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        cell.rankLabel.textColor = fiftyGrayColor
        if leaderboardObjects[indexPath.row]["numberOfUpvotes"] != nil{
            cell.rankLabel.text = "\(indexPath.row + 1)"
        }
        
        //MARK: - Number Of Upvotes
        var numberOfUpvotes = Int()
        if leaderboardObjects[indexPath.row]["numberOfUpvotes"] != nil{
            numberOfUpvotes = leaderboardObjects[indexPath.row]["numberOfUpvotes"] as! Int
            let abbreviatedNumber = abbreviateNumber(numberOfUpvotes) as String
            cell.numberOfUpvotes.setTitle(abbreviatedNumber, forState: .Normal)
            cell.numberOfUpvotes.frame =  CGRectMake(cell.frame.maxX - 45, 5, 40, 60)
            cell.numberOfUpvotes.layer.cornerRadius = 3.0
            cell.numberOfUpvotes.layer.borderColor = oneFiftyGrayColor.CGColor
            cell.numberOfUpvotes.backgroundColor = oneFiftyGrayColor
            cell.numberOfUpvotes.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            cell.numberOfUpvotes.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
            cell.numberOfUpvotes.enabled = false
        }
        
        //MARK: - Upvote Label
        cell.upvotesLabel.frame = CGRectMake(cell.numberOfUpvotes.frame.minX + 2, cell.numberOfUpvotes.frame.maxY - 20, 38, 15)
        cell.upvotesLabel.text = "Upvotes"
        cell.upvotesLabel.font = UIFont(name: "HelveticaNeue-Light", size: 10)
        cell.upvotesLabel.textColor = UIColor.whiteColor()
        cell.upvotesLabel.textAlignment = .Center
        
        
        return cell
    }
    
    
    func queryForLeaderboardObjects(){

        let leaderboardQuery = PFQuery(className: "Leaderboard")
        leaderboardQuery.orderByDescending("numberOfUpvotes")
        leaderboardQuery.limit = 1000
        leaderboardQuery.cachePolicy = PFCachePolicy.NetworkElseCache
        leaderboardQuery.includeKey("userPointer")
        leaderboardQuery.findObjectsInBackgroundWithTarget(self, selector: "leaderboardSelector:error:")
        
    }
    
    func leaderboardSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            leaderboardObjects = objects as! [PFObject]
            tableView.reloadData()
        }else{
            println("Error: \(error.userInfo)")
        }
        stopActivityIndicator()
        currentUserLeaderboardQuery()
        
    }
    
    func currentUserLeaderboardQuery(){
        if PFUser.currentUser() != nil{
        let query = PFQuery(className: "Leaderboard")
        query.whereKey("userPointer", equalTo: PFUser.currentUser()!)
        query.cachePolicy = PFCachePolicy.NetworkElseCache
        query.includeKey("userPointer")
            query.getFirstObjectInBackgroundWithTarget(self, selector: "currentUserLeaderBoardSelector:error:")
        }
    }
    
    func currentUserLeaderBoardSelector(object: AnyObject!, error: NSError!){
        if error == nil{
            currenUserLeaderBoard = object as! PFObject
            if currenUserLeaderBoard["numberOfUpvotes"] != nil{
                let currentNumUpvotes = currenUserLeaderBoard["numberOfUpvotes"] as! Int
                let abNum = abbreviateNumber(currentNumUpvotes) as! String
                currentUserNumberOfUpvotesButton.setTitle(abNum, forState: .Normal)
                
                currentUserNumberOfUpvotesButton.frame = CGRectMake(bottomContainer.frame.maxX - 45, 5, 40, 60)
                currentUserNumberOfUpvotesButton.layer.cornerRadius = 3.0
                currentUserNumberOfUpvotesButton.backgroundColor = UIColor.whiteColor()
                currentUserNumberOfUpvotesButton.setTitleColor(oneFiftyGrayColor, forState: .Normal)
                currentUserNumberOfUpvotesButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
                currentUserNumberOfUpvotesButton.enabled = false
                bottomContainer.addSubview(currentUserNumberOfUpvotesButton)
                
                let upvotesLabel = UILabel()
                upvotesLabel.frame = CGRectMake(currentUserNumberOfUpvotesButton.frame.minX + 2, currentUserNumberOfUpvotesButton.frame.maxY - 20, 38, 15)
                upvotesLabel.text = "Upvotes"
                upvotesLabel.font = UIFont(name: "HelveticaNeue-Light", size: 10)
                upvotesLabel.textColor = oneFiftyGrayColor
                upvotesLabel.textAlignment = .Center
                bottomContainer.addSubview(upvotesLabel)
            }
        }else{
            println("Error: \(error.userInfo)")
        }
        
        totalUsersQuery()
    }
    
    func profileTapped(sender: AnyObject){
        let profileVC = ProfileViewController()
        if leaderboardObjects[sender.view!.tag]["userPointer"] != nil{
            profileVC.activeUser = leaderboardObjects[sender.view!.tag]["userPointer"] as! PFUser
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func startActivityIndicator(){
        
        activityIndicatorContainer.frame = CGRectMake(0, 0, self.view.frame.width, 1000)
        activityIndicatorContainer.backgroundColor = UIColor.whiteColor()
        activityIndicatorContainer.hidden = false
        self.view.addSubview(activityIndicatorContainer)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRectMake(0, 0, view.frame.width, 50)
        //activityIndicator.center = activityIndicatorContainer.center
        activityIndicatorContainer.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
    }
    
    func stopActivityIndicator(){
        
        activityIndicator.stopAnimating()
        activityIndicatorContainer.removeFromSuperview()
        tableView.hidden = false
        tableView.reloadData()
    }
    
    func totalUsersQuery(){
        
        let query = PFQuery(className: "TotalUsers")
        query.cachePolicy = PFCachePolicy.NetworkElseCache
        query.getObjectInBackgroundWithId("RjDIi23LNW", block: { (object, error) -> Void in
            if error == nil{
                //MARK: - World Rank Label
                self.worldRankTitleLabel.frame = CGRectMake(self.bottomContainer.frame.width/2 - 75, 3, 150, 20)
                self.worldRankTitleLabel.text = "Your World Ranking"
                self.worldRankTitleLabel.font = UIFont(name: "Helvetica", size: 14)
                self.worldRankTitleLabel.textColor = UIColor.blackColor()
                self.worldRankTitleLabel.textAlignment = NSTextAlignment.Center
                self.bottomContainer.addSubview(self.worldRankTitleLabel)
                
                
                self.worldRankLabel.frame = CGRectMake(self.view.frame.width/2 - 30, self.worldRankTitleLabel.frame.maxY + 3, 60, 20)
                self.worldRankLabel.font = UIFont(name: "HelveticaNeue", size: 11)
                self.worldRankLabel.textAlignment = NSTextAlignment.Center
                let gestureRec = UITapGestureRecognizer(target: self, action: "viewRank:")
                self.worldRankLabel.addGestureRecognizer(gestureRec)
                self.worldRankLabel.userInteractionEnabled = true
                self.worldRankLabel.text = "View Rank"
                self.worldRankLabel.backgroundColor = UIColor.whiteColor()
                self.worldRankLabel.textColor = oneFiftyGrayColor
                self.worldRankLabel.layer.cornerRadius = 3
                self.bottomContainer.addSubview(self.worldRankLabel)
                
                //MARK: - Total User Label
                self.totalUsersLabel.frame = CGRectMake(self.bottomContainer.frame.width/2 - 75, self.worldRankLabel.frame.maxY + 2, 150, 20)
                self.totalUsersLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                self.totalUsersLabel.textColor = UIColor.whiteColor()
                self.totalUsersLabel.textAlignment = NSTextAlignment.Center
                self.bottomContainer.addSubview(self.totalUsersLabel)
                
                
                let totalUsersObject = object!
                var totalUsersInt = Int()
                totalUsersInt = totalUsersObject["numberOfUsers"] as! Int
                self.totalUsersLabel.text = "out of " + (abbreviateNumber(totalUsersInt) as String) + " users"
            }
        })
        
        refreshTable.endRefreshing()
    }
    
    func worldRankQuery(){
        
        if PFUser.currentUser() != nil{
        var leaderboardObjectQuery = PFQuery(className: "Leaderboard")
        var leaderboardOjbect = PFObject(className: "LeaderBoard")
        leaderboardObjectQuery.whereKey("userPointer", equalTo: PFUser.currentUser()!)
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
                worldRankQuery.cachePolicy = PFCachePolicy.NetworkElseCache
                worldRankQuery.whereKey("numberOfUpvotes", greaterThan: numberOfUpvotes)
                worldRankQuery.countObjectsInBackgroundWithBlock({ (rank, error) -> Void in
                    if error == nil{
                        let worldRank = Int(rank) + 1
                        self.worldRankLabel.font = UIFont(name: "HelveticaNeue", size: 20)
                        self.worldRankLabel.textColor = redColor
                        self.worldRankLabel.frame = CGRectMake(self.bottomContainer.frame.width/2 - 75, self.worldRankTitleLabel.frame.maxY + 3, 150, 20)
                        self.worldRankLabel.textAlignment = NSTextAlignment.Center
                        self.worldRankLabel.text = abbreviateNumber(worldRank) as String
                        self.worldRankLabel.userInteractionEnabled = false
                        self.stopRankActivityIndicator()
                        
                    }
                })
                
            }
        }
        }
        
    }
    
    func viewRank(sender: AnyObject){
        worldRankLabel.backgroundColor = transparentColor
        worldRankLabel.text = ""
        startRankActivityIndicator()
        worldRankQuery()
        
    }
    
    func startRankActivityIndicator(){
        
        rankIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        rankIndicator.frame = CGRectMake(worldRankLabel.frame.width/2 - 10, 0, 20, 20)
        rankIndicator.backgroundColor = transparentColor
        worldRankLabel.addSubview(rankIndicator)
        rankIndicator.hidesWhenStopped = true
        rankIndicator.startAnimating()
    }
    
    func stopRankActivityIndicator(){
        rankIndicator.stopAnimating()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func refresh(sender:AnyObject)
    {
        queryForLeaderboardObjects()
    }
    
}