//
//  Preferences.swift
//  panicprotector
//
//  Created by Jesús Franco García on 08/07/2021.
//

import Foundation

func savePreferencesAcceptTerms(acceptTerms: Bool) {
    UserDefaults.standard.set(acceptTerms, forKey: "acceptTerms")
}
func readAcceptTermsPreferences() -> Bool {
    return UserDefaults.standard.bool(forKey: "acceptTerms")
}

func savePreferencesPulseLevel(level: Int) {
    UserDefaults.standard.set(level, forKey: "pulselevel")
}
func readPulseLevelPreferences() -> Int {
    return UserDefaults.standard.integer(forKey: "pulselevel")
}

func savePreferencesPulse(bpm: Int) {
    UserDefaults.standard.set(bpm, forKey: "pulsebpm")
}
func readPulsePreferences() -> Int {
    return UserDefaults.standard.integer(forKey: "pulsebpm")
}

func savePreferencesNotShowPulseHelp(notshow: Bool) {
    UserDefaults.standard.set(notshow, forKey: "notshowpulsehelp")
}
func readNotShowPulseHelpPreferences() -> Bool {
    return UserDefaults.standard.bool(forKey: "notshowpulsehelp")
}

func savePreferencesNotShowBreathHelp(notshow: Bool) {
    UserDefaults.standard.set(notshow, forKey: "notshowbreathhelp")
}
func readNotShowBreathHelpPreferences() -> Bool {
    return UserDefaults.standard.bool(forKey: "notshowbreathhelp")
}
