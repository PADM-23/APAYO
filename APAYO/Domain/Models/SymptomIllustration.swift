import SwiftUI

enum SymptomIllustration: String, CaseIterable, Identifiable {
    case chestTightness = "ChestTightness"
    case chills = "Chills"
    case cough = "Cough"
    case dizziness = "Dizziness"
    case headache = "Headache"
    case hives = "Hives"
    case stomachache = "Stomachache"
    case toothache = "Toothache"
    case vomiting = "Vomiting"

    var id: Self { self }
    var image: Image { Image("SymptomCards/\(rawValue)") }
}

#Preview("Symptom illustrations") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))]) {
            ForEach(SymptomIllustration.allCases) { symptom in
                symptom.image
                    .resizable()
                    .scaledToFit()
                    .background(Color.apayoBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
        }
        .padding()
    }
}
