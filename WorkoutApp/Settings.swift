//
//  Settings.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/20/24.
//

import Foundation
import UIKit

struct Settings {
    static var shared = Settings()
    private let defaults = UserDefaults.standard
    
    private func archiveJSON<T: Encodable>(value: T, key: String) {
        let data = try! JSONEncoder().encode(value)
        let string = String(data: data, encoding: .utf8)
        defaults.set(string, forKey: key)
    }
    
    private func unarchiveJSON<T: Decodable>(key: String) -> T? {
        guard let string = defaults.string(forKey: key),
              let data = string.data(using: .utf8) else {
            return nil
        }
        
        return try! JSONDecoder().decode(T.self, from: data)
    }

    var weightUnit: WeightType {
        get {
            return unarchiveJSON(key: "weightUnit") ?? .lbs
        }
        set {
            archiveJSON(value: newValue, key: "weightUnit")
        }
    }
    
    var showTimer: Bool {
        get {
            return unarchiveJSON(key: "showTimer") ?? true
        }
        set {
            archiveJSON(value: newValue, key: "showTimer")
        }
    }
    
    var weightIncrement: Float {
        let lbs: Float = 5
        let kg: Float = 2.5
        return weightUnit == .lbs ? lbs : kg
    }
    
    var theme: UIUserInterfaceStyle {
        get {
            return unarchiveJSON(key: "theme") ?? .unspecified
        }
        set {
            archiveJSON(value: newValue, key: "theme")
        }
    }
}

extension UIUserInterfaceStyle: Codable, CaseIterable {
    public static var allCases: [UIUserInterfaceStyle] = [.unspecified, .light, .dark]
    static let valueChangedNotification = Notification.Name("Theme.ValueChangedNotification")
    
    var description: String {
        switch self {
        case .unspecified:
            return "Automatic"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        @unknown default:
            return "Automatic"
        }
    }
}