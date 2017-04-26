//
//  AppUtils.swift
//  foodwhim
//
//  Created by Erik Yang on 4/26/17.
//  Copyright © 2017 Erik Yang. All rights reserved.
//

import Foundation

//random array id helper method
func randomArrayId(input: Int) -> Int{
    return Int(arc4random_uniform(UInt32(input)))
}
