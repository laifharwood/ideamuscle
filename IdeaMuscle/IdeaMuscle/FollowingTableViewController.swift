//
//  FollowingTableViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/22/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class FollowingTableViewController: UITableViewController {
    var activeUser = PFUser()
    var activeUserFollowing = [PFUser()]
    var activityIndicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startActivityIndicator()
        activeUserFollowingQuery()
        
        if let username = activeUser.username{
            self.title = "Who " + username + " Follows"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(FriendshipTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 80
        
    }
    
    
    func activeUserFollowingQuery(){
        var query = PFQuery(className: "_User")
        var relation = PFRelation()
        relation = activeUser.relationForKey("following")
        query = relation.query()!
        query.limit = 1000
        query.cachePolicy = PFCachePolicy.NetworkElseCache
        query.orderByAscending("username")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil{
                self.activeUserFollowing = objects as! [PFUser]
                self.stopActivityIndicator()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return activeUserFollowing.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FriendshipTableViewCell
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        let user = activeUserFollowing[indexPath.row]
        
        getAvatar(user, nil, cell.profileButton)
        let gestureRec = UITapGestureRecognizer(target: self, action: "profileTapped:")
        cell.profileButton.addGestureRecognizer(gestureRec)
        cell.profileButton.userInteractionEnabled = true
        cell.profileButton.frame = CGRectMake(10, 10, 60, 60)
        cell.profileButton.layer.cornerRadius = 30
        cell.profileButton.layer.masksToBounds = true
        cell.profileButton.tag = indexPath.row
        

        
        if let username = user.username{
            cell.usernameLabel.text = username
            cell.usernameLabel.frame = CGRectMake(cell.profileButton.frame.maxX + 2, cell.profileButton.frame.maxY - cell.profileButton.frame.height/2, cell.frame.width - cell.profileButton.frame.width - cell.followButton.frame.width - 27, 20)
            cell.usernameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
            cell.usernameLabel.textColor = twoHundredGrayColor
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let profileVC = ProfileViewController()
        let user = activeUserFollowing[indexPath.row]
        user.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
            if error == nil{
                profileVC.activeUser = user
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        }
    }
    
    func startActivityIndicator(){
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRectMake(self.view.frame.width/2 - 25, tableView.frame.minY - 15, 50, 50)
        tableView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator(){
        
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func profileTapped(sender: AnyObject){
        let profileVC = ProfileViewController()
        profileVC.activeUser = activeUserFollowing[sender.view!.tag]
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
