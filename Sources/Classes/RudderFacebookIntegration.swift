//
//  RudderFacebookIntegration.swift
//  RudderFacebook
//
//  Created by Pallab Maiti on 14/12/21.
//

import Foundation
import Rudder
import FBSDKCoreKit

class RudderFacebookIntegration: RSIntegration {
    var limitedDataUse: Bool?
    var dpoState: Int?
    var dpoCountry: Int?
    let events = ["identify", "track", "screen"]
    
    init(config: [String: Any], client: RSClient) {
        limitedDataUse = config["limitedDataUse"] as? Bool
        dpoState = config["dpoState"] as? Int
        if dpoState != 0, dpoState != 1000 {
            dpoState = 0
        }
        dpoCountry = config["dpoCountry"] as? Int
        if dpoCountry != 0, dpoCountry != 1 {
            dpoCountry = 0
        }
        if limitedDataUse == true, let country = self.dpoCountry, let state = self.dpoState {
            Settings.setDataProcessingOptions(["LDU"], country: Int32(country), state: Int32(state))
            RSLogger.logDebug("[FBSDKSettings setDataProcessingOptions:[LDU] country:\(country) state:\(state)]")
        } else {
            Settings.setDataProcessingOptions([])
            RSLogger.logDebug("[FBSDKSettings setDataProcessingOptions:[]]")
        }
    }
    
    
    func dump(_ message: RSMessage) {
        switch message.type {
        case "identify":
            let address = message.context?.traits?["address"] as? [String: Any]
            AppEvents.userID = message.userId
            AppEvents.shared.setUser(email: message.context?.traits?["email"] as? String, firstName: message.context?.traits?["firstName"] as? String, lastName: message.context?.traits?["lastName"] as? String, phone: message.context?.traits?["phone"] as? String, dateOfBirth: message.context?.traits?["birthday"] as? String, gender: message.context?.traits?["gender"] as? String, city: address?["city"] as? String, state: address?["state"] as? String, zip: address?["postalcode"] as? String, country: address?["country"] as? String)
        case "track":
            if let event = message.event {
                let index = event.index(event.startIndex, offsetBy: min(40, event.count))
                let truncatedEvent = String(event[..<index])
                if let revenue = RSFBUtility.extractRevenue(from: message.properties, revenueKey: "revenue") {
                    let currency = RSFBUtility.extractCurrency(from: message.properties, withKey: "currency")
                    AppEvents.logPurchase(revenue, currency: currency)
                    var properties = message.properties
                    properties?[AppEvents.ParameterName.currency.rawValue] = currency
                    AppEvents.logEvent(AppEvents.Name(rawValue: truncatedEvent), valueToSum: revenue, parameters: properties)
                } else {
                    AppEvents.logEvent(AppEvents.Name(rawValue: truncatedEvent), parameters: message.properties)
                }
            }
        case "screen":
            if let event = message.event {
                // FB Event Names must be <= 40 characters
                // 'Viewed' and 'Screen' with spaces take up 14
                let index = event.index(event.startIndex, offsetBy: min(26, event.count))
                let truncatedEvent = String(event[..<index])
                AppEvents.logEvent(AppEvents.Name(rawValue: "Viewed \(truncatedEvent) Screen"), parameters: message.properties)
            }
        default:
            RSLogger.logWarn("MessageType is not supported")
        }
    }
    
    func reset() {
        AppEvents.clearUserID()
        AppEvents.shared.clearUserData()
    }
    
    func flush() {
        
    }
}
