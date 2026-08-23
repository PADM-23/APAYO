import Foundation

enum MedicalFacilityDataLoaderError: LocalizedError {
    case resourceNotFound
    case unreadableData(Error)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .resourceNotFound:
            return "GyeongbukMedicalFacilities.json을 앱 번들에서 찾을 수 없습니다."
        case .unreadableData(let error):
            return "의료시설 데이터 파일을 읽을 수 없습니다: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "의료시설 데이터 형식이 올바르지 않습니다: \(error.localizedDescription)"
        }
    }
}

enum MedicalFacilityDataLoader {
    nonisolated static func load(from bundle: Bundle = .main) throws -> [MedicalFacility] {
        guard let url = bundle.url(
            forResource: "GyeongbukMedicalFacilities",
            withExtension: "json"
        ) else {
            throw MedicalFacilityDataLoaderError.resourceNotFound
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw MedicalFacilityDataLoaderError.unreadableData(error)
        }

        do {
            return try JSONDecoder().decode([MedicalFacility].self, from: data)
        } catch {
            throw MedicalFacilityDataLoaderError.decodingFailed(error)
        }
    }
}
