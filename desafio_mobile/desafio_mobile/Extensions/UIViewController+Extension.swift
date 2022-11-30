//
//  UIViewController+Extensions.swift
//  desafio_mobile
//
//  Created by Johnny Camacho on 29/11/22.
//

import UIKit

extension UIViewController {
    
    func presentAlert(withMessage message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel)
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    func presentAlert(withError error: Error) {
        
        print(error)
        
        presentAlert(withMessage: error.localizedDescription)
    }
}
