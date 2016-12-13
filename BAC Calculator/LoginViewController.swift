//
//  LoginViewController.swift
//  BAC Calculator
//
//  Created by Brandon Riehle on 2/16/16.
//  Copyright © 2016 Brandon Riehle. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate
{
    // MARK: Properties
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var users = [User]()
    
//    override func viewDidAppear(animated: Bool)
//    {
//        if NSUserDefaults.standardUserDefaults().boolForKey("SeenInstructions")
//        {
//            // Terms have been accepted, proceed as normal
//        }
//        
//        else
//        {
//            // Terms have not been accepted. Show terms (perhaps using performSegueWithIdentifier)
//            
//            
//            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "TermsAccepted")
//        }
//    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let imageData = NSData(contentsOfURL: NSBundle.mainBundle()
            .URLForResource("giphy", withExtension: "gif")!)
        
        let imageGif = UIImage.gifWithData(imageData!)
        let imageView = UIImageView(image:imageGif)
        
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 667.0)
        view.addSubview(imageView)
        self.view.insertSubview(imageView, atIndex: 0)
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        
        //Looks for single or multiple taps.
        //then dismisses the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Load any saved users
        if let savedUsers = loadUsers()
        {
            users += savedUsers
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationBarHidden = true
        self.hidesBottomBarWhenPushed = true
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        // Hide the keyboard.
        textField.resignFirstResponder()
        
        //returning the value true indicates that the text field should respond to the user pressing the Return key by dismissing the keyboard
        return true
    }
    
    //Call this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //unarchive the user array stored at the path User.ArchiveURL.path! and downcast that object to a User
    func loadUsers() -> [User]?
    {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? [User]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findUser(userName:String, password: String)-> User?
    {
        for i in 0 ..< users.count
        {
            if users[i].userName == userName && users[i].password == password
            {
                return users[i]
            }
        }
        
        return nil
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "loginUser"
        {
            //getting login credentials
            let userName = userNameTextField.text ?? ""
            let password = passwordTextField.text ?? ""
            
            if let user = findUser(userName, password: password)
            {
                let nav = segue.destinationViewController as! UINavigationController
                let addEventViewController = nav.topViewController as! MainMenuViewController
                addEventViewController.user = user
            }
            
            else
            {
                //prompt user that userName or password are incorrect
                let alertController = UIAlertController(title: "Incorrect Login", message:"Username or Password Incorrect", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}