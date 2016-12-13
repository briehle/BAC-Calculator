
//
//  MainMenuViewController.swift
//  BAC Calculator
//
//  Created by Brandon Riehle on 2/24/16.
//  Copyright © 2016 Brandon Riehle. All rights reserved.
//
//  http://www.wikihow.com/Calculate-Blood-Alcohol-Content-(Widmark-Formula)#_note-3
//  http://www.lifeguardbreathtester.com/Self_Monitoring/alcohol_time.shtml


import UIKit
import CoreLocation

//user not being saved from edit correctly
class MainMenuViewController: UIViewController, CLLocationManagerDelegate
{
    // MARK: Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var flozLabel: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var timeUntilSoberTextField: UITextField!
    @IBOutlet weak var drinkCountTextField: UITextField!
    @IBOutlet weak var finishedDrinkButton: UIButton!
    @IBOutlet weak var clearDrinksButton: UIBarButtonItem!
    @IBOutlet weak var beginDrinkingButton: UIBarButtonItem!
    @IBOutlet weak var editProfileButton: UIBarButtonItem!
    @IBOutlet weak var selectDrinkButton: UIButton!
    @IBOutlet weak var drinkCountLabel: UILabel!
    
    @IBOutlet weak var timeUntilSoberLabel: UILabel!
    @IBOutlet weak var currentBacLabel: UILabel!
    
    var user: User!
    var drink: Drink!
    var users = [User]()
    var drinks = [Drink]()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//        let imageData = NSData(contentsOfURL: NSBundle.mainBundle()
//            .URLForResource("giphy (1)", withExtension: "gif")!)
//        
//        let imageGif = UIImage.gifWithData(imageData!)
//        let gifView = UIImageView(image:imageGif)
//        
//        gifView.frame = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 667.0)
//        view.addSubview(gifView)
//        self.view.insertSubview(gifView, atIndex: 0)
        
        if let savedUsers = loadUsers()
        {
            users += savedUsers
        }
        
        //navigation title set to name
        navigationItem.title = user.userName
        
        if user.isCurrentlyDrinking
        {
            beginDrinkingButton.enabled = false
            
            if user.drinkNumber > 0
            {
                clearDrinksButton.enabled = true
            }
        }
        
        //user selected a drink
        if drink != nil
        {
            //setting drink cell to drink info
            nameLabel.text = drink.name
            flozLabel.text = "\(drink.flozPerServing)" + " oz"
            imageView.image = drink.photo
            ratingControl.rating = drink.rating
        }
            
        else if drink == nil
        {
            selectDrinkButton.setTitle("Select A Drink", forState: .Normal)
            selectDrinkButton.backgroundColor = UIColor(red: 66/255, green: 244/255, blue: 235/255, alpha: 0.5)
            nameLabel.text = ""
            flozLabel.text = ""
            imageView.image = nil
            ratingControl.hidden = true
        }
        
        self.navigationController?.toolbarHidden = false
        updateScreen()
    }

    @IBAction func uberButtonPressed(sender: UIBarButtonItem)
    {
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "uber://")!)
        {
            var pickupLocation = CLLocationCoordinate2D()
            
            // Core Location Manager asks for GPS location
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startMonitoringSignificantLocationChanges()
            
            // Check if the user allowed authorization
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse)
            {
                pickupLocation = CLLocationCoordinate2D(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude)
            }
            
            // Create an Uber instance
            let uber = Uber(pickupLocation: pickupLocation)
            
            uber.deepLink()
        }
            
        else
        {
            // No Uber app, open the mobile site.
            UIApplication.sharedApplication().openURL(NSURL(string:"https://m.uber.com/")!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        //get currently logged in user
        if segue.identifier == "editUser"
        {
            let profileVC = segue.destinationViewController as! ProfileViewController
            
            //passing user and drink
            profileVC.user = user
            profileVC.drink = drink
        }
            
        else if segue.identifier == "changeDrink"
        {
            let DrinkTableVC = segue.destinationViewController as! DrinkTableViewController
            DrinkTableVC.user = user
            DrinkTableVC.drink = drink
        }
    }
    
    //load user
    func loadUsers() -> [User]?
    {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? [User]
    }
    
    //save users
    func saveUsers()
    {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(users, toFile: User.ArchiveURL.path!)
        
        //checking if save was unsuccessful
        if !isSuccessfulSave {
            print("Failed to save users...")
        }
    }
    
    func overwriteUserArray()
    {
        for i in 0 ..< users.count
        {
            if users[i].userName == user.userName
            {
                users[i] = user
            }
        }
    }
    
    //load drinks
    func loadDrinks() -> [Drink]?
    {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Drink.ArchiveURL.path!) as? [Drink]
    }
    
    func calculateBac()
    {
        var genderConstant: Float
        
        //if male user
        if user.gender == "male"
        {
            genderConstant = 0.68
        }
        
        //female user
        else
        {
            genderConstant = 0.55
        }
        
        user.alcoholConsumedInGrams += drink.flozPerServing * 29.6 * (drink.alcoholContent / 100) * 0.789
        
        let bodyWeightInGrams: Float = Float(user.weight)! * 454
        let bac: Float = (user.alcoholConsumedInGrams / (bodyWeightInGrams * genderConstant)) * 100
        
        user.currentBac = bac - (getElapsedTime() * 0.015)
        
        //1. BAC = [Alcohol consumed in grams / (Body weight in grams x r)] x 100
        //“r” is the gender constant: r = 0.55 for females and 0.68 for males
        
        //2. Count the number of drinks
        //The standard drink size of an 80-proof version of a liqueur such as gin or whiskey is approximately 1.5 ounces.[2] This is about forty percent alcohol.
        //The standard drink size of a beer with a five percent volume of alcohol is twelve ounces.
        //The standard drink size of a wine with a twelve percent volume of alcohol is five ounces.
        
        //3. Find the alcohol dose
        //(Volume of drinks) x (AC of drinks) x 0.789 = grams of alcohol consumed
        
        //4. Multiply your body weight in grams and multiply it by the gender constant
        //Body weight in pounds x 454 = body weight in grams
        
        //5. Divide the alcohol consumed in grams by (body weight in grams x gender constant.)
        
        //6. Multiply the raw number by 100
        
        //7. Account for elapsed time
        //BAC as a percentage – (elapsed time in hours x 0. 015)
    }
    
    func getElapsedTime() -> Float
    {
        let totalTime = user.endTime - user.beginTime
        let seconds = totalTime / 1000
        let hours = (seconds / 60) / 60
        
        return Float(hours)
    }
    
    func updateScreen()
    {
        //show current bac
        if user.currentBac > 0
        {
            //format BAC to 3 decimal places
            currentBacLabel.text = String (format: "%.3f", user.currentBac)
            
            //hours till sober
            let timeTillSober = user.currentBac / 0.015
            
            //hours value
            let hours = Int (floor(timeTillSober))
            
            //minutes value convert to mins
            let tempMins = timeTillSober % 1 * 60
            
            let minutes = Int (floor(tempMins))
            
            timeUntilSoberLabel.text = "\(hours) hr \(minutes) min"
        }
        
        else
        {
            currentBacLabel.text = "You're Sober"
            timeUntilSoberLabel.text = "You're Sober"
        }

        //show drink number
        drinkCountLabel.text = "\(user.drinkNumber)"
    }
    
    func noDrinkSelectedFinishedDrinkButtonClickPopup()
    {
        //send message to user to select a drink
        //prompt user that userName is already taken
        let alertController = UIAlertController(title: "Cannot Finish Drink", message:"Select a drink", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func noDrinkSelectedBeginDrinkingButtonClickPopup()
    {
        //send message to user to select a drink
        //prompt user that userName is already taken
        let alertController = UIAlertController(title: "Cannot Begin Drinking", message:"Select a drink", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func beginDrinkingButtonNotClickedPopup()
    {
        //send message to user to select a drink
        //prompt user that userName is already taken
        let alertController = UIAlertController(title: "Cannot Finish Drink", message:"Tap play button to begin drinking", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func finishedDrinkButton(sender: UIButton)
    {
        if drink == nil
        {
            noDrinkSelectedFinishedDrinkButtonClickPopup()
        }
            
        else if beginDrinkingButton.enabled
        {
            beginDrinkingButtonNotClickedPopup()
        }
        
        else
        {
            user.drinkNumber += 1
            
            let now = NSDate()
            
            user.endTime = Int64(now.timeIntervalSince1970 * 1000)
            
            //show bac
            calculateBac()
            
            updateScreen()
            
            //update current bac
            //update drink number
            //update time till sober
            //add one drink to the count
            
            clearDrinksButton.enabled = true
            
            overwriteUserArray()
            saveUsers()
        }
    }
    
    @IBAction func beginDrinkingButton(sender: UIBarButtonItem)
    {
        if drink == nil
        {
            noDrinkSelectedBeginDrinkingButtonClickPopup()
        }
        
        else
        {
            //turn off beginDrinkingButton
            beginDrinkingButton.enabled = false
            
            let now = NSDate()
            
            user.beginTime = Int64(now.timeIntervalSince1970 * 1000)
            user.isCurrentlyDrinking = true
            
            overwriteUserArray()
            saveUsers()
        }
    }
    
    @IBAction func clearDrinksButton(sender: UIBarButtonItem)
    {
        //setting everything back to 0
        user.drinkNumber = 0
        user.currentBac = 0.0
        user.alcoholConsumedInGrams = 0
        user.beginTime = 0
        user.endTime = 0
        user.isCurrentlyDrinking = false
        
        //turn on beginDrinkingButton
        beginDrinkingButton.enabled = true
        
        updateScreen()
        
        overwriteUserArray()
        saveUsers()
    }
}
