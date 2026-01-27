//
//  Concentration.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 1/7/26.
//


enum Concentration: String, Identifiable {
    case ng0    = "0 µg/mL"
    case ug0_1  = "0.1 µg/mL"
    case ug1    = "1 µg/mL"
    case ug10   = "10 µg/mL"
    case ug100  = "100 µg/mL"
    case mg1    = "1000 µg/mL"
    case mg5    = "5000 µg/mL"
    case error  = "error"

    var id: String { rawValue }
}
