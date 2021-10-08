//
//  StoreService.swift
//  panicprotector
//
//  Created by Jesús Franco García on 3/10/21.
//

import Foundation
import StoreKit

class StoreService: NSObject {
    private override init() {}
    static let shared = StoreService()
    
    func getProducts() {
        let productSet: Set = [ProductSubscriptionID.monthlySubscription.rawValue,
                             ProductSubscriptionID.yearlySubscription.rawValue]
        let request = SKProductsRequest(productIdentifiers: productSet)
        request.delegate = self
        request.start()
    }
}

extension StoreService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            print("prod: \(product.localizedTitle)")
            print("prodID: \(product.productIdentifier)")
        }
    }
}
