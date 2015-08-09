////
////  WelcomeViewController.swift
////  IdeaMuscle
////
////  Created by Laif Harwood on 8/3/15.
////  Copyright (c) 2015 Parse. All rights reserved.
////
//
import UIKit

class WelcomeViewController: UIViewController {
    
    var pageOne = PageOneWelcomeViewController()
    var pageTwo = PageTwoWelcomeViewController()
    var pageThree = PageThreeWelcomeViewController()
    var activeViewController = UIViewController()
    var oneCircle = UIView()
    var twoCircle = UIView()
    var threeCircle = UIView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        pageOne.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 50)
        pageTwo.view.frame = CGRectMake(self.view.frame.width, 0, self.view.frame.width, self.view.frame.height - 50)
        pageThree.view.frame = CGRectMake(self.view.frame.width * 2, 0, self.view.frame.width, self.view.frame.height - 50)
        addChildViewController(pageOne)
        self.view.addSubview(pageOne.view)
        addChildViewController(pageTwo)
        self.view.addSubview(pageTwo.view)
        addChildViewController(pageThree)
        self.view.addSubview(pageThree.view)
        activeViewController = pageOne
        
        
        let swipeRight = UISwipeGestureRecognizer()
        swipeRight.addTarget(self, action: "swipedRight:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.addTarget(self, action: "swipedLeft:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        let bottomContainer = UIView(frame: CGRectMake(0, self.view.frame.height - 50, self.view.frame.width, 50))
        bottomContainer.backgroundColor = twoHundredGrayColor
        self.view.addSubview(bottomContainer)
        
        oneCircle.frame = CGRectMake(self.view.frame.width/3 - 2.5, bottomContainer.frame.height/2 - 2.5, 5, 5)
        twoCircle.frame = CGRectMake(self.view.frame.width/2 - 2.5, bottomContainer.frame.height/2 - 2.5, 5, 5)
        threeCircle.frame = CGRectMake(self.view.frame.width/3 * 2 - 2.5, bottomContainer.frame.height/2 - 2.5, 5, 5)
        
        oneCircle.backgroundColor = fiftyGrayColor
        twoCircle.backgroundColor = oneFiftyGrayColor
        threeCircle.backgroundColor = oneFiftyGrayColor
        
        oneCircle.layer.cornerRadius = 2.5
        twoCircle.layer.cornerRadius = 2.5
        threeCircle.layer.cornerRadius = 2.5
        
        oneCircle.layer.masksToBounds = true
        twoCircle.layer.masksToBounds = true
        threeCircle.layer.masksToBounds = true
        
        bottomContainer.addSubview(oneCircle)
        bottomContainer.addSubview(twoCircle)
        bottomContainer.addSubview(threeCircle)
        
        let skipButton = UIButton(frame: CGRectMake(bottomContainer.frame.maxX - 45, bottomContainer.frame.height/2 - 15, 40, 30))
        skipButton.setTitle("Skip", forState: .Normal)
        skipButton.addTarget(self, action: "skip:", forControlEvents: .TouchUpInside)
        skipButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        skipButton.setTitleColor(fiftyGrayColor, forState: .Highlighted)
        skipButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 13)
        bottomContainer.addSubview(skipButton)
    }
    
    func changeViewFrame(vC: UIViewController, xValue: CGFloat){
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            vC.view.frame = CGRectMake(xValue, 0, self.view.frame.width, self.view.frame.height - 50)
        })
    }
    
    func skip(sender: UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func swipedRight(sender: UISwipeGestureRecognizer){
        if activeViewController == pageOne{
            
        }else if activeViewController == pageTwo{
            changeViewFrame(pageOne, xValue: 0)
            changeViewFrame(pageTwo, xValue: self.view.frame.width)
            changeViewFrame(pageThree, xValue: self.view.frame.width * 2)
            activeViewController = pageOne
            oneCircle.backgroundColor = fiftyGrayColor
            twoCircle.backgroundColor = oneFiftyGrayColor
        }else if activeViewController == pageThree{
            changeViewFrame(pageOne, xValue: -self.view.frame.width)
            changeViewFrame(pageTwo, xValue: 0)
            changeViewFrame(pageThree, xValue: self.view.frame.width)
            activeViewController = pageTwo
            threeCircle.backgroundColor = oneFiftyGrayColor
            twoCircle.backgroundColor = fiftyGrayColor
        }
    }
    
    func swipedLeft(sender: UISwipeGestureRecognizer){
        if activeViewController == pageOne{
            changeViewFrame(pageOne, xValue: -self.view.frame.width)
            changeViewFrame(pageTwo, xValue: 0)
            changeViewFrame(pageThree, xValue: self.view.frame.width)
            activeViewController = pageTwo
            oneCircle.backgroundColor = oneFiftyGrayColor
            twoCircle.backgroundColor = fiftyGrayColor
        }else if activeViewController == pageTwo{
            changeViewFrame(pageOne, xValue: -self.view.frame.width * 2)
            changeViewFrame(pageTwo, xValue: -self.view.frame.width)
            changeViewFrame(pageThree, xValue: 0)
            activeViewController = pageThree
            twoCircle.backgroundColor = oneFiftyGrayColor
            threeCircle.backgroundColor = fiftyGrayColor
        }else if activeViewController == pageThree{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
