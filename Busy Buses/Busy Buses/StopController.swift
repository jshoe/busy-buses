//
//  StopController.swift
//  Busy Buses
//
//  Created by Jonathan Sheu on 12/5/15.
//  Copyright © 2015 Jonathan Sheu. All rights reserved.
//

import UIKit

class StopController: UITableViewController, UISearchResultsUpdating {
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
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeSearchController()
        self.title = directionName
        if routeJSON.isEmpty {
            self.loadBusData()
        } else {
            processRoutes()
        }
    }
    
    func makeSearchController() {
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.resultSearchController.active = false
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
    
    func loadBusData() {
        let url = NSURL(string: "http://restbus.info/api/agencies/" + agencyID + "/routes/")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) -> Void in
            if error == nil {
                self.routeJSON = JSON(data: data!)
                self.processRoutes()
            }
        }
        task.resume()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.active) {
            return self.filteredTableData.count
        }
        else {
            return self.stopNames.count
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredTableData.removeAll(keepCapacity: false)
        if searchController.searchBar.text == "" {
            filteredTableData = stopNames
        } else {
            let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
            let array = (stopNames as NSArray).filteredArrayUsingPredicate(searchPredicate)
            filteredTableData = array as! [String]
        }
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StopCell", forIndexPath: indexPath)
        if (self.resultSearchController.active) {
            cell.textLabel?.text = filteredTableData[indexPath.row]
        } else {
            cell.textLabel?.text = stopNames[indexPath.row]
        }
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
