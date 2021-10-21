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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var prodSubscriptions = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    enum StateSub {
        case purchased
        case notPurchased
        case expired
        case error
    }
    
    var checkedSubs = 0
    var hasSubscription = false
    var hasVerified = false
    
    var stateMonthlySub = StateSub.error
    var stateYearlySub = StateSub.error
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        savePreferencesPulseLevel(level: -1)
        savePreferencesPulse(bpm: -1)
        customizeControls()
        fetchProducts()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        verifySubs()
        lblTerms.addBottomBorderWithColor(color: .colorGreyTranslucid, thickness: 1)
        if !readAcceptTermsPreferences(){
            performSegue(withIdentifier: "segueTerms", sender: nil)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    private func verifySubs() {
        activityIndicator.startAnimating()
        verifySub(prodId: ProductSubscriptionID.yearlySubscription.rawValue) { state in
            self.stateYearlySub = state
            self.checkedSubs += 1
            self.checkStates()
        }
        verifySub(prodId: ProductSubscriptionID.monthlySubscription.rawValue) { state in
            self.stateMonthlySub = state
            self.checkedSubs += 1
            self.checkStates()
        }
    }
    
    private func checkStates() {
        if checkedSubs > 1 {
            activityIndicator.stopAnimating()
            btnStart.isUserInteractionEnabled = true
            if stateYearlySub == .purchased || stateMonthlySub == .purchased {
                hasSubscription = true
                hasVerified = true
                // habilitamos botón comenzar y ocultamos dialogos si hace falta o activityIndicator
            } else if stateYearlySub == .error || stateMonthlySub == .error {
                hasVerified = false
                // Lanzar alert con problem
            } else {
                hasVerified = true
                viewBackSubscriptionDialog.isHidden = false
                // Mostrar dialogo de compra
                // si queremos mostrar fecha de cuando expiró hay que capturarla
            }
            checkedSubs = 0
        }
    }
    
    private func verifySub(prodId: String, completionHandler: @escaping (StateSub) -> Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                //print("receipt:\(receipt)")
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: prodId,
                    inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    //print("\(prodId) is valid until \(expiryDate)\n\(items)\n")
                    print("\(prodId) is valid until \(expiryDate)\n")
                    completionHandler(.purchased)
                case .expired(let expiryDate, let items):
                    //print("\(prodId) is expired since \(expiryDate)\n\(items)\n")
                    print("\(prodId) is expired since \(expiryDate)\n\n")
                    completionHandler(.expired)
                case .notPurchased:
                    print("The user has never purchased \(prodId)")
                    completionHandler(.notPurchased)
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completionHandler(.error)
            }
        }
    }
    
    private func fetchProducts() {
        let productSet: Set = [ProductSubscriptionID.monthlySubscription.rawValue,
                             ProductSubscriptionID.yearlySubscription.rawValue]
        let request = SKProductsRequest(productIdentifiers: productSet)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }

    private func customizeControls() {
        activityIndicator.style()
        
        view.backgroundColor = .colorPrimaryDark
        viewBackground.backgroundColor = .colorPrimaryBackground
        viewBackSubscriptionDialog.backgroundColor = .colorPrimaryBackground
        viewBackSubscriptionDialog.isHidden = true
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
        lblMonthlyPrice.style(text: "",
                              color: .white,
                              size: 24,
                              fontName: fontArialBold)
        lblYearlyPrice.style(text: "",
                              color: .white,
                              size: 24,
                              fontName: fontArialBold)
        lblSaving.style(text: txtSaving,
                        color: .white,
                        size: 14,
                        fontName: fontArialBold)
        lblExhaleAnxiety.style(text: txtExhaleAnxiety,
                               color: .colorPrimaryDark,
                               size: 16,
                               fontName: fontArialBold)
        lblCalmYourAnxiety.style(text: txtCalmYourAnxiety,
                                 color: .colorPrimary,
                                 size: 16,
                                 fontName: fontArialBold)
        lblCancelSubscription.style(text: txtCancelSubscription,
                                    color: .colorPrimary,
                                    size: 14,
                                    fontName: fontArialRegular)

        btnStart.style(txt: txtStart.uppercased())
        btnStart.isUserInteractionEnabled = false
        btnCancel.setTitle("", for: .normal)
        btnBuyMonthly.setTitle("", for: .normal)
        btnBuyYearly.setTitle("", for: .normal)
    }
    
    private func purchaseSubscription(product: ProductSubscriptionID) {
        guard let productToPurchase = prodSubscriptions.filter({ $0.productIdentifier == product.rawValue }).first else { return }
        
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: productToPurchase)
            paymentQueue.add(payment)
        } else {
            // lanzar alert "User unable to make payments"
        }
    }
    
    private func showSubscriptionPrice() {
        for subscription in prodSubscriptions {
            if subscription.productIdentifier == ProductSubscriptionID.monthlySubscription.rawValue {
                lblMonthlyPrice.text = String.localizedStringWithFormat(txtSubsMonthly, Double(truncating: subscription.price).formatTwoDecimals(unity: "€"))
            }
            if subscription.productIdentifier == ProductSubscriptionID.yearlySubscription.rawValue {
                lblYearlyPrice.text = String.localizedStringWithFormat(txtSubsYearly, Double(truncating: subscription.price).formatTwoDecimals(unity: "€"))
            }
        }
    }
    
    @IBAction func actionBuyMonthlySubscription(_ sender: Any) {
        purchaseSubscription(product: .monthlySubscription)
    }
    
    @IBAction func actionBuyYearlySubscription(_ sender: Any) {
        purchaseSubscription(product: .yearlySubscription)
    }
    
    @IBAction func actionCancelDialogSubscription(_ sender: Any) {
        viewBackSubscriptionDialog.isHidden = true
    }
    
    @IBAction func actionStart(_ sender: UIButton) {
        if hasSubscription {
            performSegue(withIdentifier: "segueTransition", sender: nil)
        } else {
            if hasVerified {
                viewBackSubscriptionDialog.isHidden = false
            } else {
                verifySubs()
            }
        }
    }

    @IBAction func actionTerms(_ sender: UIButton) {
        performSegue(withIdentifier: "segueTerms", sender: nil)
    }
    
    @IBAction func unwindTerms(segue: UIStoryboardSegue) {
        lblTerms.addBottomBorderWithColor(color: .colorGreyTranslucid, thickness: 1)
    }
    
}

extension StartViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            print("product.productIdentifier: \(product.productIdentifier)")
            print("product.price: \(product.price)")
            print("product.priceLocale: \(product.priceLocale)")
            print("product.localizedTitle: \(product.localizedTitle)")
            print("product.localizedDescription: \(product.localizedDescription)")
            prodSubscriptions.append(product)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showSubscriptionPrice()
        }
    }
}

extension StartViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                print("PURCHASINGG")
                btnStart.isUserInteractionEnabled = false
                viewBackSubscriptionDialog.isHidden = true
                break
            case .purchased, .restored:
                print("PURCHASED OR RESTORED")
                paymentQueue.finishTransaction(transaction)
                paymentQueue.remove(self)
                hasVerified = false
                verifySubs()
                viewBackSubscriptionDialog.isHidden = true
            case .failed, .deferred:
                print("FAILEDD")
                print("purchase error : \(transaction.error?.localizedDescription ?? "")")
                paymentQueue.finishTransaction(transaction)
                paymentQueue.remove(self)
                btnStart.isUserInteractionEnabled = true
                fetchProducts()
            default:
                print("UNKNOWNN")
                paymentQueue.finishTransaction(transaction)
                paymentQueue.remove(self)
            }
        }
    }
}

