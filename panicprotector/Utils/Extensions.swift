//
//  Extensions.swift
//  panicprotector
//
//  Created by Jesús Franco García on 01/05/2021.
//

import UIKit
import Foundation
import AVFoundation
import BEMCheckBox

extension UILabel {
  func animate(fontSize: CGFloat, duration: TimeInterval) {
    let startTransform = transform
    let oldFrame = frame
    var newFrame = oldFrame
    let scaleRatio = fontSize / font.pointSize

    newFrame.size.width *= scaleRatio
    newFrame.size.height *= scaleRatio
    newFrame.origin.x = oldFrame.origin.x - (newFrame.size.width - oldFrame.size.width) * 0.5
    newFrame.origin.y = oldFrame.origin.y - (newFrame.size.height - oldFrame.size.height) * 0.5
    frame = newFrame

    font = font.withSize(fontSize)

    transform = CGAffineTransform.init(scaleX: 1 / scaleRatio, y: 1 / scaleRatio);
    layoutIfNeeded()

    UIView.animate(withDuration: duration, animations: {
      self.transform = startTransform
      newFrame = self.frame
    }) { (Bool) in
      self.frame = newFrame
    }
  }
    
    func style(text: String, color: UIColor, size: CGFloat, fontName: String) {
        self.font = UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
        self.textColor = color
        self.text = text
    }
    
    func addBottomBorderWithColor(color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0,
                              y: frame.size.height - thickness,
                              width: frame.size.width,
                              height: thickness)
        layer.addSublayer(border)
    }
}

extension UIColor {
    @nonobjc class var colorPrimary: UIColor {
      return UIColor(red: 77/255, green: 208/255, blue: 225/255, alpha: 1.0)          // 4DD0E1
    }
    @nonobjc class var colorPrimaryDark: UIColor {
      return UIColor(red: 48/255, green: 63/255, blue: 159/255, alpha: 1.0)          // 303f9f
    }
    @nonobjc class var colorPrimaryBackground: UIColor {
      return UIColor(red: 225/255, green: 245/255, blue: 254/255, alpha: 1.0)          // E1F5FE
    }
    @nonobjc class var colorOrangeBreath: UIColor {
      return UIColor(red: 255/255, green: 138/255, blue: 101/255, alpha: 1.0)          // FF8A65
    }
    @nonobjc class var colorGreyTranslucid: UIColor {
      return UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 0.5)
    }
    @nonobjc class var colorOrangeTranslucid: UIColor {
      return UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 0.5)
    }
    @nonobjc class var colorGreenCalm: UIColor {
        return UIColor(red: 73/255, green: 126/255, blue: 118/255, alpha: 1.0)
    }

}

extension UIButton {
    func style(txt: String, size: CGFloat = 20){
        titleLabel!.font = UIFont(name: fontArialRegular, size: size)
        setTitle(txt, for: .normal)
        layer.cornerRadius = radius16
        layer.masksToBounds = true
        setTitleColor(.colorPrimaryBackground, for: .normal)
        backgroundColor = .colorPrimaryDark
        isUserInteractionEnabled = true
    }
    func styleDialog(txt: String){
        titleLabel!.font = UIFont(name: fontArialBold, size: 20)
        setTitle(txt, for: .normal)
        layer.cornerRadius = radius24
        layer.masksToBounds = true
        setTitleColor(.colorPrimary, for: .normal)
        backgroundColor = .colorPrimaryDark
    }
    func disableStyle(txt: String, size: CGFloat = 20){
        titleLabel!.font = UIFont(name: fontArialRegular, size: size)
        setTitle(txt, for: .normal)
        layer.cornerRadius = radius16
        layer.masksToBounds = true
        setTitleColor(.colorPrimaryBackground, for: .normal)
        backgroundColor = .lightGray
        isUserInteractionEnabled = false
    }
    func styleDialogPermission(txt: String){
        titleLabel!.font = UIFont(name: fontArialBold, size: 14)
        setTitle(txt, for: .normal)
        layer.cornerRadius = radius24
        layer.masksToBounds = true
        setTitleColor(.colorPrimary, for: .normal)
        backgroundColor = .colorPrimaryDark
    }
    func clearStyle(txt: String) {
        setTitle(txt, for: .normal)
        setTitleColor(.red, for: .normal)
        titleLabel!.font = UIFont(name: fontArialRegular, size: 16)
        layer.cornerRadius = radius8
        layer.borderWidth = 1
        layer.borderColor = UIColor.red.cgColor
        layer.masksToBounds = true
    }

}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

extension UIView {
    func roundBorderComplete() {
        layer.cornerRadius = self.frame.height / 2.0
    }
    
    func round(cornerRadius: CGFloat){
        layer.cornerRadius = cornerRadius
    }
    
    func showShadow(){
        layer.masksToBounds = false
        layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 5.0

    }
}

extension Double {
    func formatTwoDecimals(unity: String) -> String {
        return (String(format:"%.2f", self) + " \(unity)").replacingOccurrences(of: ".", with: ",")
    }
}

extension UIActivityIndicatorView {
    func style() {
        color = .colorPrimaryDark
        if #available(iOS 13.0, *) {
            style = .large
        } else {
            // Fallback on earlier versions
        }
        hidesWhenStopped = true
    }
}

extension BEMCheckBox {
    func customizeCheckBox() {
        boxType = .square
        onAnimationType = .fill
        offAnimationType = .fill
        lineWidth = 2
        cornerRadius = 4
        onTintColor = .colorOrangeBreath
        onCheckColor = .white
        onFillColor = .colorOrangeBreath
    }
}

extension AVCaptureDevice {
    private func availableFormatsFor(preferredFps: Float64) -> [AVCaptureDevice.Format] {
        var availableFormats: [AVCaptureDevice.Format] = []
        for format in formats
        {
            let ranges = format.videoSupportedFrameRateRanges
            for range in ranges where range.minFrameRate <= preferredFps && preferredFps <= range.maxFrameRate
            {
                availableFormats.append(format)
            }
        }
        return availableFormats
    }
    
    private func formatWithHighestResolution(_ availableFormats: [AVCaptureDevice.Format]) -> AVCaptureDevice.Format? {
        var maxWidth: Int32 = 0
        var selectedFormat: AVCaptureDevice.Format?
        for format in availableFormats {
            let desc = format.formatDescription
            let dimensions = CMVideoFormatDescriptionGetDimensions(desc)
            let width = dimensions.width
            if width >= maxWidth {
                maxWidth = width
                selectedFormat = format
            }
        }
        return selectedFormat
    }

    private func formatFor(preferredSize: CGSize, availableFormats: [AVCaptureDevice.Format]) -> AVCaptureDevice.Format? {
        for format in availableFormats {
            let desc = format.formatDescription
            let dimensions = CMVideoFormatDescriptionGetDimensions(desc)
            
            if dimensions.width >= Int32(preferredSize.width) && dimensions.height >= Int32(preferredSize.height) {
                return format
            }
        }
        return nil
    }
    
    func updateFormatWithPreferredVideoSpec(preferredSpec: VideoSpec) {
        let availableFormats: [AVCaptureDevice.Format]
        if let preferredFps = preferredSpec.fps {
            availableFormats = availableFormatsFor(preferredFps: Float64(preferredFps))
        }
        else {
            availableFormats = formats
        }
        
        var selectedFormat: AVCaptureDevice.Format?
        if let preferredSize = preferredSpec.size {
            selectedFormat = formatFor(preferredSize: preferredSize, availableFormats: availableFormats)
        } else {
            selectedFormat = formatWithHighestResolution(availableFormats)
        }
        print("selected format: \(String(describing: selectedFormat))")
        
        if let selectedFormat = selectedFormat {
            do {
                try lockForConfiguration()
            }
            catch let error {
                fatalError(error.localizedDescription)
            }
            activeFormat = selectedFormat
            
            if let preferredFps = preferredSpec.fps {
                activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: preferredFps)
                activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: preferredFps)
                unlockForConfiguration()
            }
        }
    }
    
    func toggleTorch(on: Bool) {
        guard hasTorch, isTorchAvailable else {
            print("Torch is not available")
            return
        }
        do {
            try lockForConfiguration()
            torchMode = on ? .on : .off
            unlockForConfiguration()
        } catch {
            print("Torch could not be used \(error)")
        }
    }
}
