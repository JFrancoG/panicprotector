//
//  StartViewController.swift
//  panicprotector
//
//  Created by Jesús Franco García on 30/04/2021.
//

import UIKit

class StartViewController: UIViewController {
    
    
    @IBOutlet weak var btnStart: UIButton!
    
    @IBOutlet weak var btnTermsUsePrivacyPolicy: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        customizeControls()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    

    private func customizeControls() {
        
        view.backgroundColor = .colorPrimaryDark
        
        btnTermsUsePrivacyPolicy.setTitle(txtTermsUsePrivacyPolicy, for: .normal)
        btnStart.style(txt: txtStart.uppercased())
        
    }

    @IBAction func actionStart(_ sender: UIButton) {
        performSegue(withIdentifier: "segueMain", sender: nil)
    }
    
    
    @IBAction func actionTermsUsePrivacyPolicy(_ sender: UIButton) {
        performSegue(withIdentifier: "segueTermsUsePP", sender: nil)
    }
    
    
}
