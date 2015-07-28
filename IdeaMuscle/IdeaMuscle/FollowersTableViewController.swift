//
//  FollowersTableViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/22/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class FollowersTableViewController: UITableViewController {
    var activeUser = PFUser()
    var activeUserFollowers = [PFUser()]
    var activityIndicator = UIActivityIndicatorView()
    var isFollowing = [Bool?](count: 1000, repeatedValue: nil)
    var currentUserFollowing = [PFUser()]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startActivityIndicator()
        queryActiveUserFollowers()
        
        if let username = activeUser.username{
            self.title = username + "'s" + " Followers"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(FriendshipTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 80

    }
    
    func queryCurrentUserFollowing(){
        if let currentUser = PFUser.currentUser(){
            var relation = PFRelation()
            var query = PFQuery(className: "_User")
            relation = currentUser.relationForKey("following")
            query = relation.query()!
            query.limit = 1000
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil{
                    self.currentUserFollowing = objects as! [PFUser]
                }
                self.stopActivityIndicator()
            })
        }
    }
    
    func queryActiveUserFollowers(){
        let query = PFQuery(className: "_User")
        query.whereKey("following", equalTo: activeUser)
        query.orderByAscending("username")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil{
                self.activeUserFollowers = objects as! [PFUser]
                self.queryCurrentUserFollowing()
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

        return activeUserFollowers.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FriendshipTableViewCell

        let user = activeUserFollowers[indexPath.row]
        
        getAvatar(user, nil, cell.profileButton)
        let gestureRec = UITapGestureRecognizer(target: self, action: "profileTapped:")
        cell.profileButton.addGestureRecognizer(gestureRec)
        cell.profileButton.userInteractionEnabled = true
        cell.profileButton.frame = CGRectMake(10, 10, 60, 60)
        cell.profileButton.layer.cornerRadius = 30
        cell.profileButton.layer.masksToBounds = true
        cell.profileButton.tag = indexPath.row
        
        if let currentUser = PFUser.currentUser(){
            cell.followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            cell.followButton.addTarget(self, action: "follow:", forControlEvents: .TouchUpInside)
            cell.followButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
            cell.followButton.layer.cornerRadius = 3
            cell.followButton.tag = indexPath.row
            
            if contains(currentUserFollowing, user){
                cell.followButton.setTitle("Following", forState: .Normal)
                cell.followButton.backgroundColor = oneFiftyGrayColor
                isFollowing[indexPath.row] = true
            }else{
                cell.followButton.setTitle("Follow", forState: .Normal)
                cell.followButton.backgroundColor = redColor
                isFollowing[indexPath.row] = false
            }
            
            if currentUser != user{
                cell.followButton.frame = CGRectMake(cell.frame.maxX - 90, cell.frame.height/2 - 20, 80, 40)
            }else{
                cell.followButton.hidden = true
            }
        }
        
        if let username = user.username{
            cell.usernameLabel.text = username
            cell.usernameLabel.frame = CGRectMake(cell.profileButton.frame.maxX + 2, cell.profileButton.frame.maxY - cell.profileButton.frame.height/2, cell.frame.width - cell.profileButton.frame.width - cell.followButton.frame.width - 27, 20)
            cell.usernameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
            cell.usernameLabel.textColor = twoHundredGrayColor
        }
        
        

        
        return cell
    }
    
    func follow(sender: UIButton!){
        if isFollowing[sender.tag] == true{
            //Unfollow
            if let user = PFUser.currentUser(){
                let userToFollow = activeUserFollowers[sender.tag]
                followGlobal(userToFollow, false, self)
                sender.setTitle("Follow", forState: .Normal)
                sender.backgroundColor = redColor
                isFollowing[sender.tag] = false
            }
            
        }else{
            //Follow
            if let user = PFUser.currentUser(){
                let userToFollow = activeUserFollowers[sender.tag]
                followGlobal(userToFollow, true, self)
                if let numberFollowing = user["isFollowing"] as? Int{
                    if numberFollowing < 1000{
                        sender.setTitle("Following", forState: .Normal)
                        sender.backgroundColor = oneFiftyGrayColor
                        isFollowing[sender.tag] = true
                    }
                }
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
        profileVC.activeUser = activeUserFollowers[sender.view!.tag]
        navigationController?.pushViewController(profileVC, animated: true)
    }
    

}
