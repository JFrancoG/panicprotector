//
//  TermsViewController.swift
//  panicprotector
//
//  Created by Jesús Franco García on 9/9/21.
//

import UIKit
import BEMCheckBox


class TermsViewController: UIViewController {
    
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var lblTerms1: UILabel!
    @IBOutlet weak var lblTerms2: UILabel!
    @IBOutlet weak var lblTerms3: UILabel!
    @IBOutlet weak var lblTerms4: UILabel!
    
    @IBOutlet weak var lblTermsBase: UILabel!
    @IBOutlet weak var lblTermsUse: UILabel!
    @IBOutlet weak var lblPrivacyPolicy: UILabel!
    @IBOutlet weak var btnTermsOfUse: UIButton!
    @IBOutlet weak var btnPrivacyPolicy: UIButton!
    
    @IBOutlet weak var checkBoxTerms: BEMCheckBox!
    @IBOutlet weak var lblAcceptTermsText: UILabel!
    
    @IBOutlet weak var btnAcceptTerms: UIButton!
    
    @IBOutlet weak var constrainHeightContentScroll: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customizeControls()
        if readAcceptTermsPreferences() {
            checkBoxTerms.on = true
            btnAcceptTerms.style(txt: txtAccept.uppercased())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let acceptY = btnAcceptTerms.frame.maxY
        let heightContent = acceptY + getFloatStatusBarHeight() + 40
        let height = max(getFloatHeightDevice() - getFloatStatusBarHeight(), heightContent)
        constrainHeightContentScroll.constant = height
        scroll.contentSize = CGSize(width: scroll.contentSize.width, height: heightContent)
        //lblPrivacyPolicy.addBottomBorderWithColor(color: .colorOrangeBreath, thickness: 1)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func customizeControls() {
        // views
        view.backgroundColor = .colorPrimaryDark
        viewContent.backgroundColor = .colorPrimaryBackground
        
        // checkBox
        checkBoxTerms.customizeCheckBox()
        
        // labels
        lblTerms1.style(text: txtTerms1,
                        color: .colorPrimaryDark,
                        size: 14,
                        fontName: fontArialRegular)
        lblTerms2.style(text: txtTerms2,
                        color: .colorPrimaryDark,
                        size: 14,
                        fontName: fontArialBold)
        lblTerms3.style(text: txtTerms3,
                        color: .colorPrimaryDark,
                        size: 14,
                        fontName: fontArialRegular)
        lblTerms4.style(text: txtTerms4,
                        color: .colorPrimaryDark,
                        size: 14,
                        fontName: fontArialBold)
        lblTermsBase.style(text: txtTermsUsePrivacyPolicy,
                           color: .lightGray,
                           size: 16,
                           fontName: fontArialRegular)
        lblTermsUse.style(text: txtTermsOfUse,
                          color: .colorPrimaryDark,
                          size: 16,
                          fontName: fontArialRegular)
        lblPrivacyPolicy.style(text: txtPrivacyPolicy,
                               color: .colorPrimaryDark,
                               size: 16,
                               fontName: fontArialRegular)
        lblAcceptTermsText.style(text: txtAcceptTerms,
                                 color: .colorPrimaryDark,
                                 size: 14,
                                 fontName: fontArialBold)

        // buttons
        btnAcceptTerms.disableStyle(txt: txtToContinue.uppercased())
        btnTermsOfUse.setTitle("", for: .normal)
        btnPrivacyPolicy.setTitle("", for: .normal)
        
    }
    
    @IBAction func actionCkeckTerms(_ sender: BEMCheckBox) {
        if sender.on {
            btnAcceptTerms.style(txt: txtToContinue.uppercased())
            savePreferencesAcceptTerms(acceptTerms: true)
        } else {
            btnAcceptTerms.disableStyle(txt: txtToContinue.uppercased())
            savePreferencesAcceptTerms(acceptTerms: false)
        }
    }
    
    @IBAction func actionShowTermsOfUse(_ sender: Any) {
        openURL(strUrl: urlTermsOfUse)
    }
    
    @IBAction func actionShowPrivacyPolicy(_ sender: Any) {
        openURL(strUrl: urlPrivacyPolicy)
    }
    
    @IBAction func actionStart(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindStart", sender: nil)
    }
    
}
