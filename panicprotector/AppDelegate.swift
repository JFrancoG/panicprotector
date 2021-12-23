//
//  AppDelegate.swift
//  panicprotector
//
//  Created by Jesús Franco García on 28/04/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
//            for purchase in purchases {
//                switch purchase.transaction.transactionState {
//                case .purchased, .restored:
//                    print("purchased or restored")
//                    if purchase.needsFinishTransaction {
//                        print("purchased or restored finish")
//                        // Deliver content from server, then:
//                        SwiftyStoreKit.finishTransaction(purchase.transaction)
//                    }
//                    // Unlock content
//                case .purchasing:
//                    print("purchasing")
//                    break // do nothing
//                case .failed, .deferred:
//                    print("failed or deferred")
//                    break // do nothing
//                @unknown default:
//                    break
//                }
//            }
//        }
//        
//        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
//            return true
//        }
        
        return true
    }




}

