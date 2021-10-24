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
    @IBOutlet weak var constrainWidthGenius: NSLayoutConstraint!
    @IBOutlet weak var constrainHeightGenius: NSLayoutConstraint!
    
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
    @IBOutlet weak var constrainWidthCloud1: NSLayoutConstraint!
    @IBOutlet weak var constrainHeightCloud1: NSLayoutConstraint!
    @IBOutlet weak var constrainWidthCloud2: NSLayoutConstraint!
    @IBOutlet weak var constrainHeightCloud2: NSLayoutConstraint!
    
    @IBOutlet weak var viewCountdown: UIView!
    @IBOutlet weak var imgCountdown: UIImageView!
    @IBOutlet weak var constrainWidthCountdown: NSLayoutConstraint!
    @IBOutlet weak var constrainHeightCountdown: NSLayoutConstraint!
    
    @IBOutlet weak var viewBackDialogEndProcess: UIView!
    @IBOutlet weak var viewDialogEndProcess: UIView!
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var lblHeartBeatsScreen: UILabel!
    @IBOutlet weak var btnEndProcess: UIButton!
    
    @IBOutlet weak var viewBackPermissionDenied: UIView!
    @IBOutlet weak var viewPermission: UIView!
    @IBOutlet weak var lblPermissionTitle: UILabel!
    @IBOutlet weak var lbl1Permission: UILabel!
    @IBOutlet weak var lbl2Permission: UILabel!
    @IBOutlet weak var btnExit: UIButton!
    @IBOutlet weak var btnSettings: UIButton!
    
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()

    let THRESHOLD: Float = -18.0
    
    var limInfGeniusY: CGFloat = 500.0
    var limSupGeniusY: CGFloat = 185.0
    var weight = 1.0
    var widthGenius = 159.0
    var heightGenius = 180.0
    var widthCountdown = 22.0
    var heightCountdown = 8.0
    var widthCloud = 170.0
    var heightCloud = 80.0
    
    var orangePoints = 0
    var prevOrangePoints = 0
    
    var isBreathingOK = false
    var isCanCheck = false
    
    var currentHelp = 1
    
    var pulseLevel = 0
    var state = StateProcess.breath
    var success = true
    
    var countdownIdx = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pulseLevel = readPulseLevelPreferences()
        customizeControls()
        checkPermissions()
        //checkHelp()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        setMeasures()
        print("getLimInfGenius(): \(getLimInfGenius())")
        print("viewGenius.frame.minY: \(viewGenius.frame.minY)")
        print("viewGenius.frame.maxY: \(viewGenius.frame.maxY)")
        print("")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if recorder != nil {
            recorder.stop()
        }
    }
    
    func checkPermissions() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)

        switch authStatus {
        case .authorized:
            print("AUTHORRIZED")
            //isPermissionDenied = false
            checkHelp()
        case .denied:
            print("DENEGADO")
            //isPermissionDenied = true
            viewBackPermissionDenied.isHidden = false
        default:
            print("NOT DETERMINED")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.checkPermissions()
            }
            checkHelp()
        }
    }
    
    private func setMeasures(){
        limInfGeniusY = viewGenius.frame.maxY
        weight = limInfGeniusY / 500.0
        print("weight: \(weight)")
        print("")
        applyWeight()
        viewGenius.isHidden = false
    }
    
    private func applyWeight() {
        let newWidthGenius = widthGenius * weight
        let newHeightGenius = heightGenius * weight
        constrainWidthGenius.constant = newWidthGenius
        constrainHeightGenius.constant = newHeightGenius
        limSupGeniusY = newHeightGenius + 5
        
        constrainWidthCountdown.constant = widthCountdown * weight
        constrainHeightCountdown.constant = heightCountdown * weight

        constrainWidthCloud1.constant = widthCloud * weight
        constrainHeightCloud1.constant = heightCloud * weight
        constrainWidthCloud2.constant = widthCloud * weight
        constrainHeightCloud2.constant = heightCloud * weight
    }
    
    private func startProcessBreath(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.animationCountdown()
            self.animateCloud(view: self.viewCloud1)
            self.animateCloud(view: self.viewCloud2)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.checkLevel()
        }
    }
    
    private func checkLevel(){
        print("prevOrangePoints:\(prevOrangePoints)")
        print("orangePoints:\(orangePoints)")
        //lblTitle.text! = "\(pulseLevel)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            
            if self.pulseLevel > 0 {
                if self.orangePoints == self.prevOrangePoints {
                    self.pulseLevel -= 1
                } else {
                    self.prevOrangePoints += 1
                }
                print("self.prevOrangePoints:\(self.prevOrangePoints)")
                print("self.orangePoints:\(self.orangePoints)")
                //self.lblTitle.text! = " \(self.pulseLevel)"
                self.checkLevel()
            }
        }
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
        viewGenius.isHidden = true
        viewBackPermissionDenied.backgroundColor = .colorGreyTranslucid
        viewBackPermissionDenied.isHidden = true
        viewPermission.backgroundColor = .colorPrimary

        lblTitle.style(text: txtBreathing.uppercased(),
                       color: .colorPrimary,
                       size: 16,
                       fontName: fontArialRegular)
        lblBreathMessages.style(text: txtBreathAndBlow,
                                color: .white,
                                size: 20,
                                fontName: fontArialBold)
        lblBreathMessages.isHidden = true
        lblContinue.style(text: txtToContinue,
                          color: .white,
                          size: 26,
                          fontName: fontArialBold)
        lblHeartBeatsScreen.style(text: txtGoToHeartBeatsScreen,
                                  color: .white,
                                  size: 20,
                                  fontName: fontArialRegular)
        
        lblCheckBox.style(text: txtDontShowAgain,
                          color: .colorPrimaryDark,
                          size: 14,
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
                              color: .colorPrimaryDark,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction21.style(text: txtBreathInstruction21,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction22.style(text: txtBreathInstruction22,
                              color: .colorPrimaryDark,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction23.style(text: txtBreathInstruction23,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction24.style(text: txtBreathInstruction24,
                              color: .colorPrimaryDark,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction31.style(text: txtBreathInstruction31,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction32.style(text: txtBreathInstruction32,
                              color: .colorPrimaryDark,
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
                              color: .colorPrimaryDark,
                              size: 14,
                              fontName: fontArialRegular)
        lblPermissionTitle.style(text: txtMicroPermission,
                             color: .colorPrimaryDark,
                             size: 20,
                             fontName: fontArialBold)
        lbl1Permission.style(text: txtWithoutPermissionNotWork,
                             color: .white,
                             size: 20,
                             fontName: fontArialRegular)
        lbl2Permission.style(text: txtEnabledPermission,
                             color: .white,
                             size: 20,
                             fontName: fontArialRegular)
        
        
        btnEndProcess.styleDialog(txt: txtEnd.uppercased())
        btnEndHelp.style(txt: txtContinue.uppercased(), size: 16)
        btnEndHelp.isHidden = true
        btnExit.styleDialog(txt: txtExit.uppercased())
        btnSettings.styleDialog(txt: txtSettings.uppercased())
        
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
        viewCountdown.isHidden = false
        let arrImgCount = [UIImage(named: "countdown_3"),
                           UIImage(named: "countdown_2"),
                           UIImage(named: "countdown_1"),
                           UIImage(named: "countdown_go")]
        for i in 0...3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.0) {
                self.countdownIdx = i
                self.imgCountdown.image = arrImgCount[i]
                self.animationCountdownUp(view: self.viewCountdown)
            }
        }
    }
    
    private func animationCountdownUp(view: UIView){
        let originalTransform = view.transform
        let scaledTransform = originalTransform.scaledBy(x: 10.0, y: 10.0)

        UIView.animate(withDuration: 0.7, animations: {
            view.transform = scaledTransform
        }, completion: {_ in
            self.animationCountdownDown(view: self.viewCountdown)
        })
    }
    
    private func animationCountdownDown(view: UIView){
        var transform: CGFloat = 0.1
        if self.countdownIdx == 3 {
            transform = 0.01
        }
        let originalTransform = view.transform
        let scaledTransform = originalTransform.scaledBy(x: transform, y: transform)

        UIView.animate(withDuration: 0.06, delay: 0.2, animations: {
                view.transform = scaledTransform
        }, completion: { _ in
            
            if self.countdownIdx == 3 {
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
        var transY: CGFloat = 3.5 * weight
        if isBreathing {
            transY = getTransY(level: pulseLevel, success: success)//-4.5
        } else if isBreathingOK {
            transY = 2.3 * weight
        } else {
            transY = 3.5 * weight
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.viewBackground.backgroundColor = .colorPrimaryBackground
                }
                checkOrangePoint()
                isBreathingOK = true
                lblBreathMessages.text = txtRest
            } else {
                if viewGenius.frame.maxY >= limInfGeniusY {
                    success = false
                }
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
    
    private func getTransY (level: Int, success: Bool) -> CGFloat {
//        pulseLevel = level
//        if !success {
//            pulseLevel = max(0, pulseLevel - 1)
//        }
//
        print("pulseLevel: \(pulseLevel)")
        
        switch pulseLevel {
        case 0:
            return -4.3 * weight
        case 1:
            return -3.9 * weight
        case 2:
            return -3.5 * weight
        case 3:
            return -3.1 * weight
        case 4:
            return -2.7 * weight
        case 5:
            return -2.3 * weight
        case 6:
            return -1.9 * weight
        default:
            return -4.0 * weight
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
    
    @IBAction func actionExit(_ sender: Any) {
        performSegue(withIdentifier: "unwindBreath", sender: nil)
    }
    
    @IBAction func actionSettings(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        performSegue(withIdentifier: "unwindBreath", sender: nil)
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
        state = .heartbeats2
        performSegue(withIdentifier: "unwindBreath", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindBreath"{
            let destinationVC = segue.destination as! TransitionViewController
            destinationVC.modalPresentationStyle = .fullScreen
            destinationVC.state = state
        }
    }
}
