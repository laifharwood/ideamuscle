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

class FriendsLeaderboardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var activityIndicator = UIActivityIndicatorView()
    let activityIndicatorContainer = UIView()
    var tableView = UITableView()
    var leaderboardObjects = [PFObject(className: "Leaderboard")]
    var followingObjects = [PFObject(className: "following")]
    var query = PFQuery()
    let refreshTable = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - TableView Did Load
        tableView.rowHeight = 70
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 200, 0)
        tableView.registerClass(LeaderboardTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(tableView)
        
        refreshTable.attributedTitle = NSAttributedString(string: "")
        refreshTable.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshTable)
        
        startActivityIndicator()
        followingQuery()

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
    
    func followingQuery(){
        if let currentUser = PFUser.currentUser(){
            var relation = PFRelation()
            query.includeKey("following")
            relation = currentUser.relationForKey("following")
            query = relation.query()!
            query.findObjectsInBackgroundWithTarget(self, selector: "followingSelector:error:")
        }
    }
    
    func followingSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            
            followingObjects = objects as! [PFObject]
            queryForLeaderboardObjects()
            
        }else{
            println("Error: \(error.userInfo)")
        }
    }
    
    func queryForLeaderboardObjects(){
        
        
        let friendsQuery = PFQuery(className: "Leaderboard")
        let selfQuery = PFQuery(className: "Leaderboard")
        if PFUser.currentUser() != nil{
            friendsQuery.whereKey("userPointer", matchesQuery: query)
            selfQuery.whereKey("userPointer", equalTo: PFUser.currentUser()!)
        }
        let leaderboardQuery = PFQuery.orQueryWithSubqueries([friendsQuery, selfQuery])
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
        refreshTable.endRefreshing()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func refresh(sender:AnyObject)
    {
        followingQuery()
    }
    
}
