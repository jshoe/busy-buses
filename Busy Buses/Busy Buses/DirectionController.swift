//
//  DirectionController.swift
//  Busy Buses
//
//  Created by Jonathan Sheu on 12/5/15.
//  Copyright © 2015 Jonathan Sheu. All rights reserved.
//

import UIKit

class DirectionController: UITableViewController {
    var agencyName = String()
    var agencyID = String()
    var lineName = String()
    var lineID = String()
    var directionNames: [String] = []
    var directionIDs: [String] = []
    var directionsJSON = JSON(NSData)
    @IBOutlet var listView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = lineName + " Line"
        let url = NSURL(string: "http://restbus.info/api/agencies/" + agencyID + "/routes/" + lineID)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) -> Void in
            if error == nil {
                self.directionsJSON = JSON(data: data!)
                self.loadDirections()
            }
        }
        task.resume()
    }
    
    func loadDirections() {
        for (_, info):(String, JSON) in self.directionsJSON["directions"] {
            self.directionNames.append(info["title"].string!)
            self.directionIDs.append(info["id"].string!)
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self.listView.reloadData();
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directionNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DirectionCell", forIndexPath: indexPath)
        cell.textLabel?.text = directionNames[indexPath.row]
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showStops" {
            if let destination = segue.destinationViewController as? StopController {
                let index = tableView.indexPathForSelectedRow!.row
                destination.agencyName = self.agencyName
                destination.agencyID = self.agencyID
                destination.lineName = self.lineName
                destination.lineID = self.lineID
                destination.directionName = self.directionNames[index]
                destination.directionID = self.directionIDs[index]
                destination.routeJSON = self.directionsJSON
                let backItem = UIBarButtonItem()
                backItem.title = "Directions"
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
}