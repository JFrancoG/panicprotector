//
//  ResponseItem.swift
//  panicprotector
//
//  Created by Jesús Franco García on 5/12/21.
//

import Foundation

struct ResponseReceiptItems : Decodable {
    var response: [ReceiptItem]
    enum CodingKeys:String, Swift.CodingKey {
        case response = "response"
    }
}

struct ResponseReceiptItem : Decodable {
    var response: ReceiptItem
    enum CodingKeys:String, Swift.CodingKey {
        case response = "response"
    }
}

class ReceiptItem: Decodable {
    var productId: String
    var quantity: Int
    var transactionId: String
    var originalTransactionId: String
    var purchaseDate: String
    var originalPurchaseDate: String
    var webOrderLineItemId: String?
    var subscriptionExpirationDate: String?
    var cancellationDate: String?
    var isTrialPeriod: Bool
    var isInIntroOfferPeriod: Bool
    
    init?(productId: String,
          quantity: Int,
          transactionId: String,
          originalTransactionId: String,
          purchaseDate: String,
          originalPurchaseDate: String,
          webOrderLineItemId: String?,
          subscriptionExpirationDate: String?,
          cancellationDate: String?,
          isTrialPeriod: Bool,
          isInIntroOfferPeriod: Bool) {
        
        self.productId = productId
        self.quantity = quantity
        self.transactionId = transactionId
        self.originalTransactionId = originalTransactionId
        self.purchaseDate = purchaseDate
        self.originalPurchaseDate = originalPurchaseDate
        self.webOrderLineItemId = webOrderLineItemId
        self.subscriptionExpirationDate = subscriptionExpirationDate
        self.cancellationDate = cancellationDate
        self.isTrialPeriod = isTrialPeriod
        self.isInIntroOfferPeriod = isInIntroOfferPeriod
    }
}
