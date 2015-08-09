//
//  PageOneWelcomeViewController.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 8/4/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class PageOneWelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        let topContainer = UIView(frame: CGRectMake(0, UIApplication.sharedApplication().statusBarFrame.height, self.view.frame.width, 75))
        topContainer.backgroundColor = fiftyGrayColor
        self.view.addSubview(topContainer)
        
        let title = UILabel(frame: CGRectMake(5, 5, self.view.frame.width - 10, topContainer.frame.height - 10))
        title.text = "What Is An Idea Muscle?"
        title.font = UIFont(name: "HelveticaNeue", size: 18)
        title.textColor = UIColor.whiteColor()
        title.textAlignment = NSTextAlignment.Center
        topContainer.addSubview(title)
        
        let textContainer = UIView(frame: CGRectMake(0, topContainer.frame.maxY, self.view.frame.width, self.view.frame.height - topContainer.frame.height - 50))
        textContainer.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(textContainer)
        
        let textView = UITextView(frame: CGRectMake(5, 5, textContainer.frame.width - 10, textContainer.frame.height - 10))
        textView.editable = false
        textView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0)
        textView.font = UIFont(name: "Avenir", size: 14)
        textView.text = "Welcome To IdeaMuscle! We are excited to have you and hope you are excited to build your idea muscle! If you don’t know what the idea muscle is then please read on. \n \nJust like your regular muscles need exercise to stay healthy, so does your mind.  If you don’t regularly exercise your mind it will become weak and will fail you when you need it most.  One way to exercise your mind is to build your \"idea muscle\".\n\n\"Idea muscle\" is a term coined by best selling author, entrepreneur, and investor James Altucher. James has lived an extraordinary and fascinating life and  he has developed a daily practice to help people be successful, happy, and productive.  One portion of the daily practice is coming up with at least 10 ideas a day on a subject. It doesn’t matter what the ideas are about, it could be business ideas, ways to help people, or how to make the world a better place...anything you want.  You will likely come up with a lot of bad ideas but over time your ideas will get better and after consistently doing this everyday, you will become an idea machine and a problem solving superhero of sorts! You will have come up with hundreds and then thousands of ideas.\n\n Then you will have the power to change your life and the lives of others because you will be overflowing with great ideas.  You will no longer be a victim of your circumstances because you will be able to figure out how to get what you want and as James puts it \"choose yourself\". \n\n To learn more about James and the idea muscle go to JamesAltucher.com."
        
        textContainer.addSubview(textView)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
