//
//  Font+Poppins.swift
//  Fraud Fishing
//
//  Created by Javier Canella Ramos on 27/09/25.
//

import Foundation

import SwiftUI

extension Font {
    static func poppinsRegular(size: CGFloat) -> Font {
        return .custom("Poppins-Regular", size: size)
    }
    
    static func poppinsMedium(size:  CGFloat) -> Font {
        return .custom("Poppins-Medium", size: size)
    }

    static func poppinsBold(size: CGFloat) -> Font {
        return .custom("Poppins-Bold", size: size)
    }
    
    static func poppinsSemiBold(size: CGFloat) -> Font {
        return .custom("Poppins-SemiBold", size: size)
    }
}
