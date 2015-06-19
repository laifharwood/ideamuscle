//
//  TopicAndIdeaContainerViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/16/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class TopicAndIdeaContainerViewController: UIViewController {
    
    let periodSC = UISegmentedControl()
    let tableSelectionSC = UISegmentedControl()
    
    let ideaTodayVC = IdeaTodayTableViewController()
    let topicTodayVC = TopicTodayTableViewController()
    
    let periodFrame = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.title = "Top Ideas"
        
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
        let tableSelectionFrame = UIView()
        tableSelectionFrame.frame = CGRectMake(0, navigationController!.navigationBar.frame.maxY, self.view.frame.width, 30)
        tableSelectionFrame.backgroundColor = oneFiftyGrayColor
        self.view.addSubview(tableSelectionFrame)
        
        //Table Selection Segmented Control
        tableSelectionSC.insertSegmentWithTitle("Ideas", atIndex: 0, animated: false)
        tableSelectionSC.insertSegmentWithTitle("Topics", atIndex: 1, animated: false)
        tableSelectionSC.selectedSegmentIndex = 0
        tableSelectionSC.frame = CGRectMake(5, 5, tableSelectionFrame.frame.width - 10, 20)
        tableSelectionSC.tintColor = UIColor.whiteColor()
        tableSelectionSC.backgroundColor = seventySevenGrayColor
        tableSelectionSC.layer.borderColor = UIColor.whiteColor().CGColor
        tableSelectionSC.layer.cornerRadius = 4
        //customSC.layer.masksToBounds = true
        tableSelectionSC.addTarget(self, action: "changeTableSelection:", forControlEvents: .ValueChanged)
        tableSelectionFrame.addSubview(tableSelectionSC)
        
        //MARK: - Period Frame Config
        
        periodFrame.frame = CGRectMake(0, tableSelectionFrame.frame.maxY, self.view.frame.width, 30)
        periodFrame.backgroundColor = oneFiftyGrayColor
        self.view.addSubview(periodFrame)
        
        //Period Segmented Control
        periodSC.insertSegmentWithTitle("Today", atIndex: 0, animated: false)
        periodSC.insertSegmentWithTitle("7", atIndex: 1, animated: false)
        periodSC.insertSegmentWithTitle("30", atIndex: 2, animated: false)
        periodSC.insertSegmentWithTitle("All", atIndex: 3, animated: false)
        periodSC.selectedSegmentIndex = 0
        periodSC.frame = CGRectMake(5, 5, periodFrame.frame.width - 10, 20)
        periodSC.tintColor = UIColor.whiteColor()
        periodSC.backgroundColor = seventySevenGrayColor
        periodSC.layer.borderColor = UIColor.whiteColor().CGColor
        periodSC.layer.cornerRadius = 4
        //customSC.layer.masksToBounds = true
        periodSC.addTarget(self, action: "changePeriodView:", forControlEvents: .ValueChanged)
        periodFrame.addSubview(periodSC)
        
        activeViewController = ideaTodayVC

        // Do any additional setup after loading the view.
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
            
            activeVC.view.frame = CGRectMake(0, periodFrame.frame.maxY, self.view.frame.width, self.view.frame.height - 143)
            
            self.view.addSubview(activeVC.view)
            
            // call before adding child view controller's view as subview
            activeVC.didMoveToParentViewController(self)
        }
    }
    
    
    
    
    func composeOriginal(sender: UIButton!){
        
        isNewTopic = true
        
        let composeTopicVC = ComposeTopicViewController()
        
        self.presentViewController(composeTopicVC, animated: true, completion: nil)
        
    }
    
    func changeTableSelection(sender: UISegmentedControl){
        
        
        
        if sender.selectedSegmentIndex == 0{
            
            self.title = "Top Ideas"
            
            activeViewController = ideaTodayVC
            
            
        }else{
            
            self.title = "Top Topics"
            
            activeViewController = topicTodayVC
            
        }
    }
    
    func changePeriodView(sender: UISegmentedControl){
        
        println(sender.selectedSegmentIndex)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
