//
//  MoreViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/5/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class MoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate{
    
    var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "More"
        
        //Right Compose Button
        let composeOriginalButton = UIButton()
        let composeOriginalImage = UIImage(named: "compose")
        composeOriginalButton.setImage(composeOriginalImage, forState: .Normal)
        composeOriginalButton.frame = CGRectMake(self.view.frame.width - 38, 25, 25, 25)
        composeOriginalButton.addTarget(self, action: "composeOriginal:", forControlEvents: .TouchUpInside)
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: composeOriginalButton)
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false);
        
        //MARK: - Left Small Logo
        
        let leftLogoView = UIImageView(image: smallLogo)
        leftLogoView.frame = CGRectMake(10, 25, 35, 35)
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: leftLogoView)
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        
        
        
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - tabBarController!.tabBar.frame.height)
        tableView.sectionHeaderHeight = 10
        //tableView.headerViewForSection(0)?.backgroundColor = oneFiftyGrayColor
        self.view.addSubview(tableView)
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = oneFiftyGrayColor
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.tabBarController != nil{
            self.tabBarController!.tabBar.hidden = false
            //updateMoreBadge(self.tabBarController!)
        }
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 4
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        
        if section == 0{
            return 4
        }else if section == 1{
            return 3
        }else if section == 2{
            return 3
        }else if section == 3{
            return 2
        }else{
            return 0
        }
    }
    
    func composeOriginal(sender: UIButton!){
        
        //composeOriginalGlobal(self)
        composeFromDetail(self, nil, true)
        
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
         //var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        var cell = MoreTableViewCell()
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        cell.textLabel!.font = UIFont(name: "HelveticaNeue", size: 13)

        // Configure the cell...
        if indexPath == NSIndexPath(forRow: 0, inSection: 0){
            cell.textLabel!.text = "Profile"
        }else if indexPath == NSIndexPath(forRow: 1, inSection: 0){
            cell.textLabel!.text = "Your Ideas"
        }else if indexPath == NSIndexPath(forRow: 2, inSection: 0){
            cell.textLabel!.text = "Your Topics"
        }else if indexPath == NSIndexPath(forRow: 3, inSection: 0){
            cell.textLabel!.text = "Ideas You've Upvoted"
        }else if indexPath == NSIndexPath(forRow: 0, inSection: 1){
            cell.textLabel!.text = "Drafts"
        }else if indexPath == NSIndexPath(forRow: 1, inSection: 1){
            cell.textLabel!.text = "Notifications"
            let badgeValue = PFInstallation.currentInstallation().badge
            if badgeValue != 0{
                
                var width = CGFloat()
                
                if badgeValue < 10{
                    
                    width = 20
                    
                }else{
                    width = 40
                }
                
                cell.badgeLabel.layer.cornerRadius = 10
                cell.badgeLabel.layer.masksToBounds = true
                cell.badgeLabel.frame = CGRectMake(cell.frame.maxX - width - 30, cell.frame.height/2 - 10, width, 20)
                cell.badgeLabel.backgroundColor = notificationRedColor
                cell.badgeLabel.font = UIFont(name: "HelveticaNeue", size: 11)
                cell.badgeLabel.textColor = UIColor.whiteColor()
                cell.badgeLabel.text = abbreviateNumber(badgeValue) as String
                cell.badgeLabel.textAlignment = NSTextAlignment.Center
            }

        }else if indexPath == NSIndexPath(forRow: 2, inSection: 1){
            cell.textLabel!.text = "Search For Users"
        }else if indexPath == NSIndexPath(forRow: 0, inSection: 2){
            cell.textLabel!.text = "Store"
        }else if indexPath == NSIndexPath(forRow: 1, inSection: 2){
            cell.textLabel!.text = "Report An Issue / Contact Us"
        }else if indexPath == NSIndexPath(forRow: 2, inSection: 2){
            cell.textLabel!.text = "End User License Agreement"
        }
        else if indexPath == NSIndexPath(forRow: 0, inSection: 3){
            cell.textLabel!.text = "Idea Muscle Orientation"
            cell.accessoryType = UITableViewCellAccessoryType.None
        }else if indexPath == NSIndexPath(forRow: 1, inSection: 3){
            cell.textLabel!.text = "Sign Out"
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        
        if indexPath == NSIndexPath(forRow: 0, inSection: 0){
            //Profile
            let profileVC = ProfileViewController()
            if let user = PFUser.currentUser(){
                profileVC.activeUser = user
                navigationController?.pushViewController(profileVC, animated: true)
            }
        }else if indexPath == NSIndexPath(forRow: 1, inSection: 0){
            //User Ideas
            let userIdeasVC = UserIdeasTableViewController()
            navigationController?.pushViewController(userIdeasVC, animated: true)
        }else if indexPath == NSIndexPath(forRow: 2, inSection: 0){
            //User Topics
            let userTopicsVC = UserTopicsTableViewController()
            navigationController?.pushViewController(userTopicsVC, animated: true)
        }else if indexPath == NSIndexPath(forRow: 3, inSection: 0){
            //Ideas User Upvoted
            if let user = PFUser.currentUser(){
                if let isPro = user["isPro"] as? Bool{
                    if isPro{
                        let ideasUserUpvotedVC = IdeasUserUpvotedTableViewController()
                        navigationController?.pushViewController(ideasUserUpvotedVC, animated: true)
                    }else{
                        upgradeUpvotedAlert()
                    }
                }else{
                    upgradeUpvotedAlert()
                }
            }
        }else if indexPath == NSIndexPath(forRow: 0, inSection: 1){
            //Drafts
            if let user = PFUser.currentUser(){
                if let isPro = user["isPro"] as? Bool{
                    if isPro == true{
                        let draftsVC = DraftsTableViewController()
                        navigationController?.pushViewController(draftsVC, animated: true)
                    }else{
                        upgradeAlert()
                    }
                }else{
                    upgradeAlert()
                }
            }
        }else if indexPath == NSIndexPath(forRow: 1, inSection: 1){
            //Notifications
            let notificationVC = NotificationsTableViewController()
            navigationController?.pushViewController(notificationVC, animated: true)
        }else if indexPath == NSIndexPath(forRow: 2, inSection: 1){
            //User Search
            let userSearchVC = UserSearchTableViewController()
             navigationController?.pushViewController(userSearchVC, animated: true)
            
        }else if indexPath == NSIndexPath(forRow: 0, inSection: 2){
            //Store
            let storeVC = StoreViewController()
            navigationController?.pushViewController(storeVC, animated: true)
        }else if indexPath == NSIndexPath(forRow: 1, inSection: 2){
            //Report Issue
            let emailVC = MFMailComposeViewController()
            emailVC.mailComposeDelegate = self
            emailVC.setSubject("Idea Muscle Report / Inquiry")
            emailVC.navigationBar.tintColor = redColor
            emailVC.setToRecipients(["support@ideamuscle.me"])
            self.presentViewController(emailVC, animated: true, completion: nil)
        }else if indexPath == NSIndexPath(forRow: 2, inSection: 2){
            //EULA
            let eulaVC = EulaViewController()
            self.presentViewController(eulaVC, animated: true, completion: nil)
        }else if indexPath == NSIndexPath(forRow: 0, inSection: 3){
            //Idea Muscle Orientation
            let welcomeVC = WelcomeViewController()
            navigationController?.presentViewController(welcomeVC, animated: true, completion: nil)
        }else if indexPath == NSIndexPath(forRow: 1, inSection: 3){
            //Sign Out
            let signOutAlert: UIAlertController = UIAlertController(title: "Confirm Sign Out", message: "Are you sure you want to Sign Out?", preferredStyle: .Alert)
            signOutAlert.view.tintColor = redColor
            signOutAlert.view.backgroundColor = oneFiftyGrayColor
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            }
            signOutAlert.addAction(cancelAction)
            
            let signOutAction: UIAlertAction = UIAlertAction(title: "Sign Out", style: .Default, handler: { (action) -> Void in
                logout()
            })
            signOutAlert.addAction(signOutAction)
            self.presentViewController(signOutAlert, animated: true, completion: nil)
        }
    }
    
    func upgradeAlert(){
        let upgradeAlert: UIAlertController = UIAlertController(title: "Upgrade Required", message: "An upgrade to Pro is requird to view or save drafts.", preferredStyle: .Alert)
        upgradeAlert.view.tintColor = redColor
        upgradeAlert.view.backgroundColor = oneFiftyGrayColor
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        upgradeAlert.addAction(cancelAction)
        
        let goToStore: UIAlertAction = UIAlertAction(title: "Go To Store", style: .Default, handler: { (action) -> Void in
            let storeVC = StoreViewController()
            self.navigationController!.pushViewController(storeVC, animated: true)
            
        })
        
        upgradeAlert.addAction(goToStore)
        self.presentViewController(upgradeAlert, animated: true, completion: nil)
    }
    
    func upgradeUpvotedAlert(){
        let upgradeAlert: UIAlertController = UIAlertController(title: "Upgrade Required", message: "An upgrade to Pro is requird to view ideas you've upvoted.", preferredStyle: .Alert)
        upgradeAlert.view.tintColor = redColor
        upgradeAlert.view.backgroundColor = oneFiftyGrayColor
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        upgradeAlert.addAction(cancelAction)
        
        let goToStore: UIAlertAction = UIAlertAction(title: "Go To Store", style: .Default, handler: { (action) -> Void in
            let storeVC = StoreViewController()
            self.navigationController!.pushViewController(storeVC, animated: true)
            
        })
        
        upgradeAlert.addAction(goToStore)
        self.presentViewController(upgradeAlert, animated: true, completion: nil)
    }
    
}
