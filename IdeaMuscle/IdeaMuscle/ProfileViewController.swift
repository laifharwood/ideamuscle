//
//  ProfileViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/25/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {
    
    var activeUser = PFUser()
    var worldRank = Int()
    var worldRankLabel = UILabel()
    var isFollowing = Bool()
    var followButton = UIButton()
    var following = [PFObject(className: "following")]
    var activityIndicator = UIActivityIndicatorView()
    let worldRankTitleLabel = UILabel()
    var ideaTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        startActivityIndicator()
        worldRankQuery()
        if activeUser != PFUser.currentUser(){
        followingQuery()
        }
        
        
        
        
        //Avatar
        var avatarFile = PFFile()
        var image = UIImage()
        var username = String()
        var imageView = UIImageView()
        imageView.frame = CGRectMake(self.view.frame.width/2 - 50, 80, 100, 100)
        if activeUser["avatar"] != nil{
            
                avatarFile = activeUser["avatar"] as! PFFile
                
                avatarFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil{
                        
                        image = UIImage(data: data!)!
                        image = cropToSquare(image: image)
                        image = image.convertToGrayScale()
                        imageView.image = image
                    }else{
                        
                        println("Error: \(error!.userInfo)")
                        
                    }
                })
            }
            imageView.layer.cornerRadius = 50
            imageView.layer.masksToBounds = true
            self.view.addSubview(imageView)
        
        //Username
        var usernameLabel = UILabel(frame: CGRectMake(5, imageView.frame.maxY + 2, self.view.frame.width - 10, 20))
        usernameLabel.textAlignment = NSTextAlignment.Center
        if activeUser["username"] != nil{
            
            usernameLabel.text = activeUser["username"] as? String
        }
        usernameLabel.font = UIFont(name: "Avenir-Light", size: 14)
        usernameLabel.textColor = fiftyGrayColor
        self.view.addSubview(usernameLabel)
        
        //World Rank Label
        worldRankTitleLabel.frame = CGRectMake(self.view.frame.width/3 - 50 - 30, usernameLabel.frame.maxY + 2, 100, 20)
        worldRankTitleLabel.text = "World Ranking"
        worldRankTitleLabel.font = UIFont(name: "Helvetica", size: 14)
        worldRankTitleLabel.textColor = oneFiftyGrayColor
        worldRankTitleLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(worldRankTitleLabel)
        
        worldRankLabel.frame = CGRectMake(self.view.frame.width/3 - 75 - 30, worldRankTitleLabel.frame.maxY - 3, 150, 40)
        worldRankLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        worldRankLabel.textColor = redColor
        worldRankLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(worldRankLabel)
        
        //Follow Button
        followButton.frame = CGRectMake(self.view.frame.width/3 * 2 - 40 + 30, worldRankTitleLabel.frame.minY + 10, 80, 40)
        let currentUser = PFUser.currentUser()
        
        
        followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        followButton.addTarget(self, action: "follow:", forControlEvents: .TouchUpInside)
        followButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        followButton.layer.cornerRadius = 3
        
        if activeUser != currentUser{
        self.view.addSubview(followButton)
        }
        
    }
    
    func follow(sender: UIButton!){
        if isFollowing == true{
            //Unfollow
            println("Unfollow")
            if let currentUser = PFUser.currentUser(){
                let relation = currentUser.relationForKey("following")
                relation.removeObject(activeUser)
                currentUser.saveInBackground()
                self.followButton.setTitle("Follow", forState: .Normal)
                self.followButton.backgroundColor = redColor
                self.isFollowing = false
            }
        }else{
            //Follow
            println("Follow")
            if let currentUser = PFUser.currentUser(){
                let relation = currentUser.relationForKey("following")
                relation.addObject(activeUser)
                currentUser.saveInBackground()
                self.followButton.setTitle("Following", forState: .Normal)
                self.followButton.backgroundColor = oneFiftyGrayColor
                isFollowing = true
                
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
                worldRankQuery.whereKey("numberOfUpvotes", greaterThanOrEqualTo: numberOfUpvotes)
                worldRankQuery.countObjectsInBackgroundWithBlock({ (rank, error) -> Void in
                    if error == nil{
                        self.worldRank = Int(rank)
                        //self.worldRankLabel.text = "\(self.worldRank)"
                        self.worldRankLabel.text = abbreviateNumber(self.worldRank) as String
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

    func startActivityIndicator(){
        
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.frame = CGRectMake(50, 0, 50, 50)
        activityIndicator.backgroundColor = UIColor.whiteColor()
        worldRankLabel.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        
    }
    
    func stopActivityIndicator(){
        self.activityIndicator.stopAnimating()
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    

}
