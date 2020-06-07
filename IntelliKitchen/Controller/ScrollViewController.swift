//
//  ScrollViewController.swift
//  intellik
//
//  Created by 江南 on 5/5/20.
//  Copyright © 2020 江南. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import FirebaseAuth


class ScrollViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var stepsdisplay: UILabel!
    @IBOutlet weak var innerscroll: UIScrollView!
    
    //rating
    @IBOutlet weak var ratinglabel: UILabel!
    
    // title of the menu
    @IBOutlet weak var menutitle: UILabel!
    
    // ingredients container
    @IBOutlet weak var ingrescroll: UIScrollView!
    @IBOutlet weak var lefthalf: UILabel!
    @IBOutlet weak var righthalf: UILabel!
    
    // menu picture
    @IBOutlet weak var menupic: UIImageView!
    @IBOutlet weak var commentstableview: UITableView!
    @IBOutlet weak var submitdisplay: UIButton!
    @IBOutlet weak var Comments: UITextField!
    
    //favourite button
    @IBOutlet weak var FavouriteButton: UIButton!
    
    let db = Firestore.firestore()
    var currentUid: String = ""
    // varaibles for steps for the first recipe
    var passid = ""
    var mylist:[String] = []
    
    //favourite
    var favlist: [String] = []
    var favornot: Bool = false;
    var wholelist: String = "";
    
    var ingredientlist:[String] = [];
    var leftstring: String = "";
    var rightstring: String = "";
    var imageurl:URL!;
    
    // test comments
    //var ref = Database.database().reference().child("commentstest1")
    var username:String = ""
    var commentlist: [[String]] = [[]];
    var commentcelllist: [Comment] = [];
    
    var commentedlist: [String] = []
    var commentornot: Bool = false;
    
    // test ratings
    var ratingarray = [Double]()
    
    var infoUsername:[String:String] = [:]
    var infoPhoto:[String:Data] = [:]
    var tempname:[String] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        Comments.delegate = self
        stepsdisplay.sizeToFit();
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.touch))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.scrollview.addGestureRecognizer(recognizer)
        
        let rootRef = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/steps");
        let titledb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/recipe_name");
        let ingredientsdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/ingredients");
        var imagedb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/img");
        var imagedbnew = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/recipe_pic");
        var ratingdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/rating");
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.currentUid = Auth.auth().currentUser!.uid
        db.collection("users").document(currentUid).collection("favoriteRecipe").getDocuments { (snapshot, error) in
            for document in snapshot!.documents{
                let documentData = document.data()
                self.favlist = documentData["favRecipe"] as? [String] ?? []
                if self.favlist.contains(self.passid){
                    self.favornot = true
                }
                if self.favornot{
                    self.FavouriteButton.setImage(UIImage(named:"feather-heart"), for: .normal)
                }
                else{
                    self.FavouriteButton.setImage(UIImage(named:"Ellipse 2"), for: .normal)
                }
            }
        }
        
        //get rating
        ratingdb.observeSingleEvent(of: .value) { (snapshot) in
            var ratingtuple = snapshot.value as! [Int];
            var avrating = Double(ratingtuple[0])/Double(ratingtuple[1])
            self.ratinglabel.text = "Average Rating: " + String(format: "%.1f", avrating) + "     " + String(ratingtuple[1]) + " have rated"
        }
        
        
        //grab steps from db
        rootRef.observe(.value, with: { snapshot in
            self.mylist = snapshot.value as! [String];
            let length = self.mylist.count;
            
            for i in 0...length-1{
                self.wholelist = self.wholelist + String(i+1) + ". " + self.mylist[i]+"\n\n";
            }
            self.stepsdisplay.text = self.wholelist;
            self.innerscroll.contentLayoutGuide.bottomAnchor.constraint(equalTo: self.stepsdisplay.bottomAnchor).isActive = true
            
        })
        
        // grab menutitle
        titledb.observeSingleEvent(of: .value) { (snapshot) in
            self.menutitle.text = snapshot.value as! String;
            self.menutitle.text = (self.menutitle.text)?.capitalized;
        }
        
        // grab ingredients
        ingredientsdb.observe(.value) { (snapshot) in
            self.ingredientlist = snapshot.value as! [String];
            self.ingredientlist = (self.ingredientlist).removingDuplicates();
            let length2 = self.ingredientlist.count;
            for j in 0...length2-1{
                if (j%2 == 0) {
                    self.leftstring = self.leftstring + (self.ingredientlist[j]).capitalized + "\n";
                }
                else{
                    self.rightstring = self.rightstring + (self.ingredientlist[j]).capitalized + "\n";
                }
            }
            self.lefthalf.text = self.leftstring;
            self.righthalf.text = self.rightstring;
            self.ingrescroll.contentLayoutGuide.bottomAnchor.constraint(equalTo: self.lefthalf.bottomAnchor).isActive = true
            
        }
        
        // grab recipe photo
        imagedb.observeSingleEvent(of: .value) { (snapshot) in
            if(!(snapshot.value is NSNull)){
                self.imageurl = URL(string: snapshot.value as! String);
                self.menupic.load(url: self.imageurl);
                self.menupic.layer.cornerRadius = 10;
            }
            else{
                imagedbnew.observeSingleEvent(of: .value) { (snapshot) in
                    if(snapshot.value != nil){
                        self.imageurl = URL(string: snapshot.value as! String);
                        self.menupic.load(url: self.imageurl);
                        self.menupic.layer.cornerRadius = 10;
                    }
                }
            }
        }
        
        forloop();

        db.collection("users").document(currentUid).getDocument { (document, error) in
            if error == nil {
                if document != nil && document!.exists {
                    let documentData = document?.data()
                    self.commentedlist = documentData?["commentedlist"] as? [String] ?? []
                    if self.commentedlist.contains(self.passid){
                        self.commentornot = true
                    }
                } else {
                    print("Can read the document but the document might not exists")
                }
                
            } else {
                print("Something wrong reading the document")
            }
        }
        
    }
    
    @IBAction func clickRating(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
        let secondVC = storyboard.instantiateViewController(identifier: "Rating") as! RatingViewController
        secondVC.passid = self.passid
        self.present(secondVC, animated: true, completion: nil)
    }
    
    @IBAction func SubmitButton(_ sender: Any) {
        
        if (!self.commentornot){
            var commentdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/comments");
            commentcelllist.removeAll()
            commentlist.append([self.currentUid, Comments.text!]);
            commentdb.setValue(commentlist);
            commentedlist.append(passid)
            db.collection("users").document(currentUid).updateData(["commentedlist" : self.commentedlist])
            self.commentornot = true
            Comments.text = nil
//            Comments.resignFirstResponder()
        } else {
            //Comments.isEnabled = false
            let alert = UIAlertController(title: "Already commented", message: "You have already commented this recipe~", preferredStyle: UIAlertController.Style.alert)
            Comments.text = nil
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.submitdisplay.isEnabled = false
            self.submitdisplay.setTitleColor(.gray, for: .normal)
        }
    }
    
    
    @IBAction func ClickFavouriteButton(_ sender: Any) {
        
        if(!favornot) {
            FavouriteButton.setImage(UIImage(named:"feather-heart"), for: .normal)
            self.favlist.append(passid)
            db.collection("users").document(currentUid).collection("favoriteRecipe").document("favRecipeList").setData(["favRecipe": self.favlist])
            favornot = true
        }
        else{
            FavouriteButton.setImage(UIImage(named:"Ellipse 2"), for: .normal)
            let index = self.favlist.firstIndex(of: passid)
            self.favlist.remove(at: index!)
            db.collection("users").document(currentUid).collection("favoriteRecipe").document("favRecipeList").setData(["favRecipe": self.favlist])
            favornot = false
        }
    }
    
    @IBAction func backbutton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var nextstage = segue.destination as! RatingViewController
        nextstage.passid = self.passid
        
    }
    
    // generate the commentlist that including all the comments
    func beforeforloop(completion: @escaping (_ temptemp: [[String]]) ->Void){
        var temptemp: [[String]] = [[""]]
        var commentdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/comments");
        commentdb.observe(.value) { (snapshot) in
            temptemp = snapshot.value as! [[String]] ;
            completion(temptemp)
        }
    }
    
    func generateuserpic(_ currentid: String, completion: @escaping (_ picarray: Data ) -> Void){
        //self.commentlist = temptemp
        self.generateusername(currentid, completion: { namearray in
            var picarray: Data?
            var lala: String = ""
            self.infoUsername[currentid] = namearray
            let storageRef = Storage.storage().reference().child("users/\(currentid)")
            storageRef.getData(maxSize: 1*65536*655366) { (data, error) in
                if (data == nil) {
                    picarray = try! Data(contentsOf: URL(string:"https://revleap.com/wp-content/themes/revleap/images/no-profile-image.jpg")!)
                }
                else{
                    picarray = data
                }
                completion(picarray!)
            }
        })
    }
    
    func generateusername(_ currentid: String, completion: @escaping (_ namearray: (String) ) -> Void){
        
        var namearray:String = ""
        self.db.collection("users").document(currentid).getDocument { (document, error) in
            if error == nil {
                if document != nil && document!.exists {
                    let documentData = document?.data()
                    namearray = documentData?["username"] as? String ?? ""
                    
                } else {
                    print("Can read the document but the document might not exists")
                }
                
            } else {
                print("Something wrong reading the document")
            }
            completion(namearray)
        }
    }
    
    func forloop(){
        beforeforloop (completion: {temptemp in
            self.commentlist = temptemp
            var count = 0
            for eachstring in self.commentlist {
                let currentid = eachstring[0]
                self.generateuserpic(currentid, completion: { namepic in
                    self.infoPhoto[currentid] = namepic
                    
                    let tempcomment = Comment(image: UIImage(data: self.infoPhoto[currentid]!)!, name: self.infoUsername[currentid] ?? "", description: eachstring[1]);
                    count = count + 1
                    self.commentcelllist.append(tempcomment)
                    if self.commentcelllist.count == 0{
                        self.commentstableview.isHidden = true
                    } else {
                        self.commentstableview.isHidden = false
                        self.commentstableview.reloadData()
                    }
                })
            }
            
        })
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        var ratingdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/rating");
        ratingdb.observeSingleEvent(of: .value) { (snapshot) in
            var ratingtuple = snapshot.value as! [Int];
            var avrating = Double(ratingtuple[0])/Double(ratingtuple[1])
            self.ratinglabel.text = "Average Rating: " + String(format: "%.1f", avrating) + "     " + String(ratingtuple[1]) + " have rated"
        }
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 300
        } else {
            self.view.frame.origin.y = 0
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    

}


