import CoreLocation
import MapKit
import SwiftUI

struct FacilitySearchView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    @StateObject private var viewModel = FacilitySearchViewModel()
    @StateObject private var locationService = UserLocationService()
    @State private var cameraPosition: MapCameraPosition = .region(Self.initialRegion)
    @State private var selectedFacility: MedicalFacility?

    var body: some View {
        ZStack(alignment: .bottom) {
            mapContent

            if viewModel.loadingState == .loading || viewModel.loadingState == .idle {
                ProgressView(text("facility.loading"))
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            controls
        }
        .background(Color(.systemBackground))
        .navigationTitle(text("facility.navigation_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await viewModel.loadFacilitiesIfNeeded()
            locationService.requestLocation()
        }
        .onChange(of: locationService.location) { _, location in
            guard let location else { return }
            moveCamera(to: location.coordinate)
        }
        .sheet(item: $selectedFacility) { facility in
            FacilityDetailSheet(
                facility: facility,
                distance: distance(to: facility),
                onOpenMap: { openInMaps(facility, directions: false) },
                onDirections: { openInMaps(facility, directions: true) }
            )
            .presentationDetents([.height(277)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(34)
            .presentationBackground(.ultraThinMaterial)
        }
        .alert(text("facility.location.alert_title"), isPresented: locationErrorPresented) {
            Button(text("common.confirm"), role: .cancel) {}
        } message: {
            Text(locationService.errorKey.map(text) ?? "")
        }
    }

    private var mapContent: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()

            ForEach(displayedFacilities) { facility in
                Annotation(facility.name, coordinate: facility.coordinate, anchor: .bottom) {
                    Button {
                        selectedFacility = facility
                    } label: {
                        Image(systemName: markerSymbol(for: facility))
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(Color.apayoGreen, in: Circle())
                            .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(facility.name), \(localizedCategory(for: facility))")
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .ignoresSafeArea(edges: .bottom)
    }

    private var controls: some View {
        HStack(alignment: .center) {
            Button(text("facility.search_nearby")) {
                locationService.requestLocation()
                if let coordinate = locationService.location?.coordinate {
                    moveCamera(to: coordinate)
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Color(.systemBackground), in: Capsule())
            .overlay { Capsule().stroke(Color.apayoGreen, lineWidth: 1) }

            Spacer()

            Button {
                locationService.requestLocation()
                if let coordinate = locationService.location?.coordinate {
                    moveCamera(to: coordinate)
                }
            } label: {
                Image(systemName: "location.north.fill")
                    .font(.headline)
                    .foregroundStyle(Color.apayoGreen)
                    .frame(width: 50, height: 50)
                    .background(Color(.systemBackground), in: Circle())
                    .shadow(color: .black.opacity(0.18), radius: 6, x: 2, y: 3)
            }
            .accessibilityLabel(text("facility.current_location"))
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 12)
    }

    private var displayedFacilities: [MedicalFacility] {
        let origin = locationService.location ?? CLLocation(latitude: 35.7866, longitude: 129.3315)
        return viewModel.facilities
            .sorted { distance(from: origin, to: $0) < distance(from: origin, to: $1) }
            .prefix(40)
            .map { $0 }
    }

    private var locationErrorPresented: Binding<Bool> {
        Binding(
            get: { locationService.errorKey != nil },
            set: { isPresented in
                if !isPresented { locationService.clearError() }
            }
        )
    }

    private func markerSymbol(for facility: MedicalFacility) -> String {
        facility.category == .hospital ? "cross.fill" : "pills.fill"
    }

    private func localizedCategory(for facility: MedicalFacility) -> String {
        text(facility.category == .hospital ? "facility.category.hospital" : "facility.category.pharmacy")
    }

    private func distance(to facility: MedicalFacility) -> CLLocationDistance? {
        guard let location = locationService.location else { return nil }
        return distance(from: location, to: facility)
    }

    private func distance(from origin: CLLocation, to facility: MedicalFacility) -> CLLocationDistance {
        origin.distance(from: CLLocation(latitude: facility.latitude, longitude: facility.longitude))
    }

    private func moveCamera(to coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    latitudinalMeters: 8_000,
                    longitudinalMeters: 8_000
                )
            )
        }
    }

    private func openInMaps(_ facility: MedicalFacility, directions: Bool) {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: facility.coordinate))
        item.name = facility.name
        let options: [String: Any] = directions
            ? [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            : [:]
        item.openInMaps(launchOptions: options)
    }

    private func text(_ key: String) -> String {
        languageStore.language.localized(key)
    }

    private static let initialRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.7866, longitude: 129.3315),
        latitudinalMeters: 18_000,
        longitudinalMeters: 18_000
    )
}

private struct FacilityDetailSheet: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    let facility: MedicalFacility
    let distance: CLLocationDistance?
    let onOpenMap: () -> Void
    let onDirections: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                Image("FacilityPlaceholder")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 98, height: 98)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                VStack(alignment: .leading, spacing: 9) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(facility.name)
                            .font(.title3.weight(.semibold))
                            .lineLimit(1)

                        if let distance {
                            Text(formattedDistance(distance))
                                .font(.headline)
                                .foregroundStyle(Color(red: 248 / 255, green: 107 / 255, blue: 107 / 255))
                        }
                    }

                    detailRow(title: text("facility.type"), value: localizedCategory)
                    detailRow(title: text("facility.departments"), value: facility.departments.first ?? text("facility.no_information"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 10) {
                actionButton(text("facility.directions"), action: onDirections)
                actionButton(text("facility.open_map"), action: onOpenMap)
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 8)
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Text(title)
                .font(.callout.weight(.semibold))
                .frame(width: 66, alignment: .leading)
            Text(value)
                .font(.callout)
                .foregroundStyle(Color.apayoGray800)
                .lineLimit(1)
        }
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color.apayoGreen, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func formattedDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1_000 { return "\(Int(distance.rounded()))m" }
        return String(format: "%.1fkm", distance / 1_000)
    }


    private var localizedCategory: String {
        text(facility.category == .hospital ? "facility.category.hospital" : "facility.category.pharmacy")
    }

    private func text(_ key: String) -> String {
        languageStore.language.localized(key)
    }
}

#Preview {
    NavigationStack {
        FacilitySearchView()
    }
    .environmentObject(AppLanguageStore())
}
