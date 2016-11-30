//
//  DrinkViewController.swift
//  BAC Calculator
//
//  Created by Brandon Riehle on 2/25/16.
//  Copyright © 2016 Brandon Riehle. All rights reserved.
//

import UIKit

class DrinkViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var alcoholContentTextField: UITextField!
    @IBOutlet weak var flozTextBox: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var drinkButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    /*
    This value is either passed by `DrinkTableViewController` in `prepareForSegue(_:sender:)`
    or constructed as part of adding a new drink.
    */
    var drink: Drink?
    var drinks = [Drink]()
    var user: User!
    var isNew: Bool!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks
        nameTextField.delegate = self
        alcoholContentTextField.delegate = self
        alcoholContentTextField.keyboardType = UIKeyboardType.NumberPad
        flozTextBox.delegate = self
        flozTextBox.keyboardType = UIKeyboardType.DecimalPad
        
        // Set up views if editing an existing Drink.
        if let drink = drink
        {
            navigationItem.title = drink.name
            nameTextField.text   = drink.name
            alcoholContentTextField.text = "\(drink.alcoholContent)"
            flozTextBox.text = "\(drink.flozPerServing)"
            photoImageView.image = drink.photo
            ratingControl.rating = drink.rating
            isNew = false
            self.navigationController?.toolbarHidden = false
        }
        
        else
        {
            drinkButton.enabled = false
            isNew = true
            self.navigationController?.toolbarHidden = true
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidDrinkName()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        if textField == flozTextBox || textField == alcoholContentTextField
        {
            let maxLength = 4
            let currentString: NSString = textField.text!
            let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
            return newString.length <= maxLength
        }
        
        else
        {
            return true
        }
    }
    
    //Call this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        checkValidDrinkName()
        navigationItem.title = nameTextField.text
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        checkValidDrinkName()
    }
    
    func checkValidDrinkName()
    {
        // Disable the Save button if any fields are empty.
        let name = nameTextField.text ?? ""
        let alcoholContent = alcoholContentTextField.text ?? ""
        let floz = flozTextBox.text ?? ""
        
        if name.isEmpty || alcoholContent.isEmpty || floz.isEmpty
        {
            saveButton.enabled = false
            drinkButton.enabled = false
        }
        
        else
        {
            saveButton.enabled = true
            drinkButton.enabled = true
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Navigation
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        //getting text to floats
        let numberFormatter = NSNumberFormatter()
        let tempNumber = numberFormatter.numberFromString(alcoholContentTextField.text ?? "")
        let alcoholContent = tempNumber!.floatValue
        
        let tempNumber2 = numberFormatter.numberFromString(flozTextBox.text ?? "")
        let floz = tempNumber2!.floatValue
        
        if saveButton === sender
        {
            // Set the drink to be passed to DrinkTableViewController after the unwind segue.
            drink = Drink(name: name, alcoholContent: alcoholContent, flozPerServing: floz, photo: photo, rating: rating)
        }
        
        else if drinkButton === sender
        {
            drink = Drink(name: name, alcoholContent: alcoholContent, flozPerServing: floz, photo: photo, rating: rating)
            
            let MainMenuVC = segue.destinationViewController as! MainMenuViewController
            MainMenuVC.user = user
            MainMenuVC.drink = drink
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem)
    {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        
        let isPresentingInAddDrinkMode = presentingViewController is UINavigationController
        
        if isPresentingInAddDrinkMode
        {
            dismissViewControllerAnimated(true, completion: nil)
        }
            
        else
        {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer)
    {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        //prompt user to select a photo or take one
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Photo Selection", message: "Take Picture or Choose From Camera Roll", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel)
        {
            action -> Void in
            //Just dismiss the action sheet
        }
        
        actionSheetController.addAction(cancelAction)
        
        //Create and add first option action
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Take Picture", style: .Default)
        {
            action -> Void in
            
            //launching the camera
            imagePickerController.sourceType = .Camera
            
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }
        
        actionSheetController.addAction(takePictureAction)
        
        //Create and add a second option action
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Choose From Camera Roll", style: .Default)
        {
            action -> Void in
            
            //Code for picking from camera roll goes here
            imagePickerController.sourceType = .PhotoLibrary
            
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }
        
        actionSheetController.addAction(choosePictureAction)
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
    }
}