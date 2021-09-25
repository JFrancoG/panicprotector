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
    case heartbeats2
    case end
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
        } else if state == .breath {
            performSegue(withIdentifier: "segueBreath", sender: nil)
        } else if state == .heartbeats2 {
            performSegue(withIdentifier: "segueHeartBeats", sender: nil)
        } else if state == .end {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func unwindFromHeartBeats(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindFromBreath(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueHeartBeats"{
            let destinationVC = segue.destination as! HeartBeatsViewController
            destinationVC.modalPresentationStyle = .fullScreen
            destinationVC.state = state
        } else if segue.identifier == "segueBreath"{
            let destinationVC = segue.destination as! BreathingViewController
            destinationVC.modalPresentationStyle = .fullScreen
            destinationVC.state = state
        }
    }
}
