//
//  StartViewController.swift
//  panicprotector
//
//  Created by Jesús Franco García on 30/04/2021.
//

import UIKit

class StartViewController: UIViewController {
    
    
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        savePreferencesPulseLevel(level: -1)
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
    

    private func customizeControls() {
        
        view.backgroundColor = .colorPrimaryDark
        
        lblTerms.style(text: txtTermsUsePrivacyPolicy,
                       color: .colorGreyTranslucid,
                       size: 14,
                       fontName: fontArialRegular)

        btnStart.style(txt: txtStart.uppercased())
        
    }

    @IBAction func actionStart(_ sender: UIButton) {
        performSegue(withIdentifier: "segueTransition", sender: nil)
    }

    @IBAction func actionTerms(_ sender: UIButton) {
        performSegue(withIdentifier: "segueTerms", sender: nil)
    }
    
    @IBAction func unwindTerms(segue: UIStoryboardSegue) {
        lblTerms.addBottomBorderWithColor(color: .colorGreyTranslucid, thickness: 1)
    }
    
}
