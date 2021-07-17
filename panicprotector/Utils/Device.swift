//
//  Device.swift
//  panicprotector
//
//  Created by Jesús Franco García on 01/07/2021.
//

import UIKit


func isXFamily() -> Bool {
    if UIDevice().userInterfaceIdiom == .phone {
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            //print("iPhone 5 or 5S or 5C")
            return false
        case 1334:
            //print("iPhone 6/6S/7/8/SE(2ndEd.)")
            return false
        case 1920, 2208:
            //print("iPhone 6+/6S+/7+/8+")
            return false
        case 2436:
            //print("X, Xs, 11 Pro")
            // 12 mini aparece aqui
            return true
        case 2688:
            //print("Xs Max, 11 Pro Max")
            return true
        case 1792:
            //print("Xr, 11")
            return true
        case 2340:
            //print("12 mini")
            return true
        case 2532:
            //print("12, 12 Pro")
            return true
        case 2778:
            //print("12 Pro Max")
            return true
        default:
            print("unknown")
            return false
        }
    }
    return false
}

func getFloatHeightDevice() -> CGFloat {
    return UIScreen.main.bounds.height
}

func getFloatStatusBarHeight() -> CGFloat {
    if isXFamily() {
        return 44
    }else{
        return 20
    }
}

func getPulsationLevel(pulse: Int) -> Int {
    if pulse < 75 {
        return 0
    } else if pulse < 90 {
        return 1
    } else if pulse < 105 {
        return 2
    } else if pulse < 120 {
        return 3
    } else if pulse < 135 {
        return 4
    } else if pulse < 150 {
        return 5
    } else {
        return 6
    }
}
