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

class TopicTodayTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var activityIndicator = UIActivityIndicatorView()
    var topicObjects = [PFObject(className: "Topic")]
    let activityIndicatorContainer = UIView()
    let refreshTable = UIRefreshControl()
    
    
    func queryForTopicObjects(){
        var query = PFQuery(className: "Topic")
        query.orderByAscending("createdAt")
        //query.cachePolicy = .NetworkElseCache
        query.orderByDescending("numberOfIdeas")
        query.limit = 100
        query.whereKeyExists("numberOfIdeas")
        query.whereKey("isPublic", equalTo: true)
        query.includeKey("creator")
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let timeZone = NSTimeZone(abbreviation: "GMT")
        calendar.timeZone = timeZone!
        let components = NSDateComponents()
        components.day = -1
        let oneDayAgo = calendar.dateByAddingComponents(components, toDate: now, options: nil)
        query.whereKey("createdAt", greaterThanOrEqualTo: oneDayAgo!)
        query.findObjectsInBackgroundWithTarget(self, selector: "topicSelector:error:")
    }
    
    func topicSelector(objects: [AnyObject]!, error: NSError!){
        if error == nil{
            //topicObjects = []
            topicObjects = objects as! [PFObject]
        }else{
            println("Error: \(error.userInfo)")
        }
        stopActivityIndicator()
        refreshTable.endRefreshing()
    }

    override func viewWillAppear(animated: Bool) {
        
        self.tabBarController!.tabBar.hidden = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 100
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0)
        tableView.registerClass(TopicTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        startActivityIndicator()
        queryForTopicObjects()
        
        self.refreshTable.attributedTitle = NSAttributedString(string: "")
        self.refreshTable.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshTable)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return topicObjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! TopicTableViewCell
        
        cell.frame = CGRectMake(0, 0, self.view.frame.width, 100)
        
        
        
        //MARK: - Idea Total Button Config
        var ideaTotalButtonWidth = CGFloat()
        var numberOfIdeas = Int()
        
        if topicObjects[indexPath.row]["numberOfIdeas"] != nil{
        numberOfIdeas = topicObjects[indexPath.row]["numberOfIdeas"] as! Int
            if numberOfIdeas < 1000{
                ideaTotalButtonWidth = 40
            }else if numberOfIdeas > 999 && numberOfIdeas < 10000{
                ideaTotalButtonWidth = 40
            }else if numberOfIdeas > 9999 && numberOfIdeas < 100000{
                ideaTotalButtonWidth = 50
            }
            cell.ideaTotalButton.setTitle("\(numberOfIdeas)", forState: .Normal)
        }else{
            ideaTotalButtonWidth = 40
        }
        
        cell.ideaTotalButton.frame =  CGRectMake(cell.frame.maxX - (ideaTotalButtonWidth + 10), 20, ideaTotalButtonWidth, cell.frame.height - 40)
        cell.ideaTotalButton.layer.cornerRadius = 3.0
        cell.ideaTotalButton.layer.borderColor = oneFiftyGrayColor.CGColor
        cell.ideaTotalButton.backgroundColor = oneFiftyGrayColor
        cell.ideaTotalButton.layer.borderWidth = 1
        cell.ideaTotalButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cell.ideaTotalButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        cell.ideaTotalButton.addTarget(self, action: "viewIdeas:", forControlEvents: .TouchUpInside)
        cell.ideaTotalButton.enabled = true
        cell.ideaTotalButton.tag = indexPath.row
        
        
        
        //MARK: - Idea Label
        cell.ideaLabel.frame = CGRectMake(cell.ideaTotalButton.frame.minX + 2, cell.ideaTotalButton.frame.maxY - 20, 38, 15)
        cell.ideaLabel.text = "Ideas"
        cell.ideaLabel.font = UIFont(name: "HelveticaNeue-Light", size: 10)
        cell.ideaLabel.textColor = UIColor.whiteColor()
        cell.ideaLabel.textAlignment = .Center
        cell.ideaLabel.tag = indexPath.row + 100
        
        
        //MARK: - Idea Topic Label Config
        var labelWidth = cell.frame.width - cell.ideaTotalButton.frame.width - 25
        cell.ideaTopicLabel.frame = CGRectMake(10, 10, labelWidth, 40)
        cell.ideaTopicLabel.font = UIFont(name: "Avenir", size: 13)
        cell.ideaTopicLabel.numberOfLines = 2
        cell.ideaTopicLabel.textColor = UIColor.blackColor()
        
        if let topicText = topicObjects[indexPath.row]["title"] as? String{
        
        cell.ideaTopicLabel.text = topicText
            
        }
        cell.ideaTopicLabel.tag = indexPath.row + 200
        
        
        //MARK: - Profile Button
        var pfUser = PFUser()
        if topicObjects[indexPath.row]["creator"] != nil{
            pfUser = topicObjects[indexPath.row]["creator"] as! PFUser
            if PFUser.currentUser() == pfUser{
                cell.profileButton.layer.borderColor = redColor.CGColor
                cell.profileButton.layer.borderWidth = 2
            }else{
                cell.profileButton.layer.borderColor = UIColor.whiteColor().CGColor
                cell.profileButton.layer.borderWidth = 0
            }
            
            getAvatar(pfUser, nil, cell.profileButton)
            
        }
        
        cell.profileButton.layer.masksToBounds = true
        let gestureRec = UITapGestureRecognizer(target: self, action: "profileTapped:")
        cell.profileButton.addGestureRecognizer(gestureRec)
        cell.profileButton.userInteractionEnabled = true
        cell.profileButton.frame = CGRectMake(10, 55, 40, 40)
        cell.profileButton.layer.cornerRadius = cell.profileButton.frame.width/2
        cell.profileButton.tag = indexPath.row
        
        
        //MARK: - Username Label Config
        var usernameLabelWidth = CGFloat()
        usernameLabelWidth = 190
        cell.usernameLabel.frame = CGRectMake(cell.profileButton.frame.maxX + 2, cell.profileButton.frame.maxY - cell.profileButton.frame.height/2, usernameLabelWidth, 20)
        cell.usernameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        cell.usernameLabel.textColor = twoHundredGrayColor
        if topicObjects[indexPath.row]["creator"] != nil{
        let username = pfUser["username"] as! String
        cell.usernameLabel.text = username
        }
        cell.usernameLabel.tag = indexPath.row + 400
        
        //MARK: - Time Stamp
        var createdAt = NSDate()
        
        if topicObjects[indexPath.row].createdAt != nil{
            createdAt = topicObjects[indexPath.row].createdAt!
            cell.timeStamp.text = createdAt.timeAgoSimple
        }
        cell.timeStamp.frame = CGRectMake(cell.frame.maxX - 30, cell.ideaTotalButton.frame.maxY + 3, 20, 20)
        cell.timeStamp.font = UIFont(name: "Avenir", size: 10)
        cell.timeStamp.textColor = oneFiftyGrayColor
        cell.timeStamp.textAlignment = NSTextAlignment.Right
        
        
//        //MARK: - Share Button Config
//        var shareImage = UIImage(named: "ideaShare.png") as UIImage!
//        let shareButtonX = cell.ideaTotalButton.frame.minX - 90
//        cell.shareButton.frame = CGRectMake(shareButtonX, 60, 20, 25)
//        cell.shareButton.setImage(shareImage, forState: .Normal)
//        cell.shareButton.addTarget(self, action: "shareTopic:", forControlEvents: .TouchUpInside)
//        cell.shareButton.tag = indexPath.row + 500
//        
//        
//        
//        //MARK: - Compose Button Config
//        var composeImage = UIImage(named: "ideaCompose.png") as UIImage!
//        cell.composeButton.frame = CGRectMake(cell.shareButton.frame.maxX + 15, 60, 20, 25)
//        cell.composeButton.setImage(composeImage, forState: .Normal)
//        cell.composeButton.addTarget(self, action: "composeForTopic:", forControlEvents: .TouchUpInside)
//        cell.composeButton.tag = indexPath.row + 600
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let topicDetailVC = TopicsDetailViewController()
        self.navigationController?.pushViewController(topicDetailVC, animated: true)
        
    }
    
    
    func viewIdeas(sender: UIButton!){
        //println(topicObjects)
        println("anything")
        //queryForTopicObjects()
        //tableView.reloadData()
        
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
        let profileVC = ProfileViewController()
        if topicObjects[sender.view!.tag]["creator"] != nil{
            profileVC.activeUser = topicObjects[sender.view!.tag]["creator"] as! PFUser
            navigationController?.pushViewController(profileVC, animated: true)
        }
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
