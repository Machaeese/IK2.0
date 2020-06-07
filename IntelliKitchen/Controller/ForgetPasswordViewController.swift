//
//  ForgetPasswordViewController.swift
//  UserLoginAndRegister
//
//  Created by Emily Xu on 4/30/20.
//  Copyright © 2020 Emily Xu. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgetPasswordViewController: UIViewController {
    
    // reference and global variable
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var message: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.styleTextField(textfield: emailTextField)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            message.alpha = 1
            message.textColor = UIColor.init(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
            message.text = "Please fill in your email"
        }
        else{
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if error == nil{
                    self.message.alpha = 1
                    self.message.textColor = UIColor.init(red: 146/255, green: 170/255, blue: 68/255, alpha: 1)
                    self.message.text = "A link has been sent to your email!"
                }
                else{
                    self.message.alpha = 1
                    self.message.textColor = UIColor.init(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                    self.message.text = "Can't find the email"
                }
            }
        }
    }
}
