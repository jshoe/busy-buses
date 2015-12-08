//
//  BusLineController.swift
//  Busy Buses
//
//  Created by Jonathan Sheu on 12/5/15.
//  Copyright © 2015 Jonathan Sheu. All rights reserved.
//

import UIKit

class BusLineController: UITableViewController, UISearchResultsUpdating {
    var agencyName = String()
    var agencyID = String()
    var lineNames: [String] = []
    var lineIDs: [String] = []
    var lineJSON = JSON(NSData)
    @IBOutlet var listView: UITableView!
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeSearchController()
        self.title = agencyName + " Lines"
        let url = NSURL(string: "http://restbus.info/api/agencies/" + agencyID + "/routes/")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) -> Void in
            if error == nil {
                self.lineJSON = JSON(data: data!)
                self.loadBusLines()
            }
        }
        task.resume()
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
    
    func loadBusLines() {
        for (_, info):(String, JSON) in self.lineJSON {
            self.lineNames.append(info["title"].string!)
            self.lineIDs.append(info["id"].string!)
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self.listView.reloadData();
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.active) {
            return self.filteredTableData.count
        }
        else {
            return self.lineNames.count
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredTableData.removeAll(keepCapacity: false)
        if searchController.searchBar.text == "" {
            filteredTableData = lineNames
        } else {
            let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
            let array = (lineNames as NSArray).filteredArrayUsingPredicate(searchPredicate)
            filteredTableData = array as! [String]
        }
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LineCell", forIndexPath: indexPath)
        if (self.resultSearchController.active) {
            cell.textLabel?.text = filteredTableData[indexPath.row]
        } else {
            cell.textLabel?.text = lineNames[indexPath.row]
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDirections" {
            if let destination = segue.destinationViewController as? DirectionController {
                let index = tableView.indexPathForSelectedRow!.row
                destination.agencyName = self.agencyName
                destination.agencyID = self.agencyID
                destination.lineName = self.lineNames[index]
                destination.lineID = self.lineIDs[index]
                let backItem = UIBarButtonItem()
                backItem.title = "Lines"
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
}
