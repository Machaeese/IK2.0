//
//  LoginCon.swift
//  UserLoginAndRegister
//
//  Created by Emily Xu on 5/7/20.
//  Copyright © 2020 Emily Xu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseDatabase

class LoginController: UIViewController, GIDSignInDelegate{
    
    // all the global varaible and reference
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var googleButton: GIDSignInButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        //validate Text Fields
        let error = validateFields()
        //There's something is wrong
        if error != nil{
            showError(error!)
        }
        else{
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            //Signing the user
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error != nil{
                    let errorMessage = error!.localizedDescription
                    self.errorLabel.text = errorMessage.split(separator: ".")[0] + "."
                    self.errorLabel.textColor = UIColor.init(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                }
                else{
                    let homepageFoodController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homepageFoodController) as? FoodViewController
                    self.view.window?.rootViewController = homepageFoodController
                    self.view.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    // check the fields and validate the data is correct. If everything is correct, return nill. Otherwise, return error massage
    func validateFields() -> String? {
        // check that all fields are filled
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            return "Please fill in all fields."
        }
        return nil
    }
    
    func showError(_ message:String){
        errorLabel.text = message
        errorLabel.textColor = UIColor.init(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
    }
    
    //Google Signin
    @IBAction func googleTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            self.errorLabel.text = error.localizedDescription
            self.errorLabel.textColor = UIColor.init(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            if let error = error {
                self.errorLabel.text = error.localizedDescription
                self.errorLabel.textColor = UIColor.init(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
            }
            else {
                let ProfileController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.profileController) as? ProfilePageViewController
                self.view.window?.rootViewController = ProfileController
                self.view.window?.makeKeyAndVisible()
            }
        }
        
        // Perform any operations on signed in user here.
        GlobalVariable.googleUsername = user.profile.name
        GlobalVariable.googleEmail = user.profile.email
        GlobalVariable.googleIconUrl = user.profile.imageURL(withDimension: 400)
    }
    
    func getGoogleUsername() -> String {
        return GlobalVariable.googleUsername
    }
    
    func getGoogleEmail() -> String {
        return GlobalVariable.googleEmail
    }
    
    func getGoogleIconUrl() -> URL? {
        return GlobalVariable.googleIconUrl
    }
}
