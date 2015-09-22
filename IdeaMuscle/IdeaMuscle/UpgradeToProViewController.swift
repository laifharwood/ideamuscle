////
////  UpgradeToProViewController.swift
////  IdeaMuscle
////
////  Created by Laif Harwood on 7/17/15.
////  Copyright (c) 2015 Parse. All rights reserved.
////
//
//import UIKit
//
//class UpgradeToProViewController: UIViewController {
//    
//    
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let label = UILabel(frame: CGRectMake(self.view.frame.width/2 - 125, 100, 250, 100))
//        label.text = "An upgrade to IdeaMuscle Pro is required to access this view."
//        label.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
//        label.numberOfLines = 0
//        label.textAlignment = NSTextAlignment.Center
//        self.view.addSubview(label)
//        
//        let button = UIButton(frame: CGRectMake(self.view.frame.width/2 - 75, label.frame.maxY + 5, 150, 30))
//        button.setTitle("Go To Store", forState: .Normal)
//        button.backgroundColor = redColor
//        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 13)
//        button.addTarget(self, action: "goToStore:", forControlEvents: .TouchUpInside)
//        button.layer.cornerRadius = 3
//        self.view.addSubview(button)
//
//        // Do any additional setup after loading the view.
//    }
//    
////    func goToStore(sender: UIButton){
////        let storeVC = StoreViewController()
////        self.navigationController?.pushViewController(storeVC, animated: true)
////    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
