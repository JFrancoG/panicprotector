//
//  MainViewController.swift
//  panicprotector
//
//  Created by Jesús Franco García on 23/05/2021.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var toolbar: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var keypad: UIView!
    
    @IBOutlet weak var viewInterrogation: UIView!
    
    @IBOutlet weak var viewNextProcess: UIView!
    
    @IBOutlet weak var containerHeartBeats: UIView!
    
    @IBOutlet weak var containerBreathing: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showHeartBeatsProcess()

        customizeControls()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    private func customizeControls(){
        view.backgroundColor = .colorPrimaryDark
        viewBackground.backgroundColor = .colorPrimaryBackground
        toolbar.showShadow()
        keypad.backgroundColor = .colorPrimary
        viewInterrogation.roundBorderComplete()
        viewNextProcess.roundBorderComplete()

        
        lblTitle.textColor = .colorPrimary
        lblTitle.text = txtHeartBeats.uppercased()
        
        
    }
    
    private func showBreathProcess(){
        containerHeartBeats.isHidden = true
        containerBreathing.isHidden = false
    }
    
    private func showHeartBeatsProcess(){
        containerHeartBeats.isHidden = false
        containerBreathing.isHidden = true
    }
    
    private func showAlertHeartBeats(){
        
    }

    private func toggleTorch(on: Bool){
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        if device.hasTorch {
            do{
                if device.isTorchAvailable {
                    try device.lockForConfiguration()
                    if on {
                        device.torchMode = .on
                    } else {
                        device.torchMode = .off
                    }
                    device.unlockForConfiguration()
                } else {
                    print("flash no disponible en este momento")
                }
            }catch{
                print("El flash no puede ser usado en este momento")
            }
        } else {
            print("El dispositivo no dispone de flash")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerBreath" {
            let destinationVC = segue.destination as! BreathViewController
            destinationVC.delegate = self
        }else
            if segue.identifier == "containerHeartBeats" {
            let destinationVC = segue.destination as! HeartBeatsViewController
            destinationVC.delegate = self
        }
    }
    
    
}

extension MainViewController: HeartBeatsProtocol {
    func endProcess() {
        // mostrar el dialog de exito
        dismiss(animated: true, completion: nil)
    }
}

extension MainViewController: BreathProtocol {
    func prueba() {
        
    }
}
