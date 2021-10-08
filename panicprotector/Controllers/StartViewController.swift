//
//  StartViewController.swift
//  panicprotector
//
//  Created by Jesús Franco García on 30/04/2021.
//

import UIKit
import StoreKit

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
    
    
    var prodSubscriptions = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchProducts()
        savePreferencesPulseLevel(level: -1)
        savePreferencesPulse(bpm: -1)
        customizeControls()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        lblTerms.addBottomBorderWithColor(color: .colorGreyTranslucid, thickness: 1)
        if !readAcceptTermsPreferences(){
            performSegue(withIdentifier: "segueTerms", sender: nil)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    private func checkSubscribed() {
        if !readIsSubscribedPreferences() {
            viewBackSubscriptionDialog.isHidden = false
        } else {
            performSegue(withIdentifier: "segueTransition", sender: nil)
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
        lblMonthlyPrice.style(text: "6,99 € / mes",
                              color: .white,
                              size: 24,
                              fontName: fontArialBold)
        lblYearlyPrice.style(text: "49,99 € / año",
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
        btnCancel.setTitle("", for: .normal)
        btnBuyMonthly.setTitle("", for: .normal)
        btnBuyYearly.setTitle("", for: .normal)
    }
    
    private func purchaseSubscription(product: ProductSubscriptionID) {
        guard let productToPurchase = prodSubscriptions.filter({ $0.productIdentifier == product.rawValue }).first else { return }
        
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: productToPurchase)
            paymentQueue.add(payment)
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
        checkSubscribed()
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
                break
            case .purchased, .restored:
                savePreferencesIsSubscribed(isSubscribed: true)
                paymentQueue.finishTransaction(transaction)
                paymentQueue.remove(self)
            case .failed, .deferred:
                paymentQueue.finishTransaction(transaction)
                paymentQueue.remove(self)
            default:
                paymentQueue.finishTransaction(transaction)
                paymentQueue.remove(self)
            }
        }
    }
}

