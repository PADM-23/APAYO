import CoreLocation
import Foundation

enum MedicalFacilityCategory: String, Codable, Hashable, Sendable {
    case hospital
    case pharmacy
}

struct MedicalFacility: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let category: MedicalFacilityCategory
    let name: String
    let type: String
    let district: String
    let address: String
    let phone: String?
    let latitude: Double
    let longitude: Double
    let departments: [String]

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
