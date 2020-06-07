//
//  AddChoresViewController.swift
//  IntelliKitchen_Myfood
//
//  Created by D.WANG on 5/7/20.
//  Copyright © 2020 D.WANG. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class AddChoresViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // reference and global varaible
    @IBOutlet weak var taskField: UITextField!
    @IBOutlet weak var choresList: UITableView!
    @IBOutlet weak var lastDoneField: UITextField!
    @IBOutlet weak var timePeriodField: UITextField!
    
    private var datePicker: UIDatePicker?
    private var pickerView: UIPickerView?
    let frequency = ["Once a day", "Twice a day", "Once a week", "Twice a week", "Once a month", "Twice a month"]
    
    var chores = [String]()
    var choreNames = [String]()
    var lastDoneDates = [String]()
    var frequencyChoice = [String]()
    var ref: DatabaseReference!
    let db = Firestore.firestore()
    var remindDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        datePicker = UIDatePicker()
        pickerView = UIPickerView()
        pickerView?.dataSource = self
        pickerView?.delegate = self
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(AddChoresViewController.dateChanged(datePicker:)), for: .valueChanged)
        lastDoneField?.addTarget(self, action: #selector(self.tapLastDone), for: .touchDown)
        timePeriodField?.addTarget(self, action: #selector(self.tapPeriod), for: .touchDown)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddChoresViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        lastDoneField.inputView = datePicker
        timePeriodField.inputView = pickerView
    }
    
    
    @IBAction func addTapped(_ sender: Any) {
        if(taskField.text == "" || lastDoneField.text == "" || timePeriodField.text == ""){
            createAlert(title: "Oops", message: "It seems like you miss something!")
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            if(timePeriodField.text == "Once a day" || timePeriodField.text == "Twice a day") {
                var dateObj = dateFormatter.date(from: lastDoneField.text ?? "")
                dateObj = dateObj?.addingTimeInterval(86400)
                remindDate = dateFormatter.string(from: dateObj!)
            }
            if(timePeriodField.text == "Once a week") {
                var dateObj = dateFormatter.date(from: lastDoneField.text ?? "")
                dateObj = dateObj?.addingTimeInterval(604800)
                remindDate = dateFormatter.string(from: dateObj!)
            }
            if(timePeriodField.text == "Twice a week") {
                var dateObj = dateFormatter.date(from: lastDoneField.text ?? "")
                dateObj = dateObj?.addingTimeInterval(302400)
                remindDate = dateFormatter.string(from: dateObj!)
            }
            if(timePeriodField.text == "Once a month") {
                var dateObj = dateFormatter.date(from: lastDoneField.text ?? "")
                dateObj = dateObj?.addingTimeInterval(2592000)
                remindDate = dateFormatter.string(from: dateObj!)
            }
            if(timePeriodField.text == "Twice a month") {
                var dateObj = dateFormatter.date(from: lastDoneField.text ?? "")
                dateObj = dateObj?.addingTimeInterval(1296000)
                remindDate = dateFormatter.string(from: dateObj!)
            }
            let currentUid = Auth.auth().currentUser!.uid
            db.collection("users").document(currentUid).collection("chores").document(taskField.text ?? "").setData(["choreName":taskField.text ?? "", "lastDone":lastDoneField.text ?? "", "frequency":timePeriodField.text ?? "", "remindDate":remindDate, "remindOrNot": false])
            createAlert(title: "Success!", message: "Successfully added chore!")
            insertNewChore()
        }
    }
    
    func insertNewChore(){
        chores.append("\(taskField.text!)       \(lastDoneField.text!)       \(timePeriodField.text!)")
        let indexPath = IndexPath(row: chores.count - 1, section: 0)
        choreNames.append(taskField.text ?? "")
        lastDoneDates.append(lastDoneField.text ?? "")
        frequencyChoice.append(timePeriodField.text ?? "")
        choresList.beginUpdates()
        choresList.insertRows(at: [indexPath], with: .automatic)
        choresList.endUpdates()
        taskField.text = ""
        timePeriodField.text = ""
        lastDoneField.text = ""
    }
    
    
    
    func createAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return frequency[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frequency.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timePeriodField.text = frequency[row]
    }
    
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if( NSDate.init().laterDate(datePicker.date) == datePicker.date){
            createAlert(title: "Oops", message: "You can't choose a future date!")
            view.endEditing(true)
        } else {
            lastDoneField.text = dateFormatter.string(from: datePicker.date)
        }
    }
    
    @objc func tapLastDone() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        lastDoneField.text = dateFormatter.string(from: datePicker!.date)
        view.endEditing(true)
    }
    
    @objc func tapPeriod() {
        timePeriodField.text = frequency[0]
        view.endEditing(true)
    }
    
}

