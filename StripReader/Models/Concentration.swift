enum Concentration: String, CaseIterable, Identifiable {
    case mg1 = "1 mg/mL"
    case mg0_1 = "0.1 mg/mL"
    case ug10 = "10 µg/mL"
    case ug1 = "1 µg/mL"
    case ug0_1 = "0.1 µg/mL"
    case ng10 = "10 ng/mL"
    case ng0 = "0 ng/mL (Control)"

    var id: String { rawValue }
}
