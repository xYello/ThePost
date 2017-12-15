//
//  Int+MilesAndMeters.swift
//  The Wave
//
//  Created by Andrew Robinson on 12/15/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import Foundation

extension Int {

    func toMeters() -> Int {
        return Int(Double(self) / 0.00062137)
    }

    func toMiles() -> Int {
        return self / 1609
    }

}
