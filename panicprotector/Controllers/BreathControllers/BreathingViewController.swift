//
//  BreathingViewController.swift
//  panicprotector
//
//  Created by Jesús Franco García on 19/06/2021.
//

import UIKit
import AVFoundation
import CoreAudio
import BEMCheckBox

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
    
    @IBOutlet weak var viewBackHelp: UIView!
    @IBOutlet weak var viewHelp: UIView!
    @IBOutlet weak var viewHelp1: UIView!
    @IBOutlet weak var viewHelp2: UIView!
    @IBOutlet weak var viewHelp3: UIView!
    
    @IBOutlet weak var lblInstruction11: UILabel!
    @IBOutlet weak var lblInstruction12: UILabel!
    @IBOutlet weak var lblInstruction13: UILabel!
    @IBOutlet weak var lblInstruction21: UILabel!
    @IBOutlet weak var lblInstruction22: UILabel!
    @IBOutlet weak var lblInstruction23: UILabel!
    @IBOutlet weak var lblInstruction24: UILabel!
    @IBOutlet weak var lblInstruction31: UILabel!
    @IBOutlet weak var lblInstruction32: UILabel!
    @IBOutlet weak var lblInstruction33: UILabel!
    @IBOutlet weak var lblInstruction34: UILabel!
    @IBOutlet weak var lblInstruction35: UILabel!
    
    @IBOutlet weak var viewGenius: UIView!
    
    @IBOutlet weak var lblBreathMessages: UILabel!
    @IBOutlet weak var viewBreath1: UIView!
    @IBOutlet weak var viewBreath2: UIView!
    @IBOutlet weak var viewBreath3: UIView!
    @IBOutlet weak var viewBreath4: UIView!
    @IBOutlet weak var viewBreath5: UIView!
    
    @IBOutlet weak var viewBackCheckBox: UIView!
    @IBOutlet weak var checkBoxHelp: BEMCheckBox!
    @IBOutlet weak var lblCheckBox: UILabel!
    @IBOutlet weak var viewBackPreviousHelp: UIView!
    @IBOutlet weak var viewBackNextHelp: UIView!
    @IBOutlet weak var btnEndHelp: UIButton!
    
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
    var isCanCheck = false
    
    var currentHelp = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        customizeControls()
        checkHelp()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if recorder != nil {
            recorder.stop()
        }
    }
    
    private func startProcessBreath(){
        animateCloud(view: viewCloud1)
        animateCloud(view: viewCloud2)
        animationCountdown()
        limInfGeniusY = viewGenius.frame.maxY
    }
    
    private func customizeControls(){
        view.backgroundColor = .colorPrimaryDark
        viewBackground.backgroundColor = .colorPrimaryBackground
        toolbar.backgroundColor = .colorPrimaryBackground
        toolbar.showShadow()
        keypad.backgroundColor = .colorPrimaryDark
        viewInterrogation.backgroundColor = .colorPrimary
        viewInterrogation.roundBorderComplete()
        viewNextProcess.backgroundColor = .colorPrimary
        viewNextProcess.roundBorderComplete()
        viewBreath1.roundBorderComplete()
        viewBreath2.roundBorderComplete()
        viewBreath3.roundBorderComplete()
        viewBreath4.roundBorderComplete()
        viewBreath5.roundBorderComplete()
        viewBackDialogEndProcess.backgroundColor = .colorGreyTranslucid
        viewBackDialogEndProcess.isHidden = true
        viewCountdown.isHidden = true
        viewBackHelp.backgroundColor = .colorGreyTranslucid
        viewHelp2.isHidden = true
        viewHelp3.isHidden = true
        viewBackCheckBox.isHidden = true
        viewBackPreviousHelp.isHidden = true

        lblTitle.style(text: txtBreathing.uppercased(),
                       color: .colorPrimary,
                       size: 16,
                       fontName: fontArialRegular)
        lblBreathMessages.style(text: txtBreathAndBlow,
                                color: .white,
                                size: 20,
                                fontName: fontArialBold)
        lblBreathMessages.isHidden = true
        
        lblCheckBox.style(text: txtDontShowAgain,
                          color: .colorPrimaryDark,
                          size: 13,
                          fontName: fontArialBold)
        
        lblInstruction11.style(text: txtBreathInstruction11,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction12.style(text: txtBreathInstruction12,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction13.style(text: txtBreathInstruction13,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction21.style(text: txtBreathInstruction21,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction22.style(text: txtBreathInstruction22,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction23.style(text: txtBreathInstruction23,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction24.style(text: txtBreathInstruction24,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction31.style(text: txtBreathInstruction31,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction32.style(text: txtBreathInstruction32,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction33.style(text: txtBreathInstruction33,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction34.style(text: txtBreathInstruction34,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction35.style(text: txtBreathInstruction35,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        
        btnEndProcess.styleDialog(txt: txtEnd.uppercased())
        btnEndHelp.style(txt: txtContinue.uppercased(), size: 16)
        btnEndHelp.isHidden = true
        
        checkBoxHelp.customizeCheckBox()
    }
    
    private func checkHelp() {
        print("readNotShowBreathHelpPreferences(): \(readNotShowBreathHelpPreferences())")
        if readNotShowBreathHelpPreferences() {
            viewBackHelp.isHidden = true
            checkBoxHelp.on = true
            startProcessBreath()
        } else {
            viewBackHelp.isHidden = false
        }
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
        
        print("viewGenius.frame.minY: \(viewGenius.frame.minY)")
        print("viewGenius.frame.maxY: \(viewGenius.frame.maxY)")
        
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
    
    private func disableHelp(){
        viewInterrogation.backgroundColor = .lightGray
        btnHelp.isUserInteractionEnabled = false
    }
    
    @IBAction func actionCheckBox(_ sender: BEMCheckBox) {
        if sender.on {
            savePreferencesNotShowBreathHelp(notshow: true)
        } else {
            savePreferencesNotShowBreathHelp(notshow: false)
        }
    }
    
    @IBAction func actionPreviousHelp(_ sender: UIButton) {
        switch currentHelp {
        case 1:
            break
        case 2:
            viewHelp1.isHidden = false
            viewHelp2.isHidden = true
            viewBackPreviousHelp.isHidden = true
            currentHelp -= 1
        case 3:
            viewHelp2.isHidden = false
            viewHelp3.isHidden = true
            viewBackNextHelp.isHidden = false
            btnEndHelp.isHidden = true
            viewBackCheckBox.isHidden = true
            currentHelp -= 1
        default:
            break
        }
    }
    
    @IBAction func actionNextHelp(_ sender: UIButton) {
        switch currentHelp {
        case 1:
            viewHelp1.isHidden = true
            viewHelp2.isHidden = false
            viewBackPreviousHelp.isHidden = false
            currentHelp += 1
        case 2:
            viewHelp2.isHidden = true
            viewHelp3.isHidden = false
            viewBackNextHelp.isHidden = true
            btnEndHelp.isHidden = false
            viewBackCheckBox.isHidden = false
            currentHelp += 1
        case 3:
            break
        default:
            break
        }
        
    }
    
    @IBAction func actionEndHelp(_ sender: UIButton) {
        viewBackHelp.isHidden = true
        disableHelp()
        startProcessBreath()
    }

    @IBAction func actionHelp(_ sender: Any) {
        viewBackHelp.isHidden = false
    }
    
    @IBAction func actionNextProcess(_ sender: UIButton) {
        nextProcess()
    }
    
    @IBAction func actionFinaliseProcess(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindBreath", sender: nil)
    }
}
