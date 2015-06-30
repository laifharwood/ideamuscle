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
    
    var tableView = UITableView()
    var leaderboardObjects = [PFObject(className: "LeaderBoard")]
    var followingObjects = [PFObject(className: "following")]
    var query = PFQuery()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        followingQuery()
        
        //MARK: - Bottom container
        let bottomContainer = UIView()
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
        
        let leaderboardQuery = PFQuery(className: "Leaderboard")
        leaderboardQuery.whereKey("userPointer", matchesQuery: query)
        leaderboardQuery.orderByDescending("numberOfUpvotes")
        leaderboardQuery.limit = 1000
        leaderboardQuery.includeKey("userPointer")
        leaderboardQuery.findObjectsInBackgroundWithTarget(self, selector: "leaderboardSelector:error:")
        
    }
    
    func leaderboardSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            leaderboardObjects = objects as! [PFObject]
            tableView.reloadData()
            println(leaderboardObjects)
        }else{
            println("Error: \(error.userInfo)")
        }
        //stopActivityIndicator()
        //refreshTable.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
