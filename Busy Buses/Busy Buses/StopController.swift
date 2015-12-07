//
//  StopController.swift
//  Busy Buses
//
//  Created by Jonathan Sheu on 12/5/15.
//  Copyright © 2015 Jonathan Sheu. All rights reserved.
//

import UIKit

class StopController: UITableViewController {
    var agencyName = String()
    var agencyID = String()
    var lineName = String()
    var lineID = String()
    var directionName = String()
    var directionID = String()
    var routeJSON = JSON(NSData)
    var stopNames: [String] = []
    var stopIDs: [String] = []
    var stopDict = [String: String]()
    @IBOutlet var listView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = directionName
        processRoutes()
    }
    
    func processRoutes() {
        for (_, info):(String, JSON) in self.routeJSON["stops"] {
            stopDict[info["id"].string!] = info["title"].string!
        }
        for (_, info):(String, JSON) in self.routeJSON["directions"] {
            if info["title"].string! == directionName {
                for (_, entry) in info["stops"] {
                    self.stopIDs.append(entry.string!)
                    self.stopNames.append(stopDict[entry.string!]!)
                }
            }
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self.listView.reloadData();
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stopNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StopCell", forIndexPath: indexPath)
        cell.textLabel?.text = stopNames[indexPath.row]
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showStop" {
            if let destination = segue.destinationViewController as? StopView {
                let index = tableView.indexPathForSelectedRow!.row
                destination.agencyName = self.agencyName
                destination.agencyID = self.agencyID
                destination.lineName = self.lineName
                destination.lineID = self.lineID
                destination.directionName = self.directionName
                destination.directionID = self.directionID
                destination.stopName = self.stopNames[index]
                destination.stopID = self.stopIDs[index]
                let backItem = UIBarButtonItem()
                backItem.title = "Stops"
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
}
