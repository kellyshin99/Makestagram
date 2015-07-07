//
//  PostSectionHeaderView.swift
//  Makestagram
//
//  Created by Kelly Shin on 7/7/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class PostSectionHeaderView: UITableViewCell {

    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var post: Post? {
        didSet{
            if let post = post {
                usernameLabel.text = post.user?.username
            }
        }
    }

}