//
//  Extensions.swift
//  panicprotector
//
//  Created by Jesús Franco García on 01/05/2021.
//

import UIKit
import Foundation
import AVFoundation

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

}

extension UIButton {
    func style(txt: String){
        setTitle(txt, for: .normal)
        layer.cornerRadius = radiusButtons
        layer.masksToBounds = true
        setTitleColor(.colorPrimaryBackground, for: .normal)
        backgroundColor = .colorPrimaryDark
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
    
    func showShadow(){
        layer.masksToBounds = false
        layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 5.0

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
