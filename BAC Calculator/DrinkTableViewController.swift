//
//  DrinkTableViewController.swift
//  BAC Calculator
//
//  Created by Brandon Riehle on 2/25/16.
//  Copyright © 2016 Brandon Riehle. All rights reserved.
//

import UIKit

class DrinkTableViewController: UITableViewController
{
    // MARK: Properties
    var drinks = [Drink]()
    var user: User!
    var drink: Drink!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        //navigationItem.leftBarButtonItem = editButtonItem()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // Load any saved drinks
        if let savedDrinks = loadDrinks()
        {
            drinks += savedDrinks
        }
        
        //otherwise load sample data
        else
        {
            // Load the sample data.
            loadSampleDrinks()
        }
        
        self.navigationController?.toolbarHidden = false
    }
    
    func loadSampleDrinks()
    {
        let photo = UIImage(named: "reddsAppleAle")!
        let drink = Drink(name: "Redds Apple Ale", alcoholContent: 5,flozPerServing: 12, photo: photo, rating: 5)

        let photo2 = UIImage(named: "mikesHardLemonade")!
        let drink2 = Drink(name: "Mike's Hard Lemonade", alcoholContent: 5,flozPerServing: 12, photo: photo2, rating: 2)
        
        let photo3 = UIImage(named: "angryOrchard")!
        let drink3 = Drink(name: "Angry Orchard", alcoholContent: 5,flozPerServing: 12, photo: photo3, rating: 3)

        drinks += [drink, drink2, drink3]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return drinks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "DrinkTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DrinkTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let drink = drinks[indexPath.row]
        
        cell.nameLabel.text = drink.name
        cell.flozLabel.text = "\(drink.flozPerServing)" + " oz"
        cell.photoImageView.image = drink.photo
        cell.ratingControl.rating = drink.rating
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            // Delete the row from the data source
            drinks.removeAtIndex(indexPath.row)
            saveDrinks()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
            
        else if editingStyle == .Insert
        {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
//    override func setEditing(editing: Bool, animated: Bool)
//    {
//        super.setEditing(editing, animated: animated)
//        
//        
//        //tableView.reloadData()
//    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

     //MARK: - Navigation
     //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "ShowDetail"
        {
            let drinkDetailViewController = segue.destinationViewController as! DrinkViewController
            
            // Get the cell that generated this segue.
            if let selectedMealCell = sender as? DrinkTableViewCell
            {
                let indexPath = tableView.indexPathForCell(selectedMealCell)!
                let selectedDrink = drinks[indexPath.row]
                drinkDetailViewController.drink = selectedDrink
                drinkDetailViewController.user = user
            }
        }
        
        else if segue.identifier == "BackFromDrinkTable"
        {
            let mainMenuViewController = segue.destinationViewController as! MainMenuViewController
            
            mainMenuViewController.user = user
            mainMenuViewController.drink = drink
        }
    }
    
    @IBAction func unwindToDrinkList(sender: UIStoryboardSegue)
    {
        if let sourceViewController = sender.sourceViewController as? DrinkViewController, drink = sourceViewController.drink
        {
            if let selectedIndexPath = tableView.indexPathForSelectedRow
            {
                // Update an existing drink.
                drinks[selectedIndexPath.row] = drink
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }
                
            else
            {
                // Add a new drink.
                let newIndexPath = NSIndexPath(forRow: drinks.count, inSection: 0)
                drinks.append(drink)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            
            // Save the drinks whenever a new one is added or an existing one is updated
            saveDrinks()
        }
    }
    
    // MARK: NSCoding
    func saveDrinks()
    {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(drinks, toFile: Drink.ArchiveURL.path!)
        
        if !isSuccessfulSave
        {
            print("Failed to save drinks...")
        }
    }
    
    //This method attempts to unarchive the object stored at the path Drink.ArchiveURL.path! and downcast that object to an array of Drink objects
    func loadDrinks() -> [Drink]?
    {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Drink.ArchiveURL.path!) as? [Drink]
    }
}
