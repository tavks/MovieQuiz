import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    private let statisticService: StatisticServiceProtocol = StatisticService()
    weak var viewController: MovieQuizViewControllerProtocol?
    var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let nextQuestion = question else { return }
        currentQuestion = nextQuestion
        let viewModel = convert(model: nextQuestion)
        viewController?.show(quiz: viewModel)
    }
    
    func setup() {
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.question,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func makeResultsViewModel() -> QuizResultsViewModel {
        let bestGame = statisticService.bestGame
        let dateString = bestGame.date.dateTimeString
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        
        return QuizResultsViewModel(title: "Этот раунд окончен!",
                                    text: """
                                    Ваш результат: \(correctAnswers)/\(questionsAmount)
                                    Количество сыгранных квизов: \(statisticService.gamesCount)
                                    Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateString))
                                    Средняя точность: \(accuracy)%
                                    """,
                                    buttonText: "Сыграть ещё раз")
    }
    
    private func proceedToNextQuestionOrResults() {
        viewController?.removeImageBorder()
        viewController?.switchButtonState(isEnabled: true)
        if isLastQuestion() {
            statisticService.store(result: GameResult(correct: correctAnswers, total: 10, date: Date()))
            let viewModel = makeResultsViewModel()
            viewController?.resultAlertPresenter?.showResultAlert(result: viewModel, completion: { [weak self] in
                guard let self else { return }
                resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            })
        } else {
            switchToNextQuestion()
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
            viewController?.hideLoadingIndicator()
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        if givenAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        viewController?.switchButtonState(isEnabled: false)
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
}
