import Foundation
import CoreLocation

struct Mission: Identifiable, Codable {
    let id: UUID
    var name: String
    var points: [CLLocationCoordinate2D]
    
    init(id: UUID = UUID(), name: String, points: [CLLocationCoordinate2D]) {
        self.id = id
        self.name = name
        self.points = points
    }
}

extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: CodingKey {
        case latitude, longitude
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}