//
//  CustomTableViewCell.swift
//  IntelliKitchen_Myfood
//
//  Created by D.WANG on 5/23/20.
//  Copyright © 2020 D.WANG. All rights reserved.
//

import UIKit


class CommentCell: UITableViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var comments: UILabel!
    
    func setComments(comment: Comment) {
        photo.image = comment.image;
        name.text = comment.name;
        comments.text = comment.description;
        photo.layer.cornerRadius = 10;
    }
}


class FavoriteRecipeCell: UITableViewCell {
    
    @IBOutlet weak var favoriteRecipeImage: UIImageView!
    @IBOutlet weak var favoriteRecipeLabel: UILabel!
    
    func setFavoriteRecipe(favoriteRecipe: FavoriteRecipe) {
        favoriteRecipeImage.image = favoriteRecipe.image
        favoriteRecipeLabel.text = favoriteRecipe.title
    }
}

class MyChoresTableViewCell: UITableViewCell {
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var lastDoneLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}


class AddFoodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var bDateLabel: UILabel!
    @IBOutlet weak var eDateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class RecipeCell: UITableViewCell {
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var recipeRating: UILabel!
    
    func setRecipe(recipe:Recipe) {
        recipeImage.image = recipe.image
        recipeTitle.text = recipe.title
        recipeRating.text = "Average Rating: \(recipe.rating)"
    }
}

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var edLabel: UILabel!
    @IBOutlet weak var bdLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


class AddChoresTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ldLabel: UILabel!
    @IBOutlet weak var fLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


class ChoresTableViewCell: UITableViewCell {

    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var orilabelView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


