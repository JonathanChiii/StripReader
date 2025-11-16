//
//  BarResult.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/15/25.
//

import Foundation
import UIKit

struct BarResult: Identifiable {
    let id = UUID()
    let index: Int
    let intensity: CGFloat
    let color: UIColor
}
