//
//  TransitionViewController.swift
//  panicprotector
//
//  Created by Jesús Franco García on 09/06/2021.
//

import UIKit


enum StateProcess {
    case heartbeats
    case breath
}

class TransitionViewController: UIViewController {

    var state = StateProcess.heartbeats

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .colorPrimaryDark
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkState()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func checkState() {
        if state == .heartbeats {
            performSegue(withIdentifier: "segueBreath", sender: nil)
            //performSegue(withIdentifier: "segueHeartBeats", sender: nil)
        } else {
            //dismiss(animated: true, completion: nil)
            performSegue(withIdentifier: "segueBreath", sender: nil)
        }
    }

    @IBAction func unwindFromHeartBeats(segue: UIStoryboardSegue) {
        state = StateProcess.breath
    }
    
    @IBAction func unwindFromBreath(segue: UIStoryboardSegue) {
        state = StateProcess.heartbeats
    }
}
