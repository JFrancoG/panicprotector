//
//  HeartBeatsViewController.swift
//  panicprotector
//
//  Created by Jesús Franco García on 23/05/2021.
//

import UIKit
import AVFoundation
import LinearProgressBar

class HeartBeatsViewController: UIViewController {
    
    
    @IBOutlet weak var viewBackHand: UIView!
    
    @IBOutlet weak var viewBackHeart: UIView!
    
    @IBOutlet weak var imgShapeHeart: UIImageView!
    
    @IBOutlet weak var viewVisor: UIView!
    
    @IBOutlet weak var lblMessage: UILabel!
    
    @IBOutlet weak var lblBPM: UILabel!
    
    @IBOutlet weak var progress: LinearProgressBar!
    
    
    var delegate: HeartBeatsProtocol?
    var counter = 0
    
    var bpm = 80.0
    
    var isPulse = false
    var isCanCheck = false
    
    private var validFrameCounter = 0
    private var heartRateManager: HeartRateManager!
    private var hueFilter = Filter()
    private var pulseDetector = PulseDetector()
    private var inputs: [CGFloat] = []
    private var measurementStartedFlag = false
    private var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        initVideoCapture()
        customizeControls()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        initCaptureSession()
        startProcessHeartBeats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deinitCaptureSession()
    }
    
    private func customizeControls(){
        lblBPM.textColor = .colorPrimaryDark
        lblBPM.text = ""
        lblMessage.textColor = .colorPrimaryDark
        lblMessage.text = "Cover the back camera until the image turns red"
        progress.barColor = .colorPrimaryDark
        progress.trackColor = .clear
        progress.barThickness = 55
        progress.barPadding = -25
        progress.progressValue = 0
        
    }
    
    func startProcessHeartBeats(){
        isCanCheck = true
        counter = 0
        animationPulse(img: imgShapeHeart)
    }
    
    private func checkProcess(){
        if isCanCheck {
            if counter > 0 {
                progress.progressValue = CGFloat(counter * 10)
                print("counter:\(counter)")
                if counter <= 10 {
                    isCanCheck = false
                    animationPulse(img: imgShapeHeart)
                } else {
                    delegate?.endProcess()
                    self.dismiss(animated: true, completion: nil)
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
        return rate
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
    
    private func deinitCaptureSession() {
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
    func endProcess()
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
                self.lblMessage.text = "Hold your index finger still."
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
                self.lblMessage.text = "Cover the back camera until the image turns red"
            }
        }
    }
}
