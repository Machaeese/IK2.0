//
//  RecipeViewController.swift
//  homepage-Food Reminder
//
//  Created by Ricky Zhang on 5/7/20.
//  Copyright © 2020 Yilun Hao. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore
import FirebaseAuth

class RecipeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // reference and global variable
    @IBOutlet weak var collectionView: UICollectionView!
    var ref : DatabaseReference?
    var databaseHandle : DatabaseHandle?
    var RecipeName = [String]()
    var RecipeImage = [UIImage]()
    var expire = [Date]()
    var allFood = [String]()
    var allRecipe = [String]()
    var AllImage = [UIImage]()
    var mylist:[Int] = []
    var recipeidlist:[String] = []
    
    var ExpiredFood = [String]()
    var EmergencyFood = [String]()
    var AlmostFood = [String]()
    var SafeFood = [String]()
    
    var list = [(String, String)]()
    var sortedfoodList = [String]()
    var allTuples = [(String, Int)]()
    
    var no = 0
    var e = 0
    var a = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        ref = Database.database().reference()
        let db = Firestore.firestore()
        let currentUid = Auth.auth().currentUser!.uid
        db.collection("users").document(currentUid).collection("foods").getDocuments { (snapshot,error) in
            if(error != nil){
                print(error!)
            }else{
                for document in (snapshot!.documents){
                    let name = document.data()["foodName"] as! String
                    //self.foodList.append(name)
                    let date = document.data()["expireDate"] as! String
                    self.list.append((name,date))
                }
                self.sortList()
                self.getdicList(){ (list) in
                    let list = list
                    for index in list{
                        self.databaseHandle = self.ref?.child("Recipe/-M8IVR-st6dljGq6M4xN/"+String(index)).observe(.value, with: { (snapshot) in
                            let value = snapshot.value as? NSDictionary
                            let recipe_name = value?.value(forKey: "recipe_name") as! String
                            if(!self.allRecipe.contains(recipe_name)){
                                var image = UIImage(named: "Mask Group 7")
                                if(value?.value(forKey: "img") != nil){
                                    let name = value?.value(forKey: "img") as! String
                                    let imageURL = URL(string: name)
                                    let data = try? Data(contentsOf: imageURL!)
                                    image = UIImage(data: data!)
                                    self.AllImage.append(image!)
                                    self.recipeidlist.append(String(index))
                                    self.allRecipe.append(recipe_name)
                                    self.collectionView.reloadData()
                                    self.collectionView .layoutIfNeeded()
                                }
                                else{
                                    if(value?.value(forKey: "recipe_pic") != nil){
                                        let name = value?.value(forKey: "recipe_pic") as! String
                                        let imageURL = URL(string: name)
                                        let data = try? Data(contentsOf: imageURL!)
                                        image = UIImage(data: data!)
                                        self.AllImage.append(image!)
                                        self.recipeidlist.append(String(index))
                                        self.allRecipe.append(recipe_name)
                                        self.collectionView.reloadData()
                                        self.collectionView .layoutIfNeeded()
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func getRecipeList(name: String, completionHandler:@escaping ([Int], [Int]) -> ()) {
        var currentfood:[Int] = []
        var transfer:[Int] = []
        self.databaseHandle = self.ref?.child("Ingredients/"+name).observe(.value, with: { (snapshot) in
            if(snapshot.exists()){
                transfer.append(contentsOf: snapshot.value as! [Int])
                currentfood = snapshot.value as! [Int]
            }
            self.databaseHandle = self.ref?.child("Ingredients/"+name+"s").observe(.value, with: { (snapshot) in
                if(snapshot.exists()){
                    transfer.append(contentsOf: snapshot.value as! [Int])
                    currentfood = snapshot.value as! [Int]
                }
                completionHandler(transfer, currentfood)
            })
        })
    }
    
    func getdicList(completionHandler:@escaping ([Int]) -> ()) {
        var list:[Int] = []
        for name in sortedfoodList{
            getRecipeList(name: name){ (translist, currlist) in
                list.append(contentsOf: translist)
                let currlist = currlist
                let mappedItems = list.map { ($0, 1) }
                var returned = [Int]()
                let counts = Dictionary(mappedItems, uniquingKeysWith: +)
                for key in counts.keys{
                    if(counts[key]! >= 2 && returned.count<3){
                        returned.append(key)
                        list = list.filter{$0 != key}
                    }
                }
                while(counts.count > 0 && self.EmergencyFood.contains(name) && currlist.count > 0 && returned.count<3){
                    returned.append(currlist.randomElement()!)
                }
                while(counts.count > 0 && self.AlmostFood.contains(name) && currlist.count > 0 && returned.count<2){
                    returned.append(currlist.randomElement()!)
                }
                while(counts.count > 0 && self.SafeFood.contains(name) && currlist.count > 0 && returned.count<1){
                    returned.append(currlist.randomElement()!)
                }
                completionHandler(returned)
            }
        }
    }
    
    func sortList(){
        for data in list{
            let expireSingle = data.1
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            dateFormatter.locale = Locale.init(identifier: "en_GB")
            if(expireSingle != ""){
                let d = dateFormatter.date(from: expireSingle)!
                let today = Date()
                let calendar = Calendar.current
                // Replace the hour (time) of both dates with 00:00
                let date1 = calendar.startOfDay(for: today)
                let date2 = calendar.startOfDay(for: d)
                
                let components = calendar.dateComponents([.day], from: date1, to: date2)
                let inday = components.day!
                var index = 0
                while(index < self.allTuples.count && self.allTuples[index].1 < inday ){
                    index+=1
                }
                if(inday >= 0){
                    self.allTuples.insert((data.0, inday), at: index)
                }
                if(inday < 0){
                    //self.sortedfoodList.insert(data.0, at: index)
                    self.ExpiredFood.append(data.0)
                    self.no+=1
                    self.e+=1
                    self.a+=1
                }
                else if(inday <= 3){
                    self.sortedfoodList.insert(data.0, at: index)
                    self.EmergencyFood.append(data.0)
                    self.e+=1
                    self.a+=1
                }
                else if(inday <= 5){
                    self.sortedfoodList.insert(data.0, at: index)
                    self.AlmostFood.append(data.0)
                    self.a+=1
                }
                else{
                    self.sortedfoodList.insert(data.0, at: index)
                    self.SafeFood.append(data.0)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allRecipe.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        let cellIndex = indexPath.item
        
        cell.imageView.image = AllImage[cellIndex]
        cell.imageView.translatesAutoresizingMaskIntoConstraints = true
        cell.imageView.contentMode = .scaleAspectFit
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = 25
        cell.labelView.text = allRecipe[cellIndex]
        cell.labelView.font = UIFont(name: "Acumin Pro SemiCondensed", size: 15)
        cell.labelView.textColor = UIColor.darkGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = self.recipeidlist[indexPath.item]
        let storyboard = UIStoryboard(name:"Main",bundle: nil)
        let anotherVC = storyboard.instantiateViewController(identifier: "menudetail") as! ScrollViewController
        anotherVC.passid = id;
        self.present(anotherVC,animated:true,completion: nil)
    }
}
