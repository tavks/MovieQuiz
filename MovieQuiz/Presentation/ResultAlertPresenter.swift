import UIKit

final class ResultAlertPresenter {
    weak var delegate: UIViewController?
    
    func showResultAlert(result: QuizResultsViewModel, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default
        ) { _ in
            completion()
        }
        
        alert.addAction(action)
        
        delegate?.present(alert, animated: true)
    }
}
