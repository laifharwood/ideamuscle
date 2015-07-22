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
    var followers = [PFUser()]
    var activityIndicator = UIActivityIndicatorView()
    var isFollowing = [Bool?](count: 1000, repeatedValue: nil)
    var following = [PFObject(className: "following")]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startActivityIndicator()
        queryFollowers()
        
        if let username = activeUser.username{
            self.title = username + "'s" + " Followers"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(FriendshipTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 80

    }
    
    func followingQuery(){
        if let currentUser = PFUser.currentUser(){
            var relation = PFRelation()
            var query = PFQuery()
            relation = currentUser.relationForKey("following")
            query = relation.query()!
            query.limit = 1000
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil{
                    self.following = objects as! [PFObject]
                }
                self.stopActivityIndicator()
            })
        }
    }
    
    func queryFollowers(){
        let query = PFQuery(className: "_User")
        query.whereKey("following", equalTo: activeUser)
        query.orderByAscending("username")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil{
                self.followers = objects as! [PFUser]
                self.followingQuery()
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

        return followers.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FriendshipTableViewCell

        let user = followers[indexPath.row]
        
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
            
            if contains(following, user){
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
        profileVC.activeUser = followers[sender.view!.tag]
        navigationController?.pushViewController(profileVC, animated: true)
    }
    

}
