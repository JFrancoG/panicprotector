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
    @IBOutlet weak var lblInProcess: UILabel!
    @IBOutlet weak var imgShapeHeart: UIImageView!
    @IBOutlet weak var viewVisor: UIView!
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
    
    @IBOutlet weak var viewBackMeasurement: UIView!
    @IBOutlet weak var viewCorrectMeasure: UIView!
    @IBOutlet weak var lblCompleteMeasure: UILabel!
    @IBOutlet weak var lblCalmLevels: UILabel!
    @IBOutlet weak var viewResult: UIView!
    @IBOutlet weak var lblCalmLevel: UILabel!
    @IBOutlet weak var lblCalmLevelDescription: UILabel!
    @IBOutlet weak var btnRestartCycleCorrect: UIButton!
    
    @IBOutlet weak var viewIncorrectMeasure: UIView!
    @IBOutlet weak var lblIncorrectMeasureTitle: UILabel!
    @IBOutlet weak var lblIncorrectMeasureContent: UILabel!
    @IBOutlet weak var btnRestartCycleIncorrect: UIButton!
    
    @IBOutlet weak var viewBackDialogStart: UIView!
    @IBOutlet weak var viewDialogStart: UIView!
    @IBOutlet weak var lblDialogStart: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    
    @IBOutlet weak var viewBackHelp: UIView!
    @IBOutlet weak var viewHelp: UIView!
    @IBOutlet weak var viewHelp1: UIView!
    @IBOutlet weak var viewHelp2: UIView!
    @IBOutlet weak var viewHelp3: UIView!
    
    @IBOutlet weak var lblInstruction1: UILabel!
    @IBOutlet weak var lblInstruction2: UILabel!
    @IBOutlet weak var lblInstruction3: UILabel!
    @IBOutlet weak var lblInstruction4: UILabel!
    @IBOutlet weak var lblInstruction5: UILabel!
    @IBOutlet weak var lblInstruction6: UILabel!
    @IBOutlet weak var lblInstruction7: UILabel!
    
    @IBOutlet weak var viewBackPreviousHelp: UIView!
    @IBOutlet weak var viewBackNextHelp: UIView!
    
    @IBOutlet weak var viewBackCheckBox: UIView!
    @IBOutlet weak var checkBoxHelp: BEMCheckBox!
    @IBOutlet weak var lblCheckBox: UILabel!
    
    @IBOutlet weak var btnEndHelp: UIButton!
    
    @IBOutlet weak var viewBackPermissionDenied: UIView!
    @IBOutlet weak var viewPermission: UIView!
    @IBOutlet weak var lblPermissionTitle: UILabel!
    @IBOutlet weak var lbl1Permission: UILabel!
    @IBOutlet weak var lbl2Permission: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnSettings: UIButton!
    
    
    var delegate: HeartBeatsProtocol?
    var counter = 0
    
    var bpm = 80.0
    
    var isPulse = false
    var isCanCheck = false
    var isPermissionDenied = false
    
    var pulseLevel = -1
    var state = StateProcess.heartbeats
    
    var partialPulseAverage = [Int]()
    
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
        //initVideoCapture()
        customizeControls()
        //savePreferencesPulseLevel(level: pulseLevel)
        //checkHelp()
        checkPermissions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //startProcessHeartBeats()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isPermissionDenied {
            resetValues()
        }
    }
    
    private func initProcess() {
        initVideoCapture()
        checkHelp()
    }
    
    func checkPermissions() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

        switch authStatus {
        case .authorized:
            print("AUTHORIZED")
            isPermissionDenied = false
            initProcess()
        case .denied:
            print("DENEGADO")
            isPermissionDenied = true
            viewBackPermissionDenied.isHidden = false
        default:
            print("NOT DETERMINED")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.checkPermissions()
            }
            initProcess()
        }
    }
    
    func resetValues() {
        deinitCaptureSession()
        initializeValues()
    }
    
    private func customizeControls(){
        // toolbar
        toolbar.backgroundColor = .colorPrimaryBackground
        toolbar.showShadow()
        
        // keypad
        keypad.backgroundColor = .clear
        viewInterrogation.backgroundColor = .colorPrimary
        viewInterrogation.roundBorderComplete()
        viewNextProcess.backgroundColor = .colorPrimary
        viewNextProcess.roundBorderComplete()
        
        // views
        view.backgroundColor = .colorPrimaryDark
        viewBackground.backgroundColor = .colorPrimaryBackground
        viewBackDialogContinue.backgroundColor = .colorGreyTranslucid
        viewBackDialogContinue.isHidden = true
        viewDialogContinue.backgroundColor = .colorPrimary
        viewBackHelp.backgroundColor = .colorGreyTranslucid
        viewHelp2.isHidden = true
        viewHelp3.isHidden = true
        viewBackPreviousHelp.isHidden = true
        viewBackCheckBox.isHidden = true
        viewBackDialogStart.backgroundColor = .colorGreyTranslucid
        viewBackDialogStart.isHidden = true
        viewDialogStart.backgroundColor = .colorPrimary
        viewBackMeasurement.backgroundColor = .colorGreyTranslucid
        viewBackMeasurement.isHidden = true
        viewCorrectMeasure.isHidden = true
        viewCorrectMeasure.backgroundColor = .colorPrimary
        viewIncorrectMeasure.isHidden = true
        viewIncorrectMeasure.backgroundColor = .colorPrimary
        viewResult.backgroundColor = .colorGreenCalm
        viewBackPermissionDenied.backgroundColor = .colorGreyTranslucid
        viewBackPermissionDenied.isHidden = true
        viewPermission.backgroundColor = .colorPrimary

        // labels
        lblInProcess.style(text: txtInProcess,
                           color: .white,
                           size: 24,
                           fontName: fontArialBold)
        lblInProcess.isHidden = true
        lblTitle.style(text: txtHeartBeats.uppercased(),
                       color: .colorPrimary,
                       size: 16,
                       fontName: fontArialRegular)

        lblCheckBox.style(text: txtDontShowAgain,
                          color: .colorPrimaryDark,
                          size: 14,
                          fontName: fontArialBold)
  
        lblDialogStart.style(text: txtDialogStartHeartBeats,
                             color: .white,
                             size: 18,
                             fontName: fontArialBold)
        
        lblContinue.style(text: txtToContinue.lowercased(),
                          color: .white,
                          size: 26,
                          fontName: fontArialBold)
        lblRemoveFinger.style(text: txtRemoveFinger.uppercased(),
                              color: .white,
                              size: 20,
                              fontName: fontArialRegular)
        lblFindQuietPlace.style(text: txtFindQuietPlace.uppercased(),
                                color: .white,
                                size: 20,
                                fontName: fontArialRegular)
        lblCompleteMeasure.style(text: txtCompleteMeasure,
                                 color: .white,
                                 size: 26,
                                 fontName: fontArialBold)
        lblCalmLevels.style(text: txtCalmLevels,
                            color: .white,
                            size: 20,
                            fontName: fontArialRegular)
        lblCalmLevel.style(text: txtCalmLevel4,
                           color: .white,
                           size: 18,
                           fontName: fontArialRegular)
        lblCalmLevelDescription.style(text: txtCalmLevel4Desc,
                                      color: .white,
                                      size: 18,
                                      fontName: fontArialRegular)
        lblIncorrectMeasureTitle.style(text: txtToContinue.lowercased(),
                                       color: .white,
                                       size: 26,
                                       fontName: fontArialBold)
        lblIncorrectMeasureContent.style(text: txtIncorrectMeasurement,
                                         color: .white,
                                         size: 20,
                                         fontName: fontArialRegular)
        lblInstruction1.style(text: txtHeartBeatsInstruction1,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction2.style(text: txtHeartBeatsInstruction2,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction3.style(text: txtHeartBeatsInstruction3,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction4.style(text: txtHeartBeatsInstruction4,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction5.style(text: txtHeartBeatsInstruction5,
                              color: .colorPrimaryDark,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction6.style(text: txtHeartBeatsInstruction6,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblInstruction7.style(text: txtHeartBeatsInstruction7,
                              color: .white,
                              size: 14,
                              fontName: fontArialRegular)
        lblPermissionTitle.style(text: txtCameraPermission,
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
        
        // buttons
        btnContinue.styleDialog(txt: txtContinue.uppercased())
        btnEndHelp.style(txt: txtContinue.uppercased(), size: 16)
        btnEndHelp.isHidden = true
        btnStart.styleDialog(txt: txtStart.uppercased())
        btnRestartCycleCorrect.styleDialog(txt: txtRestartCycle.uppercased())
        btnRestartCycleIncorrect.styleDialog(txt: txtRestartCycle.uppercased())
        btnClose.setTitle("", for: .normal)
        btnSettings.styleDialog(txt: txtSettings.uppercased())
        
        // progress
        progress.clockwise = false
        progress.progressColors = [.colorPrimaryDark]
        progress.progressThickness = 0.5
        progress.trackThickness = 0
        progress.startAngle = 142.0
        progress.angle = 0.0
        
        // checkBox
        checkBoxHelp.customizeCheckBox()
    }
    
    private func checkHelp() {
        if readNotShowPulseHelpPreferences() {
            viewBackHelp.isHidden = true
            viewBackDialogStart.isHidden = false
            checkBoxHelp.on = true
        } else {
            viewBackHelp.isHidden = false
        }
    }
    
    func initializeValues() {
        progress.stopAnimation()
    }
    
    func startProcessHeartBeats(){
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
            lblInProcess.isHidden = false
            if counter > 0 {
                // bloquear botón siguiente proceso?
                progress.animate(fromAngle: Double(counter * 10), toAngle: min(Double((counter+1) * 10), 110.0), duration: getPulseSec()) { (success) in
                    print("finish")
                }
                if counter <= 10 {
                    lblInProcess.isHidden = true
                    isCanCheck = false
                    animationPulse(img: imgShapeHeart)
                } else {
                    delegate?.endProcessPulse()
                    resetValues()
                    lblInProcess.isHidden = true
                    if state == .heartbeats {
                        lblContinue.text = txtCompleteMeasure
                        let trimAverage = trimPulseAverage()
                        pulseLevel = getPulseLevel(value: trimAverage)
                        savePreferencesPulse(bpm: trimAverage)
                        savePreferencesPulseLevel(level: pulseLevel)
                        viewBackDialogContinue.isHidden = false
                    } else {
                        let trimAverage = trimPulseAverage()
                        pulseLevel = getPulseLevel(value: trimAverage)
                        let previousBPM = readPulsePreferences()
                        viewBackMeasurement.isHidden = false
                        if previousBPM < 50 || trimAverage < 50 || previousBPM > 200 || trimAverage > 200 {
                            viewIncorrectMeasure.isHidden = false
                        } else {
                            let diff = previousBPM - trimAverage
                            let absDiff = abs(diff)
                            print("previousBPM: \(previousBPM)")
                            print("trimAverage: \(trimAverage)")
                            if absDiff > 40 {
                                viewIncorrectMeasure.isHidden = false
                            } else {
                                let calmMessages = getCalmMessages(currentBPM: trimAverage)
                                lblCalmLevel.text = calmMessages.calmLevel
                                lblCalmLevelDescription.text = calmMessages.calmDesc
                                viewCorrectMeasure.isHidden = false
                            }
                        }
                    }
                    isCanCheck = false
                }
            }
            if isPulse {
                counter += 1
            } else {
                counter = 0
            }
        }
    }
    
    private func getCalmMessages(currentBPM: Int) -> (calmLevel: String, calmDesc: String) {
        var calmMessage = ""
        var calmDescMessage = ""
        if currentBPM > 90  && currentBPM <= 110 {
            calmMessage = txtCalmLevel3
            calmDescMessage = txtCalmLevel3Desc
        } else if currentBPM > 110 && currentBPM <= 130 {
            calmMessage = txtCalmLevel2
            calmDescMessage = txtCalmLevel2Desc
        } else if currentBPM > 130 {
            calmMessage = txtCalmLevel1
            calmDescMessage = txtCalmLevel1Desc
        } else {
            calmMessage = txtCalmLevel4
            calmDescMessage = txtCalmLevel4Desc
        }
        return (calmMessage, calmDescMessage)
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
    
    private func trimPulseAverage() -> Int {
        var average = 80.0
        let orderedPartialAverage = partialPulseAverage.sorted {
            $0 < $1
        }
        let dropNumber = Int(orderedPartialAverage.count / 10)
        var trimPartialAverage = orderedPartialAverage.dropFirst(dropNumber)
        trimPartialAverage = trimPartialAverage.dropLast(dropNumber)

        let sumArray = trimPartialAverage.reduce(0, +)
        average = Double(sumArray) / Double(trimPartialAverage.count)

        return Int(round(average))
    }

    private func getPulseLevel(value: Int) -> Int {
        if value < 75 {
            return 0
        } else if value < 90 {
            return 1
        } else if value < 105 {
            return 2
        } else if value < 120 {
            return 3
        } else if value < 135 {
            return 4
        } else if value < 150 {
            return 5
        } else {
            return 6
        }
    }
    
    private func checkState() {
        if state == .heartbeats {
            state = .breath
        } else {
            state = .end
        }
    }
    
    @IBAction func actionExit(_ sender: Any) {
        checkState()
        performSegue(withIdentifier: "unwindPulse", sender: nil)
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
        performSegue(withIdentifier: "unwindPulse", sender: nil)
    }
    
    @IBAction func actionCheckBox(_ sender: BEMCheckBox) {
        if sender.on {
            savePreferencesNotShowPulseHelp(notshow: true)
        } else {
            savePreferencesNotShowPulseHelp(notshow: false)
        }
    }
    
    @IBAction func actionShowHelp(_ sender: UIButton) {
        resetValues()
        toggleTorch(status: false)
        viewBackHelp.isHidden = false
    }
    
    @IBAction func actionContinue(_ sender: UIButton) {
        checkState()
        performSegue(withIdentifier: "unwindPulse", sender: nil)
    }
    
    @IBAction func actionNextProcess(_ sender: UIButton) {
        if state == .heartbeats {
            viewBackDialogContinue.isHidden = false
        } else {
            viewBackMeasurement.isHidden = false
            viewIncorrectMeasure.isHidden = false
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
        viewBackDialogStart.isHidden = false
        disableHelp()
    }
    
    @IBAction func actionStart(_ sender: UIButton) {
        viewBackDialogStart.isHidden = true
        startProcessHeartBeats()
    }
    
    @IBAction func actionRestartCycleCorrect(_ sender: UIButton) {
        viewBackMeasurement.isHidden = true
        viewCorrectMeasure.isHidden = true
        state = .end
        performSegue(withIdentifier: "unwindPulse", sender: nil)
    }
    
    @IBAction func actionRestartCycleIncorrect(_ sender: UIButton) {
        viewBackMeasurement.isHidden = true
        viewIncorrectMeasure.isHidden = true
        state = .end
        performSegue(withIdentifier: "unwindPulse", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindPulse"{
            let destinationVC = segue.destination as! TransitionViewController
            destinationVC.modalPresentationStyle = .fullScreen
            destinationVC.state = state
        }
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
                    self.isPulse = false
                    print("pulse false")
                } else {
                    self.bpm = Double(pulse)
                    self.isPulse = true
                    print("pulse true \(lroundf(pulse))")
                    self.partialPulseAverage.append(lroundf(pulse))
                    print("num elem: \(self.partialPulseAverage.count)")
                    
                    self.checkProcess()
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
        }
    }
}
