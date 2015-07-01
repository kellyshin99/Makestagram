//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Kelly Shin on 6/29/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Bond
import Parse

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesIconImageview: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBAction func moreButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
    
    var likeBond: Bond<[PFUser]?>!
    
    var post:Post? {
        didSet {
            if let post = post {
                // bind the image of the post to the 'postImage" view
                post.image ->> postImageView
                
                // bind the likeBond that we defined earlier, to update like label and button when likes change
                post.likes ->> likeBond
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // Generates a comma separated string of usernames from an array (e.g. "User1, User2")
    func stringFromUserList(userList: [PFUser]) -> String {
        let usernameList = userList.map { user in user.username! }
        let commaSeparatedUserList = ", ".join(usernameList)
        
        return commaSeparatedUserList
    }
    
    required init (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        likeBond = Bond<[PFUser]?>() { [unowned self] likeList in
            if let likeList = likeList {
                self.likesLabel.text = self.stringFromUserList(likeList)
                self.likeButton.selected = contains(likeList, PFUser.currentUser()!)
                self.likesIconImageview.hidden = (likeList.count == 0)
            } else {
                // if there is no list of users that like this post, reset everything
                self.likesLabel.text = ""
                self.likeButton.selected = false
                self.likesIconImageview.hidden = true
            }
            
        }
            
    }
    
}
