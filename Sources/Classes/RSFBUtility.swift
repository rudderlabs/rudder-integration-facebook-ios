//
//  RSFBUtility.swift
//  RudderFacebook
//
//  Created by Pallab Maiti on 15/12/21.
//

import Foundation

class RSFBUtility {
    static func extractRevenue(from properties: [String: Any]?, revenueKey: String) -> Double? {
        if let properties = properties {
            for key in properties.keys {
                if key.caseInsensitiveCompare(revenueKey) == .orderedSame {
                    if let revenue = properties[key] {
                        return Double("\(revenue)")
                    }
                    break
                }
            }
        }
        return nil
    }
    
    static func extractCurrency(from properties: [String: Any]?, withKey currencyKey: String) -> String {
        if let properties = properties {
            for key in properties.keys {
                if key.caseInsensitiveCompare(currencyKey) == .orderedSame {
                    if let currency = properties[key] {
                        return "\(currency)"
                    }
                    break
                }
            }
        }
        // default to USD
        return "USD"
    }
}
