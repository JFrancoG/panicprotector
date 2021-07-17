//
//  HeartBeatsViewController.swift
//  panicprotector
//
//  Created by Jesús Franco García on 23/05/2021.
//

import UIKit
import AVFoundation
import KDCircularProgress
import BEMCheckBox

class HeartBeatsViewController: UIViewController {

    @IBOutlet weak var toolbar: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var viewBackHand: UIView!
    @IBOutlet weak var viewBackHeart: UIView!
    @IBOutlet weak var imgShapeHeart: UIImageView!
    @IBOutlet weak var viewVisor: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblBPM: UILabel!
    @IBOutlet weak var progress: KDCircularProgress!
    
    @IBOutlet weak var keypad: UIView!
    @IBOutlet weak var viewInterrogation: UIView!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var viewNextProcess: UIView!
    @IBOutlet weak var btnNextProcess: UIButton!
    
    @IBOutlet weak var viewBackDialogContinue: UIView!
    @IBOutlet weak var viewDialogContinue: UIView!
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var lblRemoveFinger: UILabel!
    @IBOutlet weak var lblFindQuietPlace: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    
    @IBOutlet weak var viewBackHelp: UIView!
    @IBOutlet weak var viewHelp: UIView!
    @IBOutlet weak var viewHelp1: UIView!
    @IBOutlet weak var viewHelp2: UIView!
    @IBOutlet weak var viewHelp3: UIView!
    
    @IBOutlet weak var viewBackPreviousHelp: UIView!
    @IBOutlet weak var viewBackNextHelp: UIView!
    
    @IBOutlet weak var viewBackCheckBox: UIView!
    @IBOutlet weak var checkBoxHelp: BEMCheckBox!
    @IBOutlet weak var lblCheckBox: UILabel!
    
    @IBOutlet weak var btnEndHelp: UIButton!
    
    
    var delegate: HeartBeatsProtocol?
    var counter = 0
    
    var bpm = 80.0
    
    var isPulse = false
    var isCanCheck = false
    
    var pulsationLevel = 0
    
    private var validFrameCounter = 0
    private var heartRateManager: HeartRateManager!
    private var hueFilter = Filter()
    private var pulseDetector = PulseDetector()
    private var inputs: [CGFloat] = []
    private var measurementStartedFlag = false
    private var timer = Timer()
    
    var currentHelp = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        initVideoCapture()
        customizeControls()
        checkHelp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //startProcessHeartBeats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetValues()
    }
    
    func resetValues() {
        deinitCaptureSession()
        initializeValues()
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
        viewBackDialogContinue.backgroundColor = .colorGreyTranslucid
        viewBackDialogContinue.isHidden = true
        viewBackHelp.backgroundColor = .colorGreyTranslucid
        //viewBackHelp.isHidden = true
        viewHelp2.isHidden = true
        viewHelp3.isHidden = true
        viewBackPreviousHelp.isHidden = true
        viewBackCheckBox.isHidden = true

        lblTitle.textColor = .colorPrimary
        lblTitle.text = txtHeartBeats.uppercased()
        lblBPM.textColor = .colorPrimaryDark
        lblBPM.text = ""
        lblMessage.textColor = .colorPrimaryDark
        lblMessage.text = "Cubre la cámara trasera hasta que la imagen se vuelva rojo oscuro"//"Cover the back camera until the image turns red"
        lblCheckBox.textColor = .colorPrimaryDark
        lblCheckBox.text = "No volver a mostrar"
        
        btnContinue.styleDialog(txt: txtContinue.uppercased())
        btnEndHelp.style(txt: txtContinue.uppercased())
        btnEndHelp.isHidden = true
        
        progress.clockwise = false
        progress.progressColors = [.colorPrimaryDark]
        progress.progressThickness = 0.5
        progress.trackThickness = 0
        progress.startAngle = 142.0
        progress.angle = 0.0
        
        checkBoxHelp.customizeCheckBox()
    }
    
    private func checkHelp() {
        print("readNotShowPulseHelpPreferences(): \(readNotShowPulseHelpPreferences())")
        if readNotShowPulseHelpPreferences() {
            viewBackHelp.isHidden = true
        } else {
            viewBackHelp.isHidden = false
        }
    }
    
    func initializeValues() {
        lblBPM.text = ""
        lblMessage.text = "Cubre la cámara trasera hasta que la imagen se vuelva rojo oscuro"//"Cover the back camera until the image turns red"
        //progress.angle = 0.0
        progress.stopAnimation()
    }
    
    func startProcessHeartBeats(){
        //initVideoCapture()
        initCaptureSession()
        initializeValues()
        isCanCheck = true
        counter = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.animationPulse(img: self.imgShapeHeart)
        }
    }
    
    private func checkProcess(){
        if isCanCheck {
            if counter > 0 {
                // bloquear botón siguiente proceso
                progress.animate(fromAngle: Double(counter * 10), toAngle: min(Double((counter+1) * 10), 110.0), duration: getPulseSec()) { (success) in
                    print("finish")
                }
                print("counter:\(counter)")
                if counter <= 10 {
                    isCanCheck = false
                    animationPulse(img: imgShapeHeart)
                } else {
                    delegate?.endProcessPulse()
                    resetValues()
                    // lblcontinue  = medición completa
                    viewBackDialogContinue.isHidden = false
                }
            }
            if isPulse {
                counter += 1
            } else {
                counter = 0
            }
        }
    }

    private func animationPulse(img: UIImageView){
        UIView.animate(withDuration: 0.1, animations: {() -> Void in
            img.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 0.3, animations: {() -> Void in
                img.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                DispatchQueue.main.asyncAfter(deadline: .now() + self.getPulseSec()) {
                    self.isCanCheck = true
                    self.checkProcess()
                }
            })
        })
    }
    
    private func getPulseSec() -> Double {
        var rate = 60.0 / 80.0
        if bpm > 40.0 && bpm < 200.0 {
            rate = 60.0 / bpm
        }
        print("rate: \(rate)")
        return rate
    }
    
    private func disableHelp(){
        viewInterrogation.backgroundColor = .lightGray
        btnHelp.isUserInteractionEnabled = false
    }
    
    
    @IBAction func actionCheckBox(_ sender: BEMCheckBox) {
        if sender.on {
            savePreferencesNotShowPulseHelp(notshow: true)
        } else {
            savePreferencesNotShowPulseHelp(notshow: false)
        }
    }
    
    @IBAction func actionContinue(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindPulse", sender: nil)
    }
    
    @IBAction func actionNextProcess(_ sender: UIButton) {
        // lblContinue = continuar
        viewBackDialogContinue.isHidden = false
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
        startProcessHeartBeats()
        disableHelp()
    }
    
    // MARK: - Frames Capture Methods
    private func initVideoCapture() {
        let specs = VideoSpec(fps: 30, size: CGSize(width: 300, height: 300))
        heartRateManager = HeartRateManager(cameraType: .back, preferredSpec: specs, previewContainer: viewVisor.layer)
        heartRateManager.imageBufferHandler = { [unowned self] (imageBuffer) in
            self.handle(buffer: imageBuffer)
        }
    }
    
    // MARK: - AVCaptureSession Helpers
    private func initCaptureSession() {
        heartRateManager.startCapture()
    }
    
    func deinitCaptureSession() {
        heartRateManager.stopCapture()
        toggleTorch(status: false)
    }
    
    private func toggleTorch(status: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        device.toggleTorch(on: status)
    }
    
    // MARK: - Measurement
    private func startMeasurement() {
        DispatchQueue.main.async {
            self.toggleTorch(status: true)
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
                guard let self = self else { return }
                let average = self.pulseDetector.getAverage()
                let pulse = 60.0/average
                if pulse == -60 {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.lblBPM.alpha = 0
                        
                    }) { (finished) in
                        self.lblBPM.isHidden = finished
                        self.isPulse = false
                        print("false")
                        //self.checkProcess()
                    }
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.lblBPM.alpha = 1.0
                    }) { (_) in
                        self.lblBPM.isHidden = false
                        self.lblBPM.text = "\(lroundf(pulse))"
                        self.bpm = Double(pulse)
                        self.isPulse = true
                        print("tryue")
                        self.checkProcess()
                    }
                }
            })
        }
    }

}

protocol HeartBeatsProtocol {
    func endProcessPulse()
}

//MARK: - Handle Image Buffer
extension HeartBeatsViewController {
    fileprivate func handle(buffer: CMSampleBuffer) {
        var redmean:CGFloat = 0.0;
        var greenmean:CGFloat = 0.0;
        var bluemean:CGFloat = 0.0;
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(buffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)

        let extent = cameraImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        let averageFilter = CIFilter(name: "CIAreaAverage",
                              parameters: [kCIInputImageKey: cameraImage, kCIInputExtentKey: inputExtent])!
        let outputImage = averageFilter.outputImage!

        let ctx = CIContext(options:nil)
        let cgImage = ctx.createCGImage(outputImage, from:outputImage.extent)!
        
        let rawData:NSData = cgImage.dataProvider!.data!
        let pixels = rawData.bytes.assumingMemoryBound(to: UInt8.self)
        let bytes = UnsafeBufferPointer<UInt8>(start:pixels, count:rawData.length)
        var BGRA_index = 0
        for pixel in UnsafeBufferPointer(start: bytes.baseAddress, count: bytes.count) {
            switch BGRA_index {
            case 0:
                bluemean = CGFloat (pixel)
            case 1:
                greenmean = CGFloat (pixel)
            case 2:
                redmean = CGFloat (pixel)
            case 3:
                break
            default:
                break
            }
            BGRA_index += 1
        }
        
        let hsv = rgb2hsv((red: redmean, green: greenmean, blue: bluemean, alpha: 1.0))
        // Do a sanity check to see if a finger is placed over the camera
        if (hsv.1 > 0.5 && hsv.2 > 0.5) {
            DispatchQueue.main.async {
                self.lblMessage.text = "Ahora no muevas el dedo"//"Hold your index finger still"
                self.toggleTorch(status: true)
                if !self.measurementStartedFlag {
                    self.startMeasurement()
                    self.measurementStartedFlag = true
                }
            }
            validFrameCounter += 1
            inputs.append(hsv.0)
            // Filter the hue value - the filter is a simple BAND PASS FILTER that removes any DC component and any high frequency noise
            let filtered = hueFilter.processValue(value: Double(hsv.0))
            if validFrameCounter > 60 {
                self.pulseDetector.addNewValue(newVal: filtered, atTime: CACurrentMediaTime())
            }
        } else {
            validFrameCounter = 0
            measurementStartedFlag = false
            pulseDetector.reset()
            DispatchQueue.main.async {
                self.lblMessage.text = "Cubre la cámara trasera hasta que la imagen se vuelva rojo oscuro"//"Cover the back camera until the image turns red"
            }
        }
    }
}
