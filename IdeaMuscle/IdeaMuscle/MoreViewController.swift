//
//  MoreViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/5/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class MoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "More"
        
        //Right Compose Button
        let composeOriginalButton = UIButton()
        let composeOriginalImage = UIImage(named: "ComposeWhite.png")
        composeOriginalButton.setImage(composeOriginalImage, forState: .Normal)
        composeOriginalButton.frame = CGRectMake(self.view.frame.width - 38, 25, 24.7, 25)
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
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - tabBarController!.tabBar.frame.height)
        self.view.addSubview(tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 3
    }
    
    func composeOriginal(sender: UIButton!){
        
        //composeOriginalGlobal(self)
        composeFromDetail(self, nil, true)
        
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
         var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

        // Configure the cell...
        if indexPath.row == 0 {
            cell.textLabel!.text = "Store"
        }else if indexPath.row == 1{
            cell.textLabel!.text = "Drafts"
        }else if indexPath.row == 2{
            cell.textLabel!.text = "Your Ideas"
        }
        

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.row == 0{
            let storeVC = StoreViewController()
            navigationController?.pushViewController(storeVC, animated: true)
        }else if indexPath.row == 1{
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
            
        }else if indexPath.row == 2{
            let userIdeasVC = UserIdeasTableViewController()
            navigationController?.pushViewController(userIdeasVC, animated: true)
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
    
}
