import Combine
import Foundation

@MainActor
final class FacilitySearchViewModel: ObservableObject {
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var facilities: [MedicalFacility] = []
    @Published private(set) var loadingState: LoadingState = .idle

    var hospitals: [MedicalFacility] {
        facilities.filter { $0.category == .hospital }
    }

    var pharmacies: [MedicalFacility] {
        facilities.filter { $0.category == .pharmacy }
    }

    func loadFacilitiesIfNeeded() async {
        guard loadingState == .idle else { return }
        loadingState = .loading

        do {
            facilities = try await Task.detached(priority: .userInitiated) {
                try MedicalFacilityDataLoader.load()
            }.value
            loadingState = .loaded
        } catch {
            loadingState = .failed(error.localizedDescription)
        }
    }
}
