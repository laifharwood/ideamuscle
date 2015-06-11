//
//  SharedCode.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/2/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Colors

let twitterColor : UIColor = UIColor(red: 0/255, green: 172/255, blue: 237/255, alpha: 1)
let orangeColor : UIColor = UIColor(red: 242/255, green: 123/255, blue: 53/255, alpha: 1)
let darkBrownColor : UIColor = UIColor(red: 72/255, green: 61/255, blue: 50/255, alpha: 1)
let tealColor : UIColor = UIColor(red: 3/255, green: 165/255, blue: 165/255, alpha: 1)
let customGrayColor : UIColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)

let redColor : UIColor = UIColor(red: 175/255, green: 0/255, blue: 0/255, alpha: 1)


let seventySevenGrayColor : UIColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
let twoHundredGrayColor : UIColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
let fiftyGrayColor : UIColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
let oneFiftyGrayColor : UIColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
let tenGrayColor : UIColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)


//MARK: - Images
let smallLogo = UIImage(named: "smallLogo.png")



extension UIImage {
    
    func convertToGrayScaleNoAlpha() -> CGImageRef {
        let colorSpace = CGColorSpaceCreateDeviceGray();
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.None.rawValue)
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, colorSpace, bitmapInfo)
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage)
        return CGBitmapContextCreateImage(context)
    }
    
    
    /**
    Return a new image in shades of gray + alpha
    */
    func convertToGrayScale() -> UIImage {
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.Only.rawValue)
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, nil, bitmapInfo)
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
        let mask = CGBitmapContextCreateImage(context)
        return UIImage(CGImage: CGImageCreateWithMask(convertToGrayScaleNoAlpha(), mask), scale: scale, orientation:imageOrientation)!
    }
}


