//
//  LoginViewController.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 28/11/22.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonTouched() {
        print("Login")
    }
}
