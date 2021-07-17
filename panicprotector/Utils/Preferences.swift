//
//  Preferences.swift
//  panicprotector
//
//  Created by Jesús Franco García on 08/07/2021.
//

import Foundation

func savePreferencesPulseLevel(level: Int) {
    UserDefaults.standard.set(level, forKey: "pulselevel")
}
func readPulseLevelPreferences() -> Int {
    return UserDefaults.standard.integer(forKey: "pulselevel")
}

func savePreferencesNotShowPulseHelp(notshow: Bool) {
    UserDefaults.standard.set(notshow, forKey: "notshowpulsehelp")
}
func readNotShowPulseHelpPreferences() -> Bool {
    return UserDefaults.standard.bool(forKey: "notshowpulsehelp")
}
