//
//  SharedCode.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/2/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

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
let transparentColor : UIColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0)

let sixtyThreeGrayColor : UIColor = UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 1)

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

func cropToSquare(image originalImage: UIImage) -> UIImage {
    // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
    let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage)!
    
    // Get the size of the contextImage
    let contextSize: CGSize = contextImage.size
    
    let posX: CGFloat
    let posY: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
    if contextSize.width > contextSize.height {
        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        width = contextSize.height
        height = contextSize.height
    } else {
        posX = 0
        posY = ((contextSize.height - contextSize.width) / 2)
        width = contextSize.width
        height = contextSize.width
    }
    
    let rect: CGRect = CGRectMake(posX, posY, width, height)
    
    // Create bitmap image from context using the rect
    let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
    
    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)!
    
    return image
}

func imageToGray(image: UIImage) -> UIImage{
    
    let imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
    
    let colorSpace = CGColorSpaceCreateDeviceGray()
    let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.None.rawValue)
    let context =  CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height), 8, 0, colorSpace, bitmapInfo)
    
    CGContextDrawImage(context, imageRect, image.CGImage)
    
    let imageRef = CGBitmapContextCreateImage(context)
    
    let newImage = UIImage(CGImage: CGImageCreateCopy(imageRef))
    
    return newImage!
}

func abbreviateNumber(num: NSNumber) -> NSString {
    var ret: NSString = ""
    let abbrve: [String] = ["K", "M", "B"]
    
    var floatNum = num.floatValue
    
    if floatNum > 1000 {
        
        for i in 0..<abbrve.count {
            let size = pow(10.0, (Float(i) + 1.0) * 3.0)
            //println("\(size)   \(floatNum)")
            if (size <= floatNum) {
                let num = floatNum / size
                let str = floatToString(num)
                ret = NSString(format: "%@%@", str, abbrve[i])
            }
        }
    } else {
        ret = NSString(format: "%d", Int(floatNum))
    }
    
    return ret
}

func floatToString(val: Float) -> NSString {
    var ret = NSString(format: "%.1f", val)
    var c = ret.characterAtIndex(ret.length - 1)
    
    while c == 48 {
        ret = ret.substringToIndex(ret.length - 1)
        c = ret.characterAtIndex(ret.length - 1)
        
        
        if (c == 46) {
            ret = ret.substringToIndex(ret.length - 1)
        }
    }
    return ret
}

func upvoteGlobal(idea: PFObject, shouldUpvote: Bool, button: UIButton){
    if shouldUpvote == false{
        //Remove Upvote
        if let user = PFUser.currentUser(){
            idea.removeObject(user, forKey: "usersWhoUpvoted")
            idea.incrementKey("numberOfUpvotes", byAmount: -1)
            idea.saveInBackgroundWithBlock({ (success, error) -> Void in
                if error != nil{
                    println("error saving idea object for remove upvote")
                    println("Error: \(error!.userInfo)")
                }
            })
            
            var upvoteObjectQuery = PFQuery(className: "Upvote")
            upvoteObjectQuery.whereKey("userWhoUpvoted", equalTo: user)
            upvoteObjectQuery.whereKey("ideaUpvoted", equalTo: idea)
            
            var upvoteObject = PFObject(className: "Upvote")
            
            upvoteObjectQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                if error != nil{
                    println("error in getting Upvote Object for remove upvote")
                    println("Error: \(error!.userInfo)")
                    
                }else{
                    upvoteObject = object! as PFObject
                    upvoteObject.deleteInBackgroundWithBlock({ (success, error) -> Void in
                        if error != nil{
                            println("error deleting upvote object")
                            println("Error: \(error!.userInfo)")
                        }
                    })
                }
                let ideaOwner = idea["owner"] as! PFUser
                var leaderboardQuery = PFQuery(className: "Leaderboard")
                leaderboardQuery.whereKey("userPointer", equalTo: ideaOwner)
                leaderboardQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                    
                    if error == nil{
                        var leaderboardObject = PFObject(className: "Leaderboard")
                        leaderboardObject = object!
                        leaderboardObject.incrementKey("numberOfUpvotes", byAmount: -1)
                        leaderboardObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if error != nil{
                                println("error saving leaderboard object for remove upvote")
                                println("Error: \(error!.userInfo)")
                            }
                        })
                    }else{
                        println("error finding leaderboard object to downvote")
                        println("Error: \(error!.userInfo)")
                    }
                })
            })
            
            let title = idea["numberOfUpvotes"] as! Int
            let numberString = abbreviateNumber(title)
            button.setTitle(numberString as String, forState: .Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            button.tintColor = UIColor.whiteColor()
            
        }

    }else{
        //Add Upvote
        if let user = PFUser.currentUser(){
            idea.addObject(user, forKey: "usersWhoUpvoted")
            idea.incrementKey("numberOfUpvotes")
            idea.saveInBackgroundWithBlock({ (success, error) -> Void in
                if error != nil{
                    
                    println("error saving idea object for upvote")
                    println("Error: \(error!.userInfo)")
                }
            })
            
            var upvoteObject = PFObject(className: "Upvote")
            upvoteObject.setObject(user, forKey: "userWhoUpvoted")
            upvoteObject.setObject(idea, forKey: "ideaUpvoted")
            upvoteObject.ACL?.setPublicWriteAccess(true)
            upvoteObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                if error != nil{
                    
                    println("error saving upvote object for upvote")
                    println("Error: \(error!.userInfo)")
                }
            })
    
            let ideaOwner = idea["owner"] as! PFUser
            var leaderboardQuery = PFQuery(className: "Leaderboard")
            leaderboardQuery.whereKey("userPointer", equalTo: ideaOwner)
            leaderboardQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                
                if error == nil{
                    var leaderboardObject = PFObject(className: "Leaderboard")
                    leaderboardObject = object!
                    leaderboardObject.incrementKey("numberOfUpvotes", byAmount: 1)
                    leaderboardObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if error != nil{
                            
                            println("error saving leaderboard object for upvote")
                            println("Error: \(error!.userInfo)")
                        }
                    })
                }else{
                    println("error getting leaderboardOjbect to upvote")
                    println("Error: \(error!.userInfo)")
                }
            })
            
            let title = idea["numberOfUpvotes"] as! Int
            let numberString = abbreviateNumber(title)
            button.setTitle(numberString as String, forState: .Normal)
            button.setTitleColor(redColor, forState: .Normal)
            button.tintColor = redColor

        }
    }
}

func followGlobal(userToFollow: PFUser, shouldFollow: Bool){
    if shouldFollow == false{
        //Unfollow
        if let currentUser = PFUser.currentUser(){
            let relation = currentUser.relationForKey("following")
            relation.removeObject(userToFollow)
            currentUser.saveInBackground()
        }
    }else{
        //Follow
        if let currentUser = PFUser.currentUser(){
            let relation = currentUser.relationForKey("following")
            relation.addObject(userToFollow)
            currentUser.saveInBackground()
        }
    }
}

func getAvatar(user: PFUser, imageView: UIImageView?, parseImageView: PFImageView?){
    var avatarFile = PFFile()
    var image = UIImage()
    var wasSuccessful = Bool()
    let defaultImage = UIImage(named: "IdeaMuscleLogoWhiteBackground.png")
    if user["avatar"] != nil{
        avatarFile = user["avatar"] as! PFFile
        avatarFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
            if error == nil{
                image = UIImage(data: data!)!
                image = cropToSquare(image: image)
                image = image.convertToGrayScale()
                if imageView != nil{
                imageView!.image = image
                }
                if parseImageView != nil{
                    parseImageView!.image = image
                }
            }else{
                println("could not get avatar")
                println("Error: \(error!.userInfo)")
                if imageView != nil{
                    imageView!.image = defaultImage
                }
                if parseImageView != nil{
                    parseImageView!.image = defaultImage
                }
            }
        })

    }else{
        if imageView != nil{
            imageView!.image = defaultImage
        }
        if parseImageView != nil{
            parseImageView!.image = defaultImage
        }
    }
}




