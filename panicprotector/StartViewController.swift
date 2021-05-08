//
//  StartViewController.swift
//  panicprotector
//
//  Created by Jesús Franco García on 30/04/2021.
//

import UIKit

class StartViewController: UIViewController {
    
    
    @IBOutlet weak var btnStart: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        customizeControls()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    

    private func customizeControls() {
        
        view.backgroundColor = .colorPrimaryDark
        
        btnStart.style(txt: txtStart.uppercased())
        
    }

}
