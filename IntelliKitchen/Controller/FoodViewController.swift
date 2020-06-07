//
//  FoodViewController.swift
//  homepage-Food Reminder
//
//  Created by Ricky Zhang on 4/29/20.
//  Copyright © 2020 Yilun Hao. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

class FoodViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref : DatabaseReference?
    var databaseHandle : DatabaseHandle?
    
    var list = [(String, String)]()
    var sortedfoodList = [String]()
    var allTuples = [(String, Int)]()
    
    var no = 0
    var e = 0
    var a = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        
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
                self.tableView.reloadData()
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
                self.allTuples.insert((data.0, inday), at: index)
                if(inday < 0){
                    self.sortedfoodList.insert(data.0, at: index)
                    self.no+=1
                    self.e+=1
                    self.a+=1
                }
                else if(inday <= 3){
                    self.sortedfoodList.insert(data.0, at: index)
                    self.e+=1
                    self.a+=1
                }
                else if(inday <= 5){
                    self.sortedfoodList.insert(data.0, at: index)
                    self.a+=1
                }
                else{
                    self.sortedfoodList.insert(data.0, at: index)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sortedfoodList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell")
        cell?.textLabel?.text = sortedfoodList[indexPath.row]
        cell?.textLabel?.font = UIFont(name: "Acumin Pro SemiCondensed", size: 15)
        cell?.textLabel?.textColor = UIColor.darkGray
        if(indexPath.row < no){
            cell?.backgroundColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
        }
        else if(indexPath.row < e){
            cell?.backgroundColor = UIColor(red: 250/255, green: 160/255, blue: 160/255, alpha: 1)
        }
        else if(indexPath.row < a){
            cell?.backgroundColor = UIColor(red: 255/255, green: 196/255, blue: 196/255, alpha: 1)
        }
        else{
            cell?.backgroundColor = UIColor.white
        }
        tableView.layer.cornerRadius = 20
        cell?.selectionStyle = .none
        return cell!
    }
}

