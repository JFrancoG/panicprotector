//
//  BreathingViewController.swift
//  panicprotector
//
//  Created by Jesús Franco García on 19/06/2021.
//

import UIKit
import AVFoundation
import CoreAudio

class BreathingViewController: UIViewController {
    
    @IBOutlet weak var toolbar: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewBackground: UIView!
    
    
    @IBOutlet weak var imgFloor: UIImageView!
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
    @IBOutlet weak var viewCountdown: UIView!
    
    @IBOutlet weak var lblCount: UILabel!
    
    @IBOutlet weak var viewBackDialogEndProcess: UIView!
    
    @IBOutlet weak var viewDialogEndProcess: UIView!
    @IBOutlet weak var lblContinue: UILabel!
    
    @IBOutlet weak var lblHeartBeatsScreen: UILabel!
    
    @IBOutlet weak var btnEndProcess: UIButton!
    
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()

    let THRESHOLD: Float = -18.0
    
    var limInfGeniusY: CGFloat = 500.0
    var limSupGeniusY: CGFloat = 205.0
    
    var orangePoints = 0
    
    var isBreathingOK = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        customizeControls()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        animateCloud(view: viewCloud1)
        animateCloud(view: viewCloud2)
        animationCountdown()
        limInfGeniusY = viewGenius.frame.maxY
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if recorder != nil {
            recorder.stop()
        }
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
        viewCountdown.isHidden = true

        lblTitle.textColor = .colorPrimary
        lblTitle.text = txtBreathing.uppercased()
        lblBreathMessages.text = txtBreathAndBlow
        lblBreathMessages.isHidden = true
 
        btnEndProcess.styleDialog(txt: txtEnd.uppercased())
    }
    
    private func animationCountdown() {
        let arrCount = ["3","2","1","GO!"]
        for i in 0...3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.0) {
                self.lblCount.text = arrCount[i]
                self.animationCountdownUp(view: self.viewCountdown)
            }
        }
    }
    
    private func animationCountdownUp(view: UIView){
        viewCountdown.isHidden = false
        let originalTransform = view.transform
        let scaledTransform = originalTransform.scaledBy(x: 8.0, y: 8.0)

        UIView.animate(withDuration: 0.8, animations: {
            view.transform = scaledTransform
        }, completion: {_ in
            self.animationCountdownDown(view: self.viewCountdown)
        })
    }
    
    private func animationCountdownDown(view: UIView){
        let originalTransform = view.transform
        let scaledTransform = originalTransform.scaledBy(x: 0.1, y: 0.1)
        UIView.animate(withDuration: TimeInterval(CGFloat(0.1)), delay: 0.1, animations: {
                view.transform = scaledTransform
        }, completion: { _ in
            self.viewCountdown.isHidden = true
            if self.lblCount.text == "GO!" {
                self.lblBreathMessages.isHidden = false
                self.setupAudio()
            }
        })
    }

    private func animateCloud(view: UIView){
        let modX = 1.0 + Float.random(in: -0.5...0.25)
        let modY = 1.0 + Float.random(in: -0.25...0.5)
        
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
    
    private func animateGenius(view: UIView, isBreathing: Bool){

        let originalTransform = view.transform
        var transY: CGFloat = 3.8
        if isBreathing {
            transY = -4.5
        } else if isBreathingOK {
            transY = 1.75
        } else {
            transY = 3.8
        }
        
        print("limSupGeniusY: \(limSupGeniusY)")
        print("limInfGeniusY: \(limInfGeniusY)")
        
        print("transY: \(transY)")
        
        print("iewGenius.frame.minY: \(viewGenius.frame.minY)")
        print("iewGenius.frame.maxY: \(viewGenius.frame.maxY)")
        
        if isBreathing {
            if viewGenius.frame.maxY + transY < limSupGeniusY {
                recorder.stop()
                lblBreathMessages.text = txtRest
                viewBackground.backgroundColor = .colorOrangeBreath
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                    self.viewBackground.backgroundColor = .colorPrimaryBackground
                }
                checkOrangePoint()
                isBreathingOK = true
                lblBreathMessages.text = txtRest
            } else {
                lblBreathMessages.text = txtBlow
                let translatedTransform = originalTransform.translatedBy(x: 0.0, y: transY)
                UIView.animate(withDuration: TimeInterval(CGFloat(0.1)), animations: {
                        view.transform = translatedTransform
                    })
            }
        } else {
            if viewGenius.frame.maxY + transY > limInfGeniusY {
                lblBreathMessages.text = txtBreathAndBlow
                if isBreathingOK {
                    recorder.record()
                    isBreathingOK = false
                }
            } else {
                let translatedTransform = originalTransform.translatedBy(x: 0.0, y: transY)
                UIView.animate(withDuration: TimeInterval(CGFloat(0.1)), animations: {
                        view.transform = translatedTransform
                    })
            }
        }
    }
    
    private func checkOrangePoint(){
        switch orangePoints {
        case 0:
            viewBreath1.backgroundColor = .colorOrangeBreath
        case 1:
            viewBreath2.backgroundColor = .colorOrangeBreath
        case 2:
            viewBreath3.backgroundColor = .colorOrangeBreath
        case 3:
            viewBreath4.backgroundColor = .colorOrangeBreath
        case 4:
            viewBreath5.backgroundColor = .colorOrangeBreath
        default:
            break
        }
        orangePoints += 1
        if orangePoints == 5 {
            nextProcess()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func setupAudio() {
        let url = getDocumentsDirectory().appendingPathComponent("record.caf")
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey:              kAudioFormatAppleIMA4,
            AVSampleRateKey:            44100.0,
            AVNumberOfChannelsKey:      2,
            AVEncoderBitRateKey:        12800,
            AVLinearPCMBitDepthKey:     16,
            AVEncoderAudioQualityKey:   AVAudioQuality.max.rawValue
        ]

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setActive(true)
            try recorder = AVAudioRecorder(url: url, settings: recordSettings)
        } catch {
            return
        }

        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        recorder.record()

        levelTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
    }
    
    @objc func levelTimerCallback() {
        recorder.updateMeters()

        let level = recorder.averagePower(forChannel: 0)

        if level > THRESHOLD {
            print("******************************* LEVEL: \(level)")
            animateGenius(view: viewGenius, isBreathing: true)
        } else {
            print("LEVEL: \(level)")
            animateGenius(view: viewGenius, isBreathing: false)
        }
    }
    
    private func nextProcess(){
        if recorder != nil {
            recorder.stop()
        }
        levelTimer.invalidate()
        viewBackDialogEndProcess.isHidden = false
    }
    

    @IBAction func actionHelp(_ sender: Any) {
    }
    
    @IBAction func actionNextProcess(_ sender: UIButton) {
        nextProcess()
    }
    
    @IBAction func actionFinaliseProcess(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindBreath", sender: nil)
    }
}
