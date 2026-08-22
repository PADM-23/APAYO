import Foundation

enum PreviewMockData {
    static let symptom = "어제부터 머리가 아프고 어지러워요."

    static let durationOptions = ["duration.today", "duration.days", "duration.week", "duration.weeks", "duration.month"]
    static let frequencyOptions = ["frequency.constant", "frequency.intermittent", "frequency.activity", "frequency.rest"]
    static let accompanyingOptions = ["accompanying.dizzy", "accompanying.nausea", "accompanying.chest", "accompanying.cramp", "accompanying.fever", "accompanying.rash", "choice.none"]
    static let medicationOptions = ["medication.painkiller", "medication.digestive", "medication.relaxant", "medication.chronic", "choice.none"]

    static let workQuestion = InterviewQuestion(
        title: "오늘 어떤 작업을 했나요?",
        subtitle: "증상과 관련 있을 수 있는 작업을 선택해 주세요.",
        options: [
            QuestionOption(id: "outdoor", title: "더운 야외에서 일했어요", systemImage: "sun.max.fill"),
            QuestionOption(id: "chemical", title: "농약을 사용했어요", systemImage: "leaf.fill"),
            QuestionOption(id: "machine", title: "기계를 사용했어요", systemImage: "gearshape.fill"),
            QuestionOption(id: "none", title: "해당 사항이 없어요", systemImage: "xmark.circle")
        ]
    )
}
