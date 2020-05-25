//
//  RecipeListScreen.swift
//  IntelliKitchen
//
//  Created by sawsa on 4/30/20.
//  Copyright © 2020 jigsaw. All rights reserved.
//

import UIKit
import Firebase

class RecipeListScreen: UIViewController {
    
    var ref = Database.database().reference()
    var newrecipeid:[String] = [];
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mySearchBar: UISearchBar!
    
    var recipes:[Recipe] = []
    
    var searchByName = true
    var searchArray: [String] = []
    var label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if searchByName {
            mySearchBar.text = searchArray[0]
        } else {
            var text = ""
            for i in 0...(searchArray.count - 1) {
                if i == 0 {
                    text = searchArray[i]
                } else {
                    text += ", \(searchArray[i])"
                }
            }
            mySearchBar.text = text
        }
        
        // UI design
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
        label.center.x = self.view.center.x
        label.center.y = self.view.center.y - 20
        label.textAlignment = .center
        label.text = "No matching result. \nPlease conduct your search again."
        label.font = label.font.withSize(20)
        label.numberOfLines = 0
        self.view.addSubview(label)
        label.isHidden = true
        
        if searchByName {
            createArray(true, Array(searchArray[1...]))
        } else {
            createArray(false, searchArray)
        }
        tableView.delegate = self
        tableView.dataSource = self
//        getRecipeID(false, searchArray, completion: { recipeID in
//            print(recipeID)
//        })
    }
    
    func createArray(_ searchByName: Bool, _ searchArray: [String]) {
        print("in create array")
        retrieveRecipes(searchByName, searchArray, completion: { searchedRecipes in
            if searchedRecipes.count == 0 {
                self.tableView.isHidden = true
                self.label.isHidden = false
            } else {
                self.recipes = searchedRecipes
                self.tableView.reloadData()
                self.tableView.isHidden = false
                self.label.isHidden = true
            }
        })
    }
    
    func retrieveRecipes(_ searchByName: Bool, _ searchArray: [String], completion: @escaping (_ searchedRecipes: [Recipe]) -> Void) {
        var tempRecipes: [Recipe] = []
        
        getRecipeID(searchByName, searchArray, completion: { recipeID in
            if recipeID.count == 0 {
                completion(tempRecipes)
            } else {
                let recipeRef = Database.database().reference().child("Recipe")
                recipeRef.observe(.value, with: { snapshot in
                    for child in snapshot.children {
                        let snap = child as! DataSnapshot
                        if recipeID.contains(Int(snap.key)!) {
                            self.newrecipeid.append(snap.key)
                            if let dict = snap.value as? [String: Any] {
                                var image = UIImage()
                                if dict["img"] == nil {
                                    image = UIImage(imageLiteralResourceName: "RecipeImage.jpg")
                                } else {
                                    let imageUrl = URL(string: dict["img"] as! String)
                                    let imageData = try! Data(contentsOf: imageUrl!)
                                    image = UIImage(data: imageData)!
                                }
                                let recipe = Recipe(image: image, title: dict["recipe_name"] as! String)
                                tempRecipes.append(recipe)
                            }
                        }
                    }
                    //print("xjnnnnnnnnn")
                    //print(self.newrecipeid)
                    completion(tempRecipes)
                   // print(self.newrecipeid)

                })
            }
        })
    }

    func getRecipeID(_ searchByName: Bool, _ searchArray: [String], completion: @escaping (_ recipeID: [Int]) -> Void) {
        if searchByName {
            var recipeID: [Int] = []
            let recipeRef = Database.database().reference().child("RecipeNameTOId")
            recipeRef.observe(.value, with: {snapshot in
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    if searchArray.contains(snap.key) {
                        recipeID.append(contentsOf: (snap.value as? [Int])!)
                    }
                }
                completion(recipeID)
            })
        } else {
            var result = Set<Int>()
            var first = true
            
            let ingredientRef = Database.database().reference().child("Ingredients")
            ingredientRef.observe(.value, with: {snapshot in
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    if searchArray.contains(snap.key) {
                        let value = (snap.value as? [Int])!
                        let valueSet = Set(value)
                        if first {
                            result = valueSet
                            first = false
                        } else {
                            result = result.intersection(valueSet)
                        }
                        if result.count == 0 {
                            break
                        }
                    }
                }
                completion(Array(result))
            })
        }
    }
    
}

extension RecipeListScreen: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipe = recipes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeCell
        cell.setRecipe(recipe: recipe)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("3. recipe count is: \(recipes.count)")
        if recipes.count == 0 {
            return CGFloat(0.0)
        } else {
            return CGFloat(110.0)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = newrecipeid[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "menudetail") as! ScrollViewController
        secondVC.passid = id;
        self.present(secondVC,animated:true,completion: nil)
    }
}