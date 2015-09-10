//
//  AppDelegate.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit

import Bolts
import Parse
import FBSDKCoreKit
import ParseCrashReporting


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    

    var window: UIWindow?
    //var tabBarController: UITabBarController?

    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UAAppReviewManager.setAppID("1018374250")
        UAAppReviewManager.setReviewMessage("If you like IdeaMuscle then please rate it. If you don't like IdeaMuscle then let us know how we can make it better at support@ideamuscle.me .... or go write a scathing pointless review if you think that will make you feel better." + "😉")
        UAAppReviewManager.setCancelButtonTitle("No way! I hate this app!")
        UAAppReviewManager.showPromptIfNecessary()

        
        
        Hoko.setupWithToken("e0348143635d4116ba4b3e31d6d47088376aefab")
        Hoko.deeplinking().mapRoute("ideas/:ideaId", toTarget: { (deeplink: HOKDeeplink) -> Void in
            
            if PFUser.currentUser() != nil{
            let ideaDetailVC = IdeaDetailViewController()
            let dict = deeplink.routeParameters as! [NSObject : String]
            let ideaId = dict["ideaId"]
            let query = PFQuery(className: "Idea")
            query.includeKey("owner")
            query.includeKey("topicPointer")
            //query.includeKey("usersWhoUpvoted")
            query.getObjectInBackgroundWithId(ideaId!, block: { (idea, error) -> Void in
                if error == nil{
                    let activeIdea = idea! as PFObject
                    ideaDetailVC.activeIdea = activeIdea
                    var topic = PFObject(className: "Topic")
                    topic = activeIdea["topicPointer"] as! PFObject
                    ideaDetailVC.activeTopic = topic
                    HOKNavigation.pushViewController(ideaDetailVC, animated: true)
                }else{
                    
                }
            })
            }
        })
        
        Hoko.deeplinking().mapRoute("topics/:topicId", toTarget: { (deeplink: HOKDeeplink) -> Void in
            if PFUser.currentUser() != nil{
                let topicDetailVC = TopicsDetailViewController()
                let dict = deeplink.routeParameters as! [NSObject : String]
                let topicId = dict["topicId"]
                let query = PFQuery(className: "Topic")
                query.includeKey("creator")
                query.getObjectInBackgroundWithId(topicId!, block: { (topic, error) -> Void in
                    let activeTopic = topic! as PFObject
                    topicDetailVC.activeTopic = activeTopic
                    HOKNavigation.pushViewController(topicDetailVC, animated: true)
                })
                
            }
        })
        
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        //Parse.enableLocalDatastore()

        // ****************************************************************************
        // Uncomment this line if you want to enable Crash Reporting
        ParseCrashReporting.enable()
        //
        // Uncomment and fill in with your Parse credentials:
        Parse.setApplicationId("XfETALgT99bADjGNWoe4rPeRhDGhAbqAi5yzGsbQ",
            clientKey: "CQj3sFXoJfk90GxrVQLF1woSJ4YQxp8Ow0hcAG10")
        
        PFTwitterUtils.initializeWithConsumerKey("eCAQJjFpIIWbB5432mWLKRWAu", consumerSecret: "STcV6ellf3Pc7iT7rGukXgVqempvByt0HvfvtXX6HmURmspyBr")
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        //PFFacebookUtils.initializeFacebook()
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        // ****************************************************************************

        //PFUser.enableAutomaticUser()

        let defaultACL = PFACL();

        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)

        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)

        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.

            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes = UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
            application.registerForRemoteNotificationTypes(types)
        }
        
        var navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.whiteColor()
        if let titleFont = UIFont(name: "HelveticaNeue", size: 15){
            
            navigationBarAppearance.titleTextAttributes = [NSFontAttributeName: titleFont, NSForegroundColorAttributeName: UIColor.whiteColor()]
            
        }
        
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            openedFromNotification(remoteNotification as [NSObject : AnyObject])
        }
    
        navigationBarAppearance.barTintColor = fiftyGrayColor
        
        var navItemAppearance = UIBarButtonItem.appearance()
        
        navItemAppearance.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -200), forBarMetrics: UIBarMetrics.Default)
        
        window?.rootViewController = ViewController()
        
        return true
    }

    //--------------------------------------
    // MARK: - Push Notifications
    //--------------------------------------

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveEventually()
        
        PFPush.subscribeToChannelInBackground("", block: { (succeeded: Bool, error: NSError?) -> Void in
            if succeeded {
                //println("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
            } else {
                //println("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
            }
        })
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            //println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        //PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive{
            openedFromNotification(userInfo)
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }else if application.applicationState == UIApplicationState.Background{
            openedFromNotification(userInfo)
        }else if application.applicationState == UIApplicationState.Active{
            ++PFInstallation.currentInstallation().badge
        }
       
        PFInstallation.currentInstallation().saveEventually()
        
        updateMoreBadge(tabBarControllerK)
    }
    
    func openedFromNotification(userInfo: [NSObject : AnyObject]){
        if PFInstallation.currentInstallation().badge > 0{
            --PFInstallation.currentInstallation().badge
        }
        if let ideaId = userInfo["ideaId"] as? String{
            let idea = PFObject(withoutDataWithClassName: "Idea", objectId: ideaId)
            idea.fetchIfNeededInBackgroundWithBlock({ (object, error) -> Void in
                if error == nil{
                    let activeTopic = idea["topicPointer"] as! PFObject
                    activeTopic.fetchIfNeededInBackgroundWithBlock({ (object, error) -> Void in
                        if error == nil{
                            let ideaDetailVC = IdeaDetailViewController()
                            ideaDetailVC.activeIdea = idea
                            ideaDetailVC.activeTopic = activeTopic
                            
                            if let notificationId = userInfo["notificationId"] as? String{
                                let notification = PFObject(withoutDataWithClassName: "Notification", objectId: notificationId)
                                notification["hasRead"] = true
                                notification.saveEventually()
                            }
                            HOKNavigation.pushViewController(ideaDetailVC, animated: true)
                        }
                    })
                }
            })
        }
    }

    ///////////////////////////////////////////////////////////
    // Uncomment this method if you want to use Push Notifications with Background App Refresh
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    //     if application.applicationState == UIApplicationState.Inactive {
    //         PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    //     }
    // }

    //--------------------------------------
    // MARK: - Facebook SDK Integration
    //--------------------------------------

    ///////////////////////////////////////////////////////////
    // Uncomment this method if you are using Facebook
    ///////////////////////////////////////////////////////////
     func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
         //return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, session:PFFacebookUtils.session())
     }
}
