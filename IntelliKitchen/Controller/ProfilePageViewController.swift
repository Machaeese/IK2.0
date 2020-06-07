//
//  ProfilePageViewController.swift
//  IntellK_Profile_Page
//
//  Created by zhangjm on 5/19/20.
//  Copyright © 2020 zhangjm. All rights reserved.
//

import UIKit
import FirebaseAuth
import UserNotifications
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage

class ProfilePageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var saveUsername: UIButton!
    @IBOutlet weak var favRecipeAlert: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var favoriteRecipes:[FavoriteRecipe] = []
    var favoriteIDList:[String] = []
    
    static var systemNotification = false
    var databaseNotification = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()
        myImageView?.layer.borderWidth = 1
        myImageView?.layer.masksToBounds = false
        myImageView?.layer.borderColor = UIColor.black.cgColor
        myImageView?.layer.cornerRadius = myImageView.frame.height/2
        myImageView?.clipsToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func loadUserInfo(){
        let db = Firestore.firestore()
        
        let tempGoogleUsername = GlobalVariable.googleUsername
        let tempGoogleEmail = GlobalVariable.googleEmail
        let tempGoogleIconUrl = GlobalVariable.googleIconUrl
        
        //handle google log in
        if tempGoogleUsername != "" && tempGoogleEmail != ""{
            self.userName?.text = tempGoogleUsername
            
            self.userEmail?.text = tempGoogleEmail
            
            guard let imageURL = tempGoogleIconUrl else { return  }
            
            DispatchQueue.global().async {
                guard let imageData = try? Data(contentsOf: imageURL) else { return }
                
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    self.myImageView?.image = image
                    self.uploadProfileImage(image!){(url) in
                        
                    }
                }
            }
            let currentUid = Auth.auth().currentUser!.uid
            
            db.collection("users").document(currentUid).collection("favoriteRecipe").getDocuments{ (snapshot, error) in
                for document in snapshot!.documents{
                    let documentData = document.data()
                    self.favoriteIDList = documentData["favRecipe"] as! [String]
                    if self.favoriteIDList.count == 0{
                        self.favRecipeAlert?.text = "Add Some Favorite while Searching"
                    } else {
                        self.favRecipeAlert?.text = "My Favorite Recipes:"
                        
                    }
                    self.favoriteRecipes = self.createArray(self.favoriteIDList)
                }
            }
            
            db.collection("users").document(currentUid).setData(["username":tempGoogleUsername, "email":tempGoogleEmail, "uid": currentUid]) { (error) in
                if error != nil{
                    print(" error when saving google sign in information")
                }
            }
            //handle normal login
        } else {
            let currentUid = Auth.auth().currentUser!.uid
            db.collection("users").document(currentUid).getDocument { (document, error) in
                if error == nil {
                    if document != nil && document!.exists {
                        let documentData = document?.data()
                        
                        self.userName?.text = documentData?["username"] as? String
                        self.userEmail?.text = documentData?["email"] as? String
                        self.loadImageFromFirebase()
                        
                    } else {
                        print("Can read the document but the document might not exists")
                    }
                    
                } else {
                    print("Something wrong reading the document")
                }
            }
            db.collection("users").document(currentUid).collection("favoriteRecipe").getDocuments{ (snapshot, error) in
                for document in snapshot!.documents{
                    let documentData = document.data()
                    self.favoriteIDList = documentData["favRecipe"] as! [String]
                    if self.favoriteIDList.count == 0{
                        self.favRecipeAlert?.text = "Add Some Favorite while Searching"
                    } else {
                        self.favRecipeAlert?.text = "My Favorite Recipes:"
                    }
                    self.favoriteRecipes = self.createArray(self.favoriteIDList)
                }
            }
        }
    }
    
    func createArray(_ favoriteIDList: [String]) -> [FavoriteRecipe]{
        var temp: [FavoriteRecipe] = []
        
        retrieveFR(favoriteIDList, completion: {searchedRecipes in
            self.favoriteRecipes = searchedRecipes
            self.tableView?.reloadData()
        })
        
        return temp
    }
    
    func retrieveFR(_ favoriteIDList: [String], completion: @escaping (_ searchedRecipes: [FavoriteRecipe]) -> Void){
        let ref = Database.database().reference()
        var temp: [FavoriteRecipe] = []
        
        for recipe in favoriteIDList{
            let currentRecipeString = "Recipe/-M8IVR-st6dljGq6M4xN/" + recipe
            let recipeRef = ref.child(currentRecipeString)
            recipeRef.observe(.value, with: {snapshot in
                let snap = snapshot as! DataSnapshot
                if let dict = snap.value as? [String: Any]{
                    var currentImage = UIImage()
                    var urlString = try! dict["img"] as? String
                    if urlString == nil {
                        urlString = try! dict["recipe_pic"] as! String
                    }
                    if urlString == nil {
                        currentImage = UIImage(imageLiteralResourceName: "RecipeImage.jpg")
                    } else {
                        var imageUrl = URL(string: urlString!)
                        let imageData = try! Data(contentsOf: imageUrl!)
                        currentImage = UIImage(data: imageData)!
                    }
                    var currentTitle = dict["recipe_name"] as! String
                    let tempFR = FavoriteRecipe(image: currentImage, title: currentTitle)
                    temp.append(tempFR)
                }
                completion(temp)
            })
        }
    }
    
    @IBAction func showOrHidePassword(_ sender: Any) {
        let tempGoogleUsername = GlobalVariable.googleUsername
        let tempGoogleEmail = GlobalVariable.googleEmail
        
        if tempGoogleUsername != "" && tempGoogleEmail != ""{
            self.createAlert(title: "Notice", message: "You may not change your password by signing in with Google")
        }
        else{
            let email = Auth.auth().currentUser?.email
            
            Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
                if error == nil{
                    self.createAlertSignOut(title: "Success", message: "A link has been sent to your email!")
                }
                else{
                    self.createAlert(title: "Oops!", message: "There‘s something wrong. Please try again.")
                }
            }
        }
    }
    
    func createAlertSignOut(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
            self.signoutTapped((Any).self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func importImage(_ sender: Any) {
        let tempGoogleUsername = GlobalVariable.googleUsername
        let tempGoogleEmail = GlobalVariable.googleEmail
        
        if tempGoogleUsername != "" && tempGoogleEmail != ""{
            self.createAlert(title: "Notice", message: "You may not change your profile photo by signing in with Google")
        }
        else{
            //Given the user the opportunity to pick a picture.
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.photoLibrary
            image.allowsEditing = false
            
            self.present(image, animated: true){
                //After it is complete.
            }
        }
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let storageRef = Storage.storage().reference().child("users/\(uid)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) {metaData, error in
            if error == nil, metaData != nil {
                //if let url = storageRef.downloadURL(completion: (URL?, Error?) -> Void){
                completion(nil)
                
            } else {
                completion(nil)
            }
            //success
        }
    }
    
    func loadImageFromFirebase(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let storageRef = Storage.storage().reference().child("users/\(uid)")
        storageRef.getData(maxSize: 1*65536*65536) {data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                // Data for "images/island.jpg" is returned
                self.myImageView?.image = UIImage(data: data!)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            myImageView.image = image
            self.uploadProfileImage(image){(url) in
                
            }
        }
        else{
            //error message
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveUsernameAction(_ sender: Any) {
        let tempGoogleUsername = GlobalVariable.googleUsername
        let tempGoogleEmail = GlobalVariable.googleEmail
        
        if tempGoogleUsername != "" && tempGoogleEmail != ""{
            self.createAlert(title: "Notice", message: "You may not change your username by signing in with Google")
        }
        else{
            let db = Firestore.firestore()
            let currentUid = Auth.auth().currentUser!.uid
            let updateString = self.userName!.text
            db.collection("users").document(currentUid).updateData(["username": updateString])
        }
        self.createAlert(title: "Notice", message: "Sucessfully save the username")
    }
    
    @IBAction func switchNotificationControl(_ sender: Any) {
        let currentUid = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
        let content = UNMutableNotificationContent()
        let date = Date().addingTimeInterval(8)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        if((sender as AnyObject).isOn == true){
            content.title = "I'm the notification"
            content.body = "Your food is about to expire!"
            ProfilePageViewController.systemNotification = true
            db.collection("users").document(currentUid).collection("notificationCollection").document("notificationDocument").setData(["commentedlist": "true"])
        }
        else{
            content.title = "I'm the notification"
            content.body = "you closed the notification!"
            ProfilePageViewController.systemNotification = false
            db.collection("users").document(currentUid).collection("notificationCollection").document("notificationDocument").setData(["commentedlist": "false"])
        }
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        center.add(request) { (error) in }
    }
    
    
    
    
    @IBAction func signoutTapped(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let loginController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginController) as? LoginController
        view.window?.rootViewController = loginController
        view.window?.makeKeyAndVisible()
        
        GlobalVariable.googleUsername = ""
        GlobalVariable.googleEmail = ""
        
        GlobalVariable.googleIconUrl = URL(string: "")
    }
}

