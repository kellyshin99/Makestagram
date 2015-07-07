//
//  FriendSearchViewController.swift
//  Makestagram
//
//  Created by Kelly Shin on 6/26/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import ConvenienceKit
import Parse

class FriendSearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var users: [PFUser]?
    
    var followingUsers: [PFUser]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var query: PFQuery? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    enum State {
        case DefaultMode
        case SearchMode
    }
    
    var state: State = .DefaultMode {
        didSet {
            switch (state) {
                case .DefaultMode:
                    query = ParseHelper.allUsers(updateList)
                case .SearchMode:
                    let searchText = searchBar?.text ?? ""
                query = ParseHelper.searchUsers(searchText, completionBlock: updateList)
                
                }
            }
        }

    // MARK: Update List
    
    func updateList(results: [AnyObject]?, error: NSError?) {
        self.users = results as? [PFUser] ?? []
        self.tableView.reloadData()
        
        if let error = error {
            ErrorHandling.defaultErrorHandler(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: View Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        state = .DefaultMode

        ParseHelper.getFollowingUserForUser(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            let relations = results as? [PFObject] ?? []
            // use map to extract the User from a Follow object
            self.followingUsers = relations.map {
                $0.objectForKey(ParseHelper.ParseFollowToUser) as! PFUser
            }
            
            if let error = error {
                // Call the default error handler in case of an Error
                ErrorHandling.defaultErrorHandler(error)
            }
        }
    }
}

    // MARK: TableView Data Source
    
    extension FriendSearchViewController: UITableViewDataSource {
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.users?.count ?? 0
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! FriendSearchTableViewCell
            
            let user = users![indexPath.row]
            cell.user = user
            
            if let followingUsers = followingUsers {
                // check if current user is already following displayed user
                // change button appereance based on result
                cell.canFollow = !contains(followingUsers, user)
            }
            
            cell.delegate = self
            
            return cell
        }
    }
    
    // MARK: Searchbar Delegate
    
    extension FriendSearchViewController: UISearchBarDelegate {
        
        func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
            state = .SearchMode
        }
        
        func searchBarCancelButtonClicked(searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            searchBar.text = ""
            searchBar.setShowsCancelButton(false, animated: true)
            state = .DefaultMode
        }
        
        func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
            ParseHelper.searchUsers(searchText, completionBlock:updateList)
        }
        
    }
    
    // MARK: FriendSearchTableViewCell Delegate
    
    extension FriendSearchViewController: FriendSearchTableViewCellDelegate {
        
        func cell(cell: FriendSearchTableViewCell, didSelectFollowUser user: PFUser) {
            ParseHelper.addFollowRelationshipFromUser(PFUser.currentUser()!, toUser: user)
            // update local cache
            followingUsers?.append(user)
        }
        
        func cell(cell: FriendSearchTableViewCell, didSelectUnfollowUser user: PFUser) {
            if var followingUsers = followingUsers {
                ParseHelper.removeFollowRelationshipFromUser(PFUser.currentUser()!, toUser: user)
                // update local cache
                removeObject(user, fromArray: &followingUsers)
                self.followingUsers = followingUsers
            }
        }
        
    }


    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

