//
//  AgencyController.swift
//  Busy Buses
//
//  Created by Jonathan Sheu on 12/5/15.
//  Copyright © 2015 Jonathan Sheu. All rights reserved.
//

import UIKit

class AgencyController: UITableViewController {
    var agenciesJSON = JSON(NSData)
    var agencyNames: [String] = []
    var agencyIDs: [String] = []
    @IBOutlet var listView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func loadAgencyNames() {
        for (_, info):(String, JSON) in self.agenciesJSON {
            self.agencyNames.append(info["title"].string!)
            self.agencyIDs.append(info["id"].string!)
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self.listView.reloadData();
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agencyNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AgencyCell", forIndexPath: indexPath)
        cell.textLabel?.text = agencyNames[indexPath.row]
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLines" {
            if let destination = segue.destinationViewController as? BusLineController {
                let index = tableView.indexPathForSelectedRow!.row
                destination.agencyName = self.agencyNames[index]
                destination.agencyID = self.agencyIDs[index]
            }
        }
    }
}
