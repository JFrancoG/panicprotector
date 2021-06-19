//
//  BreathingViewController.swift
//  panicprotector
//
//  Created by Jesús Franco García on 19/06/2021.
//

import UIKit

class BreathingViewController: UIViewController {
    
    @IBOutlet weak var toolbar: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewBackground: UIView!
    
    
    @IBOutlet weak var keypad: UIView!
    @IBOutlet weak var viewInterrogation: UIView!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var viewNextProcess: UIView!
    @IBOutlet weak var btnNextProcess: UIButton!
    
    @IBOutlet weak var viewGenius: UIView!
    
    @IBOutlet weak var lblBreathMessages: UILabel!
    @IBOutlet weak var viewBreath1: UIView!
    @IBOutlet weak var viewBreath2: UIView!
    @IBOutlet weak var viewBreath3: UIView!
    @IBOutlet weak var viewBreath4: UIView!
    @IBOutlet weak var viewBreath5: UIView!
    
    @IBOutlet weak var viewCloud1: UIView!
    @IBOutlet weak var viewCloud2: UIView!
    
    @IBOutlet weak var viewBackDialogEndProcess: UIView!
    
    @IBOutlet weak var viewDialogEndProcess: UIView!
    @IBOutlet weak var lblContinue: UILabel!
    
    @IBOutlet weak var lblHeartBeatsScreen: UILabel!
    
    @IBOutlet weak var btnEndProcess: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customizeControls()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        animateCloud(view: viewCloud1)
        animateCloud(view: viewCloud2)
    }
    
    private func customizeControls(){
        view.backgroundColor = .colorPrimaryDark
        viewBackground.backgroundColor = .colorPrimaryBackground
        toolbar.backgroundColor = .colorPrimaryBackground
        toolbar.showShadow()
        keypad.backgroundColor = .colorPrimary
        viewInterrogation.backgroundColor = .colorPrimaryDark
        viewInterrogation.roundBorderComplete()
        viewNextProcess.backgroundColor = .colorPrimaryDark
        viewNextProcess.roundBorderComplete()
        viewBreath1.roundBorderComplete()
        viewBreath2.roundBorderComplete()
        viewBreath3.roundBorderComplete()
        viewBreath4.roundBorderComplete()
        viewBreath5.roundBorderComplete()
        viewBackDialogEndProcess.backgroundColor = .colorGreyTranslucid
        viewBackDialogEndProcess.isHidden = true

        lblTitle.textColor = .colorPrimary
        lblTitle.text = txtBreathing.uppercased()
 
        btnEndProcess.styleDialog(txt: txtFinalise.uppercased())
    }
    

    private func animateCloud(view: UIView){
        let modX = 1.0 + Float.random(in: -0.3...0.15)
        let modY = 1.0 + Float.random(in: -0.15...0.3)
        
        let duration = Float.random(in: 25.0...70.0)
        
        let transX = 500.0 + view.frame.width
        let transY = Float.random(in: -50.0...50.0)
        
        let originalTransform = view.transform
        let scaledTransform = originalTransform.scaledBy(x: CGFloat(modX), y: CGFloat(modY))
            let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: CGFloat(transX), y: CGFloat(transY))
        UIView.animate(withDuration: TimeInterval(CGFloat(duration)), animations: {
                view.transform = scaledAndTranslatedTransform
            })
    }

    @IBAction func actionHelp(_ sender: Any) {
    }
    
    @IBAction func actionNextProcess(_ sender: UIButton) {
        
        viewBackDialogEndProcess.isHidden = false
    }
    
    @IBAction func actionFinaliseProcess(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindBreath", sender: nil)
    }
}
