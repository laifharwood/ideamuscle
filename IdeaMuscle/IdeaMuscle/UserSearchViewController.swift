//
//  UserSearchViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 8/8/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

import UIKit
import Parse
import ParseUI

class UserSearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var activityIndicator = UIActivityIndicatorView()
    var tableView = UITableView()
    var userObjects = []
    let searchField = UITextField()
    let searchButton = UIButton()
    let searchTypeSelection = UISegmentedControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = fiftyGrayColor
        self.title = "User Search"
        
        searchField.delegate = self
        searchField.frame = CGRectMake(5, self.navigationController!.navigationBar.frame.maxY + 5, self.view.frame.width - 60, 30)
        searchField.placeholder = "Search"
        searchField.font = UIFont(name: "Avenir", size: 14)
        searchField.layer.cornerRadius = 3
        searchField.layer.borderWidth = 1
        searchField.layer.borderColor = oneFiftyGrayColor.CGColor
        searchField.backgroundColor = UIColor.whiteColor()
        searchField.textColor = UIColor.blackColor()
        let paddingView = UIView(frame: CGRectMake(0, 0, 5, searchField.frame.height))
        searchField.leftView = paddingView
        searchField.leftViewMode = UITextFieldViewMode.Always
        self.view.addSubview(searchField)
        
        searchButton.frame = CGRectMake(searchField.frame.maxX + 5, self.navigationController!.navigationBar.frame.maxY + 5, 40, 30)
        searchButton.setTitle("Go", forState: .Normal)
        searchButton.setTitleColor(fiftyGrayColor, forState: .Normal)
        searchButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        searchButton.backgroundColor = redColor
        searchButton.enabled = false
        searchButton.backgroundColor = twoHundredGrayColor
        searchButton.layer.cornerRadius = 3
        searchButton.addTarget(self, action: "querySearch:", forControlEvents: .TouchUpInside)
        self.view.addSubview(searchButton)
        
        let searchTypeContainer = UIView(frame: CGRectMake(0, searchField.frame.maxY + 5, self.view.frame.width, 30))
        searchTypeContainer.backgroundColor = oneFiftyGrayColor
        self.view.addSubview(searchTypeContainer)
        
        searchTypeSelection.insertSegmentWithTitle("Exact Match", atIndex: 0, animated: false)
        searchTypeSelection.insertSegmentWithTitle("Broad Match", atIndex: 1, animated: false)
        searchTypeSelection.selectedSegmentIndex = 0
        searchTypeSelection.frame = CGRectMake(5, 5, searchTypeContainer.frame.width - 10, 20)
        searchTypeSelection.tintColor = UIColor.whiteColor()
        searchTypeSelection.backgroundColor = seventySevenGrayColor
        searchTypeSelection.layer.borderColor = UIColor.whiteColor().CGColor
        searchTypeSelection.layer.cornerRadius = 4
        searchTypeSelection.addTarget(self, action: "changeSearchType:", forControlEvents: .ValueChanged)
        searchTypeContainer.addSubview(searchTypeSelection)
        
        //MARK: - TableView Did Load
        tableView.rowHeight = 70
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0)
        tableView.registerClass(LeaderboardTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = CGRectMake(0, searchTypeContainer.frame.maxY, self.view.frame.width, self.view.frame.height - searchTypeContainer.frame.maxY)
        //self.view.addSubview(tableView)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = true
    }
    
    func querySearch(sender: UIButton){
        startActivityIndicator()
        
        let lowercaseSearchString = searchField.text.lowercaseString
        
        let query = PFQuery(className: "_User")
        query.cachePolicy = PFCachePolicy.NetworkElseCache
        
        if searchTypeSelection.selectedSegmentIndex == 0{
            query.whereKey("lowercaseUsername", equalTo: lowercaseSearchString)
        }else if searchTypeSelection.selectedSegmentIndex == 1{
            query.whereKey("lowercaseUsername", containsString: lowercaseSearchString)
        }
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil{
                self.userObjects = objects as! [PFUser]
            }
            self.stopActivityIndicator()
        }
    }
    
    func changeSearchType(sender: UISegmentedControl){
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if string == ""{
            if count(searchField.text) - 1 > 3{
                searchButton.enabled = false
                searchButton.backgroundColor = twoHundredGrayColor
            }
        }
        if count(searchField.text) + count(string) > 3{
            searchButton.enabled = true
            searchButton.backgroundColor = redColor
        }else{
            searchButton.enabled = false
            searchButton.backgroundColor = twoHundredGrayColor
        }
        return true
    }
    
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userObjects.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! LeaderboardTableViewCell
        //cell.frame = CGRectMake(0, 0, view.frame.width, 70)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        
        //MARK: - Profile Buttons
        if let user = userObjects[indexPath.row] as? PFUser{
            if PFUser.currentUser() == user{
                cell.profileButton.layer.borderColor = redColor.CGColor
                cell.profileButton.layer.borderWidth = 2
            }else{
                cell.profileButton.layer.borderColor = UIColor.whiteColor().CGColor
                cell.profileButton.layer.borderWidth = 0
            }
            getAvatar(user, nil, cell.profileButton)
            
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
            if let username = user.username{
                cell.usernameLabel.text = username
            }
            cell.usernameLabel.tag = indexPath.row
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let profileVC = ProfileViewController()
        if let user = userObjects[indexPath.row] as? PFUser{
            profileVC.activeUser = user
            user.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
                if error == nil{
                    self.navigationController?.pushViewController(profileVC, animated: true)
                }
            }
        }
    }
    

    
    func profileTapped(sender: AnyObject){
        let profileVC = ProfileViewController()
        if let user = userObjects[sender.view!.tag] as? PFUser{
            profileVC.activeUser = user
            user.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
                if error == nil{
                    self.navigationController?.pushViewController(profileVC, animated: true)
                }
            }
        }
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func startActivityIndicator(){
        
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRectMake(self.view.frame.width/2 - 25, tableView.frame.minY, 50, 50)
        tableView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator(){
        self.view.addSubview(tableView)
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    
}

