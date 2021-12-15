//
//  RudderFacebookFactory.swift
//  RudderFacebook
//
//  Created by Pallab Maiti on 14/12/21.
//

import Foundation
import Rudder

@objc
open class RudderFacebookFactory: NSObject, RSIntegrationFactory {
        
    @objc
    public static func instance() -> RSIntegrationFactory {
        return RudderFacebookFactory()
    }
    
    @objc
    public func initiate(_ config: [String : Any], client: RSClient, rudderConfig: RSConfig) -> RSIntegration {
        return RudderFacebookIntegration(config: config, client: client)
    }
    
    @objc
    public var key: String = "Facebook App Events"
    
    
}
