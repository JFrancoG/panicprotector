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

    let THRESHOLD: Float = -16.0
    
    var limInfGeniusY: CGFloat = 500.0
    var limSupGeniusY: CGFloat = 190.0
    
    var isUp = false
    
    
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
        lblBreathMessages.isHidden = true
 
        btnEndProcess.styleDialog(txt: txtFinalise.uppercased())
    }
    
    private func animationCountdown() {
        let arrCount = ["3","2","1","GO!"]
        for i in 0...3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.1) {
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
        UIView.animate(withDuration: TimeInterval(CGFloat(0.1)), delay: 0.2, animations: {
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
        var transY: CGFloat = 5.0
        if isBreathing {
            transY = -10.0
        }
        
        print("limSupGeniusY: \(limSupGeniusY)")
        print("limInfGeniusY: \(limInfGeniusY)")
        
        print("transY: \(transY)")
        
        print("iewGenius.frame.minY: \(viewGenius.frame.minY)")
        print("iewGenius.frame.maxY: \(viewGenius.frame.maxY)")
        
        if isBreathing {
            if viewGenius.frame.maxY + transY < limSupGeniusY {
                // calcular lo que queda y parar
                //transY = limSupGeniusY - viewGenius.frame.minY
                // poner fondo naranja 0.2 seg
                // encender punto naranja redondo
                // hacer animación hasta abajo
                // para la grabación de audio
                // cuando llegue abajo hacer setup
            } else {
                let translatedTransform = originalTransform.translatedBy(x: 0.0, y: transY)
                UIView.animate(withDuration: TimeInterval(CGFloat(0.1)), animations: {
                        view.transform = translatedTransform
                    })
            }
        } else {
            if viewGenius.frame.maxY + transY > limInfGeniusY {
                // calcular lo que queda hasta abajo y parar ahí
                //transY = viewGenius.frame.minY - limInfGeniusY
            } else {
                let translatedTransform = originalTransform.translatedBy(x: 0.0, y: transY)
                UIView.animate(withDuration: TimeInterval(CGFloat(0.1)), animations: {
                        view.transform = translatedTransform
                    })
            }
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

        levelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
    }
    
    @objc func levelTimerCallback() {
        recorder.updateMeters()

        let level = recorder.averagePower(forChannel: 0)
        
        print("LEVEL: \(level)")
        
        if level > THRESHOLD {
            print("******************************* LEVEL: \(level)")
            animateGenius(view: viewGenius, isBreathing: true)
        } else {
            animateGenius(view: viewGenius, isBreathing: false)
        }

        // do whatever you want with isLoud
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
