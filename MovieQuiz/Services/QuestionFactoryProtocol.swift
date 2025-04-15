protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData()
    var delegate: QuestionFactoryDelegate? { get set }
}
