//
//  StartViewController.swift
//  panicprotector
//
//  Created by Jesús Franco García on 30/04/2021.
//

import UIKit
import StoreKit
import SwiftyStoreKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    
    @IBOutlet weak var viewBackSubscriptionDialog: UIView!
    @IBOutlet weak var viewSubscriptions: UIView!
    @IBOutlet weak var lblSubscriptionTrial: UILabel!
    @IBOutlet weak var viewBackMonthlySub: UIView!
    @IBOutlet weak var lblMonthlySub: UILabel!
    @IBOutlet weak var lblMonthlyPrice: UILabel!
    @IBOutlet weak var viewBackYearlySub: UIView!
    @IBOutlet weak var lblYearlySub: UILabel!
    @IBOutlet weak var lblYearlyPrice: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnBuyMonthly: UIButton!
    @IBOutlet weak var btnBuyYearly: UIButton!
    @IBOutlet weak var lblSaving: UILabel!
    
    @IBOutlet weak var lblExhaleAnxiety: UILabel!
    @IBOutlet weak var lblCalmYourAnxiety: UILabel!
    
    @IBOutlet weak var lblCancelSubscription: UILabel!
    @IBOutlet weak var lblVariationPrices: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
//    var prodSubscriptions = [SKProduct]()
//    let paymentQueue = SKPaymentQueue.default()
    
    enum StateSub {
        case purchased
        case notPurchased
        case expired
        case error
    }
    
    var stateMonthlySub = StateSub.error
    var stateYearlySub = StateSub.error
    
    var subsCont = 0
    var hasSubscription = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        savePreferencesPulseLevel(level: -1)
        savePreferencesPulse(bpm: -1)
        customizeControls()

        productsInfo()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        scroll.contentSize = CGSize(width: self.view.frame.width, height: 700)
        lblTerms.addBottomBorderWithColor(color: .colorGreyTranslucid, thickness: 1)
        if !readAcceptTermsPreferences(){
            performSegue(withIdentifier: "segueTerms", sender: nil)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    private func productsInfo() {
        activityIndicator.startAnimating()
        for i in 0..<subsIDs[0].count {
            SwiftyStoreKit.retrieveProductsInfo(Set(arrayLiteral: subsIDs[0][i])) { result in
                if let product = result.retrievedProducts.first {
                    let id = product.productIdentifier
                    self.verifySubscription(prodId: id)
                    print("Product: \(product.localizedTitle), price: \(product.localizedPrice!)")
                    if id == subsIDs[0][0] { // monthly
                        let monthly = String.localizedStringWithFormat(
                            txtSubsMonthlyDinamic,
                            product.localizedPrice!)
                            self.lblMonthlySub.style(text: product.localizedTitle,
                                                color: .white,
                                                size: 18,
                                                fontName: fontArialBold)
                            self.lblMonthlyPrice.style(text: monthly,
                                                       color: .white,
                                                       size: 24,
                                                       fontName: fontArialBold)
                    } else if id == subsIDs[0][1] {// yearly
                        let savingDbl = Double(truncating: product.price) / 12.0
                        let savingStr = savingDbl.formatTwoDecimals(unity: "")
                        let yearly = String.localizedStringWithFormat(
                            txtSubsYearlyDinamic,
                            product.localizedPrice!)
                        let saving = String.localizedStringWithFormat(
                            txtSavingDinamic,
                            savingStr)
                            
                        self.lblYearlySub.style(text: product.localizedTitle,
                                                color: .white,
                                                size: 18,
                                                fontName: fontArialBold)
                        self.lblYearlyPrice.style(text: yearly,
                                                  color: .white,
                                                  size: 24,
                                                  fontName: fontArialBold)
                        self.lblSaving.style(text: saving,
                                             color: .white,
                                             size: 13,
                                             fontName: fontArialBold)
                    }
                } else if let invalidProductId = result.invalidProductIDs.first {
                    print("Invalid product identifier: \(invalidProductId)")
                } else {
                    print("Error: \(String(describing: result.error))")
                }
            }
        }
    }
    

    private func purchaseSubscription(id: String) {
        SwiftyStoreKit.purchaseProduct(id, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let product):
                // fetch content from your server, then:
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                let id = product.productId
                print("Purchase Success: \(id)")
                self.verifySubscription(prodId: id)

            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }
        
    }
    
    
    private func verifySubscription(prodId: String) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            self.activityIndicator.stopAnimating()
            self.btnBuyMonthly.isUserInteractionEnabled = true
            self.btnBuyYearly.isUserInteractionEnabled = true
            switch result {
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: prodId,
                    inReceipt: receipt)
                    
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(prodId) is valid until \(expiryDate)\n\(items)\n")
                    self.viewBackSubscriptionDialog.isHidden = true
                    self.hasSubscription = true
                case .expired(let expiryDate, let items):
                    print("\(prodId) is expired since \(expiryDate)\n\(items)\n")
                case .notPurchased:
                    print("The user has never purchased \(prodId)")
                }

            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    
    private func verifySubscriptions() {
        
    }
    
    
    
    private func restoreSubscriptions() {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
    

//
//    private func verifySubs(completionHandler: @escaping (StateSub) -> Void) {
//        print("verifySubs")
//        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
//        let prods: Set<String> = [ProductSubscriptionID.monthlySubscription.rawValue,
//                                ProductSubscriptionID.yearlySubscription.rawValue]
//        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
//            print("verifyReceipt")
//            switch result {
//            case .success(let receipt):
//                let purchaseResult = SwiftyStoreKit.verifySubscriptions(
//                    productIds: prods,
//                    inReceipt: receipt)
//                switch purchaseResult {
//                case .purchased(let expiryDate, let items):
//                    //print("\(prods) is valid until \(expiryDate)\n\(items)\n")
//                    //print("\(prodId) is valid until \(expiryDate)\n")
//                    print("is valid until \(expiryDate)\n")
//                    completionHandler(.purchased)
//                case .expired(let expiryDate, let items):
//                    //print("\(prodId) is expired since \(expiryDate)\n\(items)\n")
//                    //print("\(prodId) is expired since \(expiryDate)\n\n")
//                    print("is expired since \(expiryDate)\n")
//                    completionHandler(.expired)
//                case .notPurchased:
////                    print("The user has never purchased \(prodId)")
//                    print("The user has never purchased")
//                    completionHandler(.notPurchased)
//                }
//            case .error(let error):
//                print("Receipt verification failed: \(error)")
//                completionHandler(.error)
//            }
//        }
//    }


    private func customizeControls() {
        activityIndicator.style()
        
        view.backgroundColor = .colorPrimaryDark
        viewBackground.backgroundColor = .colorPrimaryBackground
        viewBackSubscriptionDialog.backgroundColor = .colorPrimaryBackground
        viewBackSubscriptionDialog.isHidden = false
        viewBackMonthlySub.backgroundColor = .colorPrimary
        viewBackMonthlySub.round(cornerRadius: radius8)
        viewBackYearlySub.backgroundColor = .colorPrimary
        viewBackYearlySub.round(cornerRadius: radius8)
        viewSubscriptions.backgroundColor = .colorPrimaryDark
        
        lblTerms.style(text: txtTermsUsePrivacyPolicy,
                       color: .colorGreyTranslucid,
                       size: 14,
                       fontName: fontArialRegular)
        lblSubscriptionTrial.style(text: txt7DaysTrial,
                                    color: .white,
                                    size: 18,
                                    fontName: fontArialBold)
        lblMonthlySub.style(text: txtMonthlySubscription,
                            color: .white,
                            size: 18,
                            fontName: fontArialBold)
        lblYearlySub.style(text: txtYearlySubscription,
                            color: .white,
                            size: 18,
                            fontName: fontArialBold)
        lblMonthlyPrice.style(text: txtSubsMonthly,
                              color: .white,
                              size: 24,
                              fontName: fontArialBold)
        lblYearlyPrice.style(text: txtSubsYearly,
                              color: .white,
                              size: 24,
                              fontName: fontArialBold)
        lblSaving.style(text: txtSaving,
                        color: .white,
                        size: 13,
                        fontName: fontArialBold)
        lblExhaleAnxiety.style(text: txtExhaleAnxiety,
                               color: .colorPrimaryDark,
                               size: 16,
                               fontName: fontArialBold)
        lblCalmYourAnxiety.style(text: txtCalmYourAnxiety,
                                 color: .colorPrimary,
                                 size: 14,
                                 fontName: fontArialBold)
        lblCancelSubscription.style(text: txtCancelSubscription,
                                    color: .colorPrimary,
                                    size: 14,
                                    fontName: fontArialRegular)
        lblVariationPrices.style(text: txtVariationPrices,
                                 color: .colorPrimary,
                                 size: 12,
                                 fontName: fontArialRegular)

        btnStart.style(txt: txtStart.uppercased())
        btnCancel.setTitle("", for: .normal)
        btnBuyMonthly.setTitle("", for: .normal)
        btnBuyMonthly.isUserInteractionEnabled = false
        btnBuyYearly.setTitle("", for: .normal)
        btnBuyYearly.isUserInteractionEnabled = false
    }
    
    @IBAction func actionBuyMonthlySubscription(_ sender: Any) {
        purchaseSubscription(id: ProductSubscriptionID.monthlySubscription.rawValue)
    }
    
    @IBAction func actionBuyYearlySubscription(_ sender: Any) {
        purchaseSubscription(id: ProductSubscriptionID.yearlySubscription.rawValue)
    }
    
    @IBAction func actionCancelDialogSubscription(_ sender: Any) {
        viewBackSubscriptionDialog.isHidden = true
    }
    
    @IBAction func actionStart(_ sender: UIButton) {
        if hasSubscription {
            performSegue(withIdentifier: "segueTransition", sender: nil)
        } else {
            viewBackSubscriptionDialog.isHidden = false
        }
    }

    @IBAction func actionTerms(_ sender: UIButton) {
        performSegue(withIdentifier: "segueTerms", sender: nil)
    }
    
    @IBAction func unwindTerms(segue: UIStoryboardSegue) {
        lblTerms.addBottomBorderWithColor(color: .colorGreyTranslucid, thickness: 1)
    }
    
}
//
//extension StartViewController: SKProductsRequestDelegate {
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        for product in response.products {
//            print("product.productIdentifier: \(product.productIdentifier)")
//            print("product.price: \(product.price)")
//            print("product.priceLocale: \(product.priceLocale)")
//            print("product.localizedTitle: \(product.localizedTitle)")
//            print("product.localizedDescription: \(product.localizedDescription)")
//            prodSubscriptions.append(product)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            //self.showSubscriptionPrice()
//        }
//    }
//}
//
//extension StartViewController: SKPaymentTransactionObserver {
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction in transactions {
//            print("SKPaymentTransactionObserver")
//            switch transaction.transactionState {
//            case .purchasing:
//                print("PURCHASINGG")
//                btnStart.isUserInteractionEnabled = false
//                viewBackSubscriptionDialog.isHidden = true
//                break
//            case .purchased, .restored:
//                print("PURCHASED OR RESTORED")
//                paymentQueue.finishTransaction(transaction)
//                paymentQueue.remove(self)
//                hasSubscription = true
//                verifySubscriptions()
//                viewBackSubscriptionDialog.isHidden = true
//            case .failed, .deferred:
//                print("FAILEDD")
//                print("purchase error : \(transaction.error?.localizedDescription ?? "")")
//                paymentQueue.finishTransaction(transaction)
//                paymentQueue.remove(self)
//                btnStart.isUserInteractionEnabled = true
//                fetchProducts()
//            default:
//                print("UNKNOWNN")
//                paymentQueue.finishTransaction(transaction)
//                paymentQueue.remove(self)
//            }
//        }
//    }
//}

