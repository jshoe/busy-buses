//
//  BusLineController.swift
//  Busy Buses
//
//  Created by Jonathan Sheu on 12/5/15.
//  Copyright © 2015 Jonathan Sheu. All rights reserved.
//

import UIKit

class BusLineController: UITableViewController {
    var agencyName = String()
    var agencyID = String()
    var lineNames: [String] = []
    var lineIDs: [String] = []
    var lineJSON = JSON(NSData)
    @IBOutlet var listView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return lineNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LineCell", forIndexPath: indexPath)
        cell.textLabel?.text = lineNames[indexPath.row]
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
                backItem.title = "All Lines"
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
}
