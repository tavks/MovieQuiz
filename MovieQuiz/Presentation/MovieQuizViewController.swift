import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    var resultAlertPresenter: ResultAlertPresenter? { get set }
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func switchButtonState(isEnabled: Bool)
    func removeImageBorder()
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    var resultAlertPresenter: ResultAlertPresenter?
    private var presenter: MovieQuizPresenter?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageViewBorders()
        resultAlertPresenter = ResultAlertPresenter()
        resultAlertPresenter?.delegate = self
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
        presenter?.setup()
        activityIndicator.hidesWhenStopped = true
    }
    
    private func setupImageViewBorders() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = 20
    }
    
    func switchButtonState(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
        yesButton.alpha = isEnabled ? 1.0 : 0.5
        noButton.alpha = isEnabled ? 1.0 : 0.5
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) {[weak self] _ in
            guard let self else { return }
            presenter?.resetQuestionIndex()
            presenter?.questionFactory?.requestNextQuestion()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        let borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.borderColor = borderColor
    }
    
    func removeImageBorder() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.color = .ypBlack
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Невозможно загрузить данные",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: "Попробовать еще раз",
            style: .default
        ) { [self]_ in
            self.showLoadingIndicator()
            presenter?.questionFactory?.loadData()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
}
