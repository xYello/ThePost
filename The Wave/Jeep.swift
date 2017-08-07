//
//  Jeep.swift
//  ThePost
//
//  Created by Andrew Robinson on 12/26/16.
//  Copyright © 2016 XYello, Inc. All rights reserved.
//

import UIKit

enum JeepModel: Int {
    case all = 0
    case wranglerJK
    case wranglerTJ
    case wranglerYJ
    case cherokeeCJ
    case cherokeeXJ
    
    var name: String {
        switch self {
        case .all: return "General"
        case .wranglerJK: return "Jeep Wrangler JK/JKU"
        case .wranglerTJ: return "Jeep Wrangler TJ"
        case .wranglerYJ: return "Jeep Wrangler YJ"
        case .cherokeeCJ: return "Jeep Cherokee CJ"
        case .cherokeeXJ: return "Jeep Cherokee XJ"
        }
    }

    var shortDescription: String {
        switch self {
        case .all: return "General"
        case .wranglerJK: return "JK/JKU"
        case .wranglerTJ: return "TJ"
        case .wranglerYJ: return "YJ"
        case .cherokeeCJ: return "CJ"
        case .cherokeeXJ: return "XJ"
        }
    }
    
    static var count: Int { return JeepModel.cherokeeXJ.hashValue + 1 }
    
    static func enumFromString(string: String) -> JeepModel {
        switch string {
        case JeepModel.wranglerJK.name: return JeepModel.wranglerJK
        case JeepModel.wranglerTJ.name: return JeepModel.wranglerTJ
        case JeepModel.wranglerYJ.name: return JeepModel.wranglerYJ
        case JeepModel.cherokeeCJ.name: return JeepModel.cherokeeCJ
        case JeepModel.cherokeeXJ.name: return JeepModel.cherokeeXJ
        default: return JeepModel.all
        }
    }

    static func arrayOfStrings() -> [String] {
        return [JeepModel.all.name,
                JeepModel.wranglerJK.name,
                JeepModel.wranglerTJ.name,
                JeepModel.wranglerYJ.name,
                JeepModel.cherokeeCJ.name,
                JeepModel.cherokeeXJ.name]
    }
}

class Jeep: NSObject {
    
    var type: JeepModel! {
        didSet {
            evaluateType(type: type)
        }
    }
    
    private(set) var image: UIImage?
    private(set) var name: String?
    private(set) var startYear: Int?
    private(set) var endYear: Int?
    private(set) var isInProduction = false {
        didSet {
            if isInProduction {
                let components = Calendar.current.dateComponents([.year], from: Date())
                endYear = components.year
            }
        }
    }
    
    init(withType type: JeepModel) {
        super.init()
        
        defer {
            self.type = type
        }
    }
    
    private func evaluateType(type: JeepModel) {
        switch type {
        case .all:
            image = UIImage(named: "AllDuhJeeps")!
            name = "All Jeeps"
        case .wranglerJK:
            image = UIImage(named: "JKGrillIcon")!
            name = JeepModel.wranglerJK.name
            startYear = 2007
            isInProduction = true
        case .wranglerTJ:
            image = UIImage(named: "TJGrillIcon")!
            name = JeepModel.wranglerTJ.name
            startYear = 1997
            endYear = 2006
        case .wranglerYJ:
            image = UIImage(named: "YJGrillIcon")!
            name = JeepModel.wranglerYJ.name
            startYear = 1987
            endYear = 1995
        case .cherokeeCJ:
            image = UIImage(named: "CJGrillIcon")!
            name = JeepModel.cherokeeCJ.name
            startYear = 1944
            endYear = 1986
        case .cherokeeXJ:
            image = UIImage(named: "XJGrillIcon")!
            name = JeepModel.cherokeeXJ.name
            startYear = 1984
            endYear = 1996
        }
        
    }

}
