//
//  AppParameters.swift
//  LFC
//
//  Created by Admin on 22.09.16.
//  Copyright © 2016 bondar. All rights reserved.
//

import UIKit

class AppParameters: NSObject {
    static let sharedInstance:AppParameters = {
        let instance = AppParameters()
        return instance
    }()
    
    let flikrKey = "7910c73df5e7c958b9e3a534170b7c1b"
    let flikrSecret = "103ee5a29af20d4b"
    
    var standartBBOX = "-180,-90,180,90"
    let pageLimit = 30
    
    private override init()
    {
        
    }
    
}
