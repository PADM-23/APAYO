import Foundation

enum PreviewMockData {
    static let symptom = "어제부터 머리가 아프고 어지러워요."

    static let durationOptions = ["오늘 갑자기", "최근 2-3일 전", "지난주부터", "2-3주 전부터", "한 달 이상 전부터 (오래전부터)"]
    static let frequencyOptions = ["쉴 때도 계속 아파요", "아팠다 안 아팠다 반복돼요", "작업·활동할 때 더 심해져요", "푹 쉬면 통증이 가라앉아요"]
    static let accompanyingOptions = ["어지럽거나\n두통이 있음", "메스껍거나\n구토를 함", "가슴이 답답하고\n숨이 참", "근육 쥐 남 경련", "열 남 오한", "피부 발진", "증상 없음"]
    static let medicationOptions = ["해열 진통제", "소화제", "근육 이완제", "기저질환 약", "증상 없음"]

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
