//
//  AgencyController.swift
//  Busy Buses
//
//  Created by Jonathan Sheu on 12/5/15.
//  Copyright © 2015 Jonathan Sheu. All rights reserved.
//

import UIKit

class AgencyController: UITableViewController, UISearchResultsUpdating {
    var agenciesJSON = JSON(NSData)
    var agencyNames: [String] = []
    var agencyIDs: [String] = []
    @IBOutlet var listView: UITableView!
    var filteredTableData = [String]()
    var nameToID = [String: String]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeSearchController()
        let url = NSURL(string: "http://restbus.info/api/agencies/")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) -> Void in
            if error == nil {
                self.agenciesJSON = JSON(data: data!)
                self.loadAgencyNames()
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.active) {
            return self.filteredTableData.count
        }
        else {
            return self.agencyNames.count
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredTableData.removeAll(keepCapacity: false)
        if searchController.searchBar.text == "" {
            filteredTableData = agencyNames
        } else {
            let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
            let array = (agencyNames as NSArray).filteredArrayUsingPredicate(searchPredicate)
            filteredTableData = array as! [String]
        }
        self.tableView.reloadData()
    }
    
    func loadAgencyNames() {
        for (_, info):(String, JSON) in self.agenciesJSON {
            self.agencyNames.append(info["title"].string!)
            self.agencyIDs.append(info["id"].string!)
            nameToID[info["title"].string!] = info["id"].string!
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self.listView.reloadData();
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AgencyCell", forIndexPath: indexPath)
        if (self.resultSearchController.active) {
            cell.textLabel?.text = filteredTableData[indexPath.row]
        } else {
            cell.textLabel?.text = agencyNames[indexPath.row]
        }
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLines" {
            if let destination = segue.destinationViewController as? BusLineController {
                let index = tableView.indexPathForSelectedRow!.row
                if (self.resultSearchController.active) {
                    destination.agencyName = filteredTableData[index]
                    destination.agencyID = nameToID[filteredTableData[index]]!
                } else {
                    destination.agencyName = self.agencyNames[index]
                    destination.agencyID = self.agencyIDs[index]
                }
                let backItem = UIBarButtonItem()
                backItem.title = "Agencies"
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
}
