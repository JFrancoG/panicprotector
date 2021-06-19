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
    
    @IBOutlet weak var btnNextProcess: UIButton!
    @IBOutlet weak var containerHeartBeats: UIView!
    
    @IBOutlet weak var containerBreathing: UIView!
    
    
    var state = StateProcess.heartbeats
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        showHeartBeatsProcess()
        //showBreathProcess()

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
        state = .breath
        containerHeartBeats.isHidden = true
        containerBreathing.isHidden = false
        lblTitle.text = txtBreathing.uppercased()
    }
    
    private func showHeartBeatsProcess(){
        state = .heartbeats
        containerHeartBeats.isHidden = false
        containerBreathing.isHidden = true
        lblTitle.text = txtHeartBeats.uppercased()
        let pulseVC = children.first(where: { $0 is HeartBeatsViewController }) as! HeartBeatsViewController
        pulseVC.startProcessHeartBeats()
    }
    
    private func showAlertHeartBeats(){
        
    }
    
    private func startProcessBreath(){
        let pulseVC = children.first(where: { $0 is HeartBeatsViewController }) as! HeartBeatsViewController
        pulseVC.resetValues()
        showBreathProcess()
    }
    
    
    @IBAction func actionNextProcess(_ sender: UIButton) {
        if state == .heartbeats {
            startProcessBreath()
        } else {
            // Poner en respiracion todo como al principio e iniciar las pulsaciones
            showHeartBeatsProcess()
        }
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
    

    
}

extension MainViewController: HeartBeatsProtocol {
    func endProcessPulse() {
        // mostrar el dialog de exito
        // y cuando lo cierre
        showBreathProcess()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showBreathProcess()
        }
    }
}

