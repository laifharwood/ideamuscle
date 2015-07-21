//
//  TopicAndIdeaContainerViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/16/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class LeaderboardViewController: UIViewController {
    
    let tableSelectionSC = UISegmentedControl()
    
    let friendsVC = FriendsLeaderboardTableViewController()
    let worldVC = WorldLeaderboardTableViewController()
    let upgradeVC = UpgradeToProViewController()
    let tableSelectionFrame = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.title = "Leaderboards"
        
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
        
        //MARK: - Table Selection Frame Config
        tableSelectionFrame.frame = CGRectMake(0, navigationController!.navigationBar.frame.maxY, self.view.frame.width, 30)
        tableSelectionFrame.backgroundColor = oneFiftyGrayColor
        self.view.addSubview(tableSelectionFrame)
        
        //Table Selection Segmented Control
        tableSelectionSC.insertSegmentWithTitle("Friends", atIndex: 0, animated: false)
        tableSelectionSC.insertSegmentWithTitle("World", atIndex: 1, animated: false)
        tableSelectionSC.selectedSegmentIndex = 0
        tableSelectionSC.frame = CGRectMake(5, 5, tableSelectionFrame.frame.width - 10, 20)
        tableSelectionSC.tintColor = UIColor.whiteColor()
        tableSelectionSC.backgroundColor = seventySevenGrayColor
        tableSelectionSC.layer.borderColor = UIColor.whiteColor().CGColor
        tableSelectionSC.layer.cornerRadius = 4
        //customSC.layer.masksToBounds = true
        tableSelectionSC.addTarget(self, action: "changeTableSelection:", forControlEvents: .ValueChanged)
        tableSelectionFrame.addSubview(tableSelectionSC)
        
        
        if let user = PFUser.currentUser(){
            if let isPro = user["isPro"] as? Bool{
                if isPro == true{
                    activeViewController = friendsVC
                }else{
                    activeViewController = upgradeVC
                }
            }else{
                activeViewController = upgradeVC
            }
        }
        
        

    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
    }
    
    
    private var activeViewController: UIViewController? {
        didSet {
            removeInactiveViewController(oldValue)
            updateActiveViewController()
        }
    }
    
    private func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if let inActiveVC = inactiveViewController {
            // call before removing child view controller's view from hierarchy
            inActiveVC.willMoveToParentViewController(nil)
            
            inActiveVC.view.removeFromSuperview()
            
            // call after removing child view controller's view from hierarchy
            inActiveVC.removeFromParentViewController()
        }
    }
    
    private func updateActiveViewController() {
        if let activeVC = activeViewController {
            // call before adding child view controller's view as subview
            addChildViewController(activeVC)
            
            activeVC.view.frame = CGRectMake(0, tableSelectionFrame.frame.maxY, self.view.frame.width, self.view.frame.height - 143)
            
            self.view.addSubview(activeVC.view)
            
            // call before adding child view controller's view as subview
            activeVC.didMoveToParentViewController(self)
        }
    }
    
    func composeOriginal(sender: UIButton!){
        
        //composeOriginalGlobal(self)
        composeFromDetail(self, nil, true)
        
    }
    
    func changeTableSelection(sender: UISegmentedControl){
        
        if let user = PFUser.currentUser(){
            if let isPro = user["isPro"] as? Bool{
                if isPro == true{
                    if sender.selectedSegmentIndex == 0{
                        activeViewController = friendsVC
                    }else{
                        activeViewController = worldVC
                    }
                }else{
                    activeViewController = upgradeVC
                }
            }else{
                activeViewController = upgradeVC
            }
        }
        

        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
