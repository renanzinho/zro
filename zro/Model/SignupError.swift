//
//  SignupError.swift
//  zro
//
//  Created by rfl3 on 30/09/20.
//  Copyright © 2020 renacio. All rights reserved.
//

import Foundation

struct SignupErrorObject: Codable {

    var code: String
    var field: String
    var message: String

}

struct SignupError: Codable {

    var errors: [SignupErrorObject]

}
