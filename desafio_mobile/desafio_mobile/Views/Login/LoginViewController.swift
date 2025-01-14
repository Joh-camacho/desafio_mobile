//
//  LoginViewController.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 28/11/22.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let viewModel: LoginViewModel
    
    // MARK: - Init
    init(viewModel: LoginViewModel = LoginViewModel()) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle screen
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        viewModel.delegate = self
        
        initializeHideKeyboard()
    }
}

// MARK: - IBActions
extension LoginViewController {
    
    @IBAction func loginButtonTouched() {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        disableInteractions()
        
        viewModel.loginUser(email: email, password: password)
    }
    
    @IBAction func signUpButtonTouched() {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        disableInteractions()
        
        viewModel.registerUser(email: email, password: password)
    }
}

// MARK: - Private functions
extension LoginViewController {
    
    private func presentHome() {
        let homeVC = HomeViewController()
        homeVC.modalPresentationStyle = .fullScreen
        
        present(homeVC, animated: true)
    }
    
    private func enableInteractions() {
        view.isUserInteractionEnabled = true
    }
    
    private func disableInteractions() {
        view.isUserInteractionEnabled = false
    }
    
    private func initializeHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        default:
            passwordTextField.resignFirstResponder()
            
            loginButtonTouched()
        }

        return true
    }
    
}

// MARK: - LoginViewDelegate
extension LoginViewController: LoginViewDelegate {
    
    func authService(didAuthenticate user: User) {
        presentHome()
        
        enableInteractions()
    }
    
    func authService(didFailToAuthorizeWith error: Error) {
        presentAlert(withError: error)
        
        enableInteractions()
    }
}
