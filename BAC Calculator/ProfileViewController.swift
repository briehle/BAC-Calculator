//
//  ProfileViewController.swift
//  BAC Calculator
//
//  Created by Brandon Riehle on 2/23/16.
//  Copyright © 2016 Brandon Riehle. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate
{
    // MARK: Properties
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var genderImage: UIImageView!
    @IBOutlet weak var genderSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var signoutButton: UIBarButtonItem!
    
    /*
    This value is either passed by `MenuViewController` in `prepareForSegue(_:sender:)`
    or constructed as part of adding a new user.
    */

    var drink: Drink?
    var user: User?
    var users = [User]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        //then dismisses the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        genderSwitch.addTarget(self, action: #selector(ProfileViewController.genderSwitchIsChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        weightTextField.delegate = self
        weightTextField.keyboardType = UIKeyboardType.NumberPad
        
        //if they are editing
        if let user = user
        {
            //filling in all data fields for user
            navigationItem.title = user.userName
            userNameTextField.text = user.userName
            passwordTextField.text = user.password
            weightTextField.text = user.weight
            genderSwitch.setOn(user.gender, animated: user.gender)
            genderSwitchIsChanged(genderSwitch)
            signoutButton.enabled = true
            
            if user.isCurrentlyDrinking
            {
                //disable these
                genderSwitch.enabled = false
                weightTextField.enabled = false
            }
        }
        
        checkTextfields()
        
        if let savedUsers = loadUsers()
        {
            users += savedUsers
        }
        
        self.navigationController!.toolbarHidden = false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        if textField == weightTextField
        {
            let maxLength = 3
            let currentString: NSString = textField.text!
            let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
            return newString.length <= maxLength
        }
        
        else
        {
             return true
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        // Hide the keyboard.
        textField.resignFirstResponder()
        
        //returning the value true indicates that the text field should respond to the user pressing the Return key by dismissing the keyboard
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        // Disable the Save button while editing.
        checkTextfields()
    }

    //Call this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        navigationItem.title = userNameTextField.text
        checkTextfields()
    }
    
    func checkTextfields()
    {
        // Disable the Save button if the text field is empty.
        let userNameText = userNameTextField.text ?? ""
        let passwordText = passwordTextField.text ?? ""
        let weightText = weightTextField.text ?? ""
        
        if userNameText.isEmpty || passwordText.isEmpty || weightText.isEmpty
        {
            saveButton.enabled = false
        }
            
        else
        {
            saveButton.enabled = true
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func genderSwitchIsChanged(genderSwitch: UISwitch)
    {
        if genderSwitch.on
        {
            genderImage.image = UIImage(named: "male")
        }
        
        else
        {
            genderImage.image = UIImage(named: "female")
        }
    }
    
    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem)
    {
        //when canceling a create new profile
        if user == nil
        {
            dismissViewControllerAnimated(true, completion: nil)
        }
            
        //when canceling an edit profile
        else
        {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        //getting user info
        if (segue.identifier == "saveUser")
        {
            let userName = userNameTextField.text ?? ""
            let password = passwordTextField.text ?? ""
            let weight = weightTextField.text ?? ""
            let gender: Bool
            
            if genderSwitch.on
            {
                gender = true
            }
            
            else
            {
                gender = false
            }
            
            let potentialNewUser = User(userName: userName, password: password, gender: gender, weight: weight)
            
            //cases 
            //new user
            //existing user changed name
            //existing user didnt change name Nothing
            //existing user chnages name to another user in list error
            
            //new user
            if findExistingUser(potentialNewUser!) == -1
            {
                users.append(potentialNewUser!)
            }
            
            else if user?.userName == potentialNewUser?.userName
            {
                //save name in right spot
                users[findExistingUser(user!)] = potentialNewUser!
            }
            
            else
            {
                userNameTaken()
            }
            
            //saving users array
            saveUsers()
            
            // User to pass to MainMenuViewControl
            let nav = segue.destinationViewController as! UINavigationController
            let addEventViewController = nav.topViewController as! MainMenuViewController
            addEventViewController.drink = drink
            addEventViewController.user = potentialNewUser
        }
        
        else if(segue.identifier == "logout")
        {
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
    }
    
    func findExistingUser(potentialUser: User) -> Int
    {
        for i in 0 ..< users.count
        {
            if users[i] == potentialUser
            {
                return i
            }
        }
        
        return -1
    }
    
    func userNameTaken()
    {
        //prompt user that userName is already taken
        let alertController = UIAlertController(title: "Username not available", message:"Username taken", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func saveUsers()
    {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(users, toFile: User.ArchiveURL.path!)
        
        //checking if save was unsuccessful
        if !isSuccessfulSave {
            print("Failed to save users...")
        }
    }
    
    //unarchive the user array stored at the path User.ArchiveURL.path! and downcast that object to a User
    func loadUsers() -> [User]?
    {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? [User]
    }
}
