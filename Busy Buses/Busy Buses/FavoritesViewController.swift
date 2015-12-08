//
//  FavoritesViewController.swift
//  Busy Buses
//
//  Created by Jonathan Sheu on 12/7/15.
//  Copyright © 2015 Jonathan Sheu. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UITableViewController {
    var agencyNames: [String] = []
    var agencyIDs: [String] = []
    var lineNames: [String] = []
    var lineIDs: [String] = []
    var directionNames: [String] = []
    var directionIDs: [String] = []
    var stopNames: [String] = []
    var stopIDs: [String] = []
    @IBOutlet var listView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFavorites()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        loadFavorites()
    }
    
    func loadFavorites() {
        self.agencyNames.removeAll()
        self.agencyIDs.removeAll()
        self.lineNames.removeAll()
        self.lineIDs.removeAll()
        self.directionNames.removeAll()
        self.directionIDs.removeAll()
        self.stopNames.removeAll()
        self.stopIDs.removeAll()
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDel.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Fav_stop")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            let result = results as! [NSManagedObject]
            for item in result {
//                print(item.valueForKey("stopName") as? String)
                self.agencyNames.append((item.valueForKey("agencyName") as? String)!)
                self.agencyIDs.append((item.valueForKey("agencyID") as? String)!)
                self.lineNames.append((item.valueForKey("lineName") as? String)!)
                self.lineIDs.append((item.valueForKey("lineID") as? String)!)
                self.directionNames.append((item.valueForKey("directionName") as? String)!)
                self.directionIDs.append((item.valueForKey("directionID") as? String)!)
                self.stopNames.append((item.valueForKey("stopName") as? String)!)
                self.stopIDs.append((item.valueForKey("stopID") as? String)!)
            }
        } catch _ as NSError {
            print("Error loading favorites.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stopNames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favoriteCell", forIndexPath: indexPath)
        cell.textLabel?.text = stopNames[indexPath.row]
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showStop" {
            if let destination = segue.destinationViewController as? StopView {
                let index = tableView.indexPathForSelectedRow!.row
                destination.agencyName = self.agencyNames[index]
                destination.agencyID = self.agencyIDs[index]
                destination.lineName = self.lineNames[index]
                destination.lineID = self.lineIDs[index]
                destination.directionName = self.directionNames[index]
                destination.directionID = self.directionIDs[index]
                destination.stopName = self.stopNames[index]
                destination.stopID = self.stopIDs[index]
                let backItem = UIBarButtonItem()
                backItem.title = "Favorites"
                navigationItem.backBarButtonItem = backItem
            }
        }
    }

}
