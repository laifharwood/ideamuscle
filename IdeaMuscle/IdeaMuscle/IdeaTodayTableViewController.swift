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
    
    
    func queryForTopicObjects(){
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
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 150
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0)
        tableView.registerClass(IdeaTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        startActivityIndicator()
        queryForTopicObjects()
        
        self.refreshTable.attributedTitle = NSAttributedString(string: "Pull to refresh")
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
        var numberOfUpvotesButtonWidth = CGFloat()
        var numberOfUpvotes = Int()
        
        if ideaObjects[indexPath.row]["numberOfUpvotes"] != nil{
            numberOfUpvotes = ideaObjects[indexPath.row]["numberOfUpvotes"] as! Int
            if numberOfUpvotes < 1000{
                numberOfUpvotesButtonWidth = 45
            }else if numberOfUpvotes > 999 && numberOfUpvotes < 10000{
                numberOfUpvotesButtonWidth = 45
            }else if numberOfUpvotes > 9999 && numberOfUpvotes < 100000{
                numberOfUpvotesButtonWidth = 55
            }
            cell.numberOfUpvotesButton.setTitle("\(numberOfUpvotes)", forState: .Normal)
            
            if let currentUser = PFUser.currentUser(){
                
                let ideaObject = ideaObjects[indexPath.row]
                    
                if ideaObject.objectForKey("usersWhoUpvoted")?.containsObject(currentUser) == true{
                    
                    cell.numberOfUpvotesButton.setTitleColor(redColor, forState: .Normal)
                    cell.numberOfUpvotesButton.tintColor = redColor
                    cell.numberOfUpvotesButton.layer.borderColor = redColor.CGColor
                    hasUpvoted[indexPath.row] = true
                    
                    
                    
                }else{
                    
                    cell.numberOfUpvotesButton.setTitleColor(oneFiftyGrayColor, forState: .Normal)
                    cell.numberOfUpvotesButton.tintColor = oneFiftyGrayColor
                    cell.numberOfUpvotesButton.layer.borderColor = oneFiftyGrayColor.CGColor
                    hasUpvoted[indexPath.row] = false
                }
                
                
            }
        }else{
            numberOfUpvotesButtonWidth = 45
            cell.numberOfUpvotesButton.setTitle("0", forState: .Normal)
            cell.numberOfUpvotesButton.setTitleColor(oneFiftyGrayColor, forState: .Normal)
        }
        
        cell.numberOfUpvotesButton.frame =  CGRectMake(cell.frame.maxX - (numberOfUpvotesButtonWidth) - 5, cell.frame.height/2 - 35, numberOfUpvotesButtonWidth, 70)
        let image = UIImage(named: "upvoteArrow")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.numberOfUpvotesButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 18)
        cell.numberOfUpvotesButton.setImage(image, forState: .Normal)
        
        let spacing = CGFloat(20)
        
        let imageSize = cell.numberOfUpvotesButton.imageView!.frame.size
        let titleSize = cell.numberOfUpvotesButton.titleLabel!.frame.size
        
        cell.numberOfUpvotesButton.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0)
        cell.numberOfUpvotesButton.imageEdgeInsets = UIEdgeInsetsMake(-45, 0.0, 0.0, -titleSize.width)
        
        cell.numberOfUpvotesButton.layer.cornerRadius = 3
        cell.numberOfUpvotesButton.layer.borderWidth = 1
        
        
        cell.numberOfUpvotesButton.addTarget(self, action: "upvote:", forControlEvents: .TouchUpInside)
        cell.numberOfUpvotesButton.tag = indexPath.row
        
        
        
        //MARK: - Topic Label Config
        var labelWidth = cell.frame.width - cell.numberOfUpvotesButton.frame.width - 25
        cell.topicLabel.frame = CGRectMake(10, 5, labelWidth, 20)
        cell.topicLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        cell.topicLabel.numberOfLines = 1
        cell.topicLabel.textColor = oneFiftyGrayColor
        
        if let topic = ideaObjects[indexPath.row]["topicPointer"] as? PFObject{
            
            let topicText = topic["title"] as! String
            
            cell.topicLabel.text = topicText
            
        }
        cell.topicLabel.tag = indexPath.row + 200
        
        //MARK: - Idea Label Config
        cell.ideaLabel.numberOfLines = 0
        cell.ideaLabel.frame = CGRectMake(25, cell.topicLabel.frame.maxY + 2, labelWidth - 5, 70)
        
        cell.ideaLabel.font = UIFont(name: "HelveticaNeue", size: 13)
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
            
            let pfFile = pfUser["avatar"] as! PFFile
            
            pfFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error != nil{
                    //cell.profileImage = UIImage(named: "smallLogo.png")!
                }else{
                    
                    cell.profileImage = UIImage(data: data!)!
                }
                cell.profileImage = cropToSquare(image: cell.profileImage)
                cell.profileImage = cell.profileImage.convertToGrayScale()
                cell.profileButton.image = cell.profileImage
            })
            
        }else{
            
            cell.profileButton.backgroundColor = UIColor.grayColor()
        }
        
        
        cell.profileButton.layer.cornerRadius = cell.profileButton.frame.width/2
        
        cell.profileButton.layer.masksToBounds = true
        cell.profileButton.tag = indexPath.row
        let gestureRec = UITapGestureRecognizer(target: self, action: "profileTapped:")
        cell.profileButton.addGestureRecognizer(gestureRec)
        cell.profileButton.userInteractionEnabled = true
        cell.profileButton.frame = CGRectMake(10, 105, 40, 40)
        cell.profileButton.layer.cornerRadius = cell.profileButton.frame.width/2
        cell.profileButton.tag = indexPath.row + 300
        
        
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
        
        
        
        //MARK: - Share Button Config
        var shareImage = UIImage(named: "ideaShare.png") as UIImage!
        let shareButtonX = cell.numberOfUpvotesButton.frame.minX - 90
        cell.shareButton.frame = CGRectMake(shareButtonX, cell.usernameLabel.frame.minY - 7, 20, 25)
        cell.shareButton.setImage(shareImage, forState: .Normal)
        cell.shareButton.addTarget(self, action: "shareTopic:", forControlEvents: .TouchUpInside)
        cell.shareButton.tag = indexPath.row + 500
        
        
        
        //MARK: - Compose Button Config
        var composeImage = UIImage(named: "ideaCompose.png") as UIImage!
        cell.composeButton.frame = CGRectMake(cell.shareButton.frame.maxX + 15, cell.usernameLabel.frame.minY - 7, 20, 25)
        cell.composeButton.setImage(composeImage, forState: .Normal)
        cell.composeButton.addTarget(self, action: "composeForTopic:", forControlEvents: .TouchUpInside)
        cell.composeButton.tag = indexPath.row + 600
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    func upvote(sender: UIButton!){
        
        let ideaObject = ideaObjects[sender.tag]
        
        if hasUpvoted[sender.tag] == true{
            //Remove Upvote
            if let user = PFUser.currentUser(){
            ideaObject.removeObject(user, forKey: "usersWhoUpvoted")
            ideaObject.incrementKey("numberOfUpvotes", byAmount: -1)
            ideaObject.saveInBackground()
            
            var upvoteObjectQuery = PFQuery(className: "Upvote")
            upvoteObjectQuery.whereKey("userWhoUpvoted", equalTo: user)
            upvoteObjectQuery.whereKey("ideaUpvoted", equalTo: ideaObject)
            
            var upvoteObject = PFObject(className: "Upvote")
            
            upvoteObjectQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                if error != nil{
                    
                }else{
                    upvoteObject = object! as PFObject
                    upvoteObject.deleteInBackground()
                }
               sender.setTitleColor(oneFiftyGrayColor, forState: .Normal)
                let title = ideaObject["numberOfUpvotes"] as! Int
               sender.setTitle("\(title)", forState: .Normal)
               sender.setTitleColor(oneFiftyGrayColor, forState: .Normal)
                sender.tintColor = oneFiftyGrayColor
               sender.layer.borderColor = oneFiftyGrayColor.CGColor
            })
            
            }
            hasUpvoted[sender.tag] = false
        }else{
            //Add Upvote
            if let user = PFUser.currentUser(){
                ideaObject.addObject(user, forKey: "usersWhoUpvoted")
                ideaObject.incrementKey("numberOfUpvotes")
                ideaObject.saveInBackground()
                
                var upvoteObject = PFObject(className: "Upvote")
                upvoteObject.setObject(user, forKey: "userWhoUpvoted")
                upvoteObject.setObject(ideaObject, forKey: "ideaUpvoted")
                upvoteObject.saveInBackground()
                
                sender.setTitleColor(redColor, forState: .Normal)
                let title = ideaObject["numberOfUpvotes"] as! Int
                sender.setTitle("\(title)", forState: .Normal)
                sender.setTitleColor(redColor, forState: .Normal)
                sender.tintColor = redColor
                
                sender.layer.borderColor = redColor.CGColor
                hasUpvoted[sender.tag] = true
                
            }
            
            
            
        }
    }
    
    func startActivityIndicator(){
        
        println("activity Indicator Started")
        
        activityIndicatorContainer.frame = CGRectMake(0, 0, self.view.frame.width, 50)
        
        //activityIndicatorContainer.backgroundColor = UIColor.blackColor()
        activityIndicatorContainer.hidden = false
        self.view.addSubview(activityIndicatorContainer)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRectMake(0, 0, 50, 50)
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
        
        println(sender.view!.tag)
    }
    
    func refresh(sender:AnyObject)
    {
        queryForTopicObjects()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
