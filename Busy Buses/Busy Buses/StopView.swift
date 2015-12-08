//
//  StopView.swift
//  Busy Buses
//
//  Created by Jonathan Sheu on 12/5/15.
//  Copyright © 2015 Jonathan Sheu. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class StopView: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    var agencyName = String()
    var agencyID = String()
    var lineName = String()
    var lineID = String()
    var directionName = String()
    var directionID = String()
    var stopName = String()
    var stopID = String()
    var predictionsJSON = JSON(NSData)
    var predictions: [String] = []
    var headerTitle = "Loading..."
    var lastTime = String()
    var readoutInterval = Int()
    @IBOutlet var listView: UITableView!
    @IBOutlet var audioEnabled: UISwitch!
    var intervalPicker = UIPickerView()
    let intervalPickerValues = ["Auto Interval", "Every 1 minute", "Every 5 minutes", "Every 10 minutes", "Every 20 minutes"]
    @IBOutlet var intervalInput: UITextField!
    @IBOutlet var favoriteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = stopName
        self.navigationController?.setToolbarHidden(false, animated: true)
        listView.dataSource = self
        listView.delegate = self
        intervalPicker.dataSource = self
        intervalPicker.delegate = self
        intervalInput.inputView = intervalPicker
        intervalInput.text = "Auto Interval"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        audioEnabled.setOn(false, animated: false)
        self.loadPredictions()
    }
    
    override func viewWillDisappear(animated: Bool) {
        audioEnabled.setOn(false, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return intervalPickerValues.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return intervalPickerValues[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        intervalInput.text = intervalPickerValues[row]
        self.view.endEditing(true)
        self.sayTimes()
    }
    
    func loadPredictions() {
        let url = NSURL(string: "http://restbus.info/api/agencies/" + agencyID + "/routes/" + lineID + "/stops/" + stopID + "/predictions")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) -> Void in
            if error == nil {
                self.predictionsJSON = JSON(data: data!)
                self.parsePredictions()
            }
        }
        task.resume()
    }
    
    func parsePredictions() {
        if self.predictions.count != 0 {
            lastTime = self.predictions[0]
        }
        self.predictions.removeAll()
        for (_, info):(String, JSON) in self.predictionsJSON[0]["values"] {
            self.predictions.append(String(info["minutes"].int!))
        }
        if self.predictions.count == 0 {
            headerTitle = "No incoming buses!"
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self.listView.reloadData();
            }
        } else {
            headerTitle = "Next bus times:"
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self.listView.reloadData();
            }
            delay(60.0) {
                self.loadPredictions()
            }
        }
    }
    
    @IBAction func buttonClicked(sender: AnyObject) {
        if audioEnabled.on {
            intervalInput.hidden = false
        } else {
            intervalInput.hidden = true
        }
        self.sayTimes()
    }
    
    @IBAction func buttonAction(sender: UIBarButtonItem!) {
        saveToFavorites()
    }

    func getAudioInterval() -> Int {
        let cur = intervalInput.text
        if cur == "Auto Interval" {
            let next = Int(self.predictions[0])
            if next > 40 {
                return 20
            } else if next > 30 {
                return 10
            } else if next > 10 {
                return 5
            } else {
                return 1
            }
        } else if cur == "Every 1 minute" {
            return 1
        } else if cur == "Every 5 minutes" {
            return 5
        } else if cur == "Every 10 minutes" {
            return 10
        } else if cur == "Every 20 minutes" {
            return 20
        }
        return 5
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PredictionCell", forIndexPath: indexPath)
        if indexPath.row >= predictions.count {
            return cell
        }
        let time = Int(predictions[indexPath.row])
        if time == 0 {
            cell.textLabel?.text = "Arriving now"
        } else if time == 1 {
            cell.textLabel?.text = "1 minute"
        } else {
            cell.textLabel?.text = String(time!) + " minutes"
        }
        cell.imageView!.image = UIImage(named: "bus.png")!
        return cell
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    func sayTimes() {
        if !audioEnabled.on || self.predictions.isEmpty {
            print("No predictions")
            return
        }
        let speechSynthesizer = AVSpeechSynthesizer()
        let time = Int(self.predictions[0])
        var text = String()
        if time == 0 {
            text = "The next bus is arriving now."
        } else if time == 1 {
            text = "The next bus comes in 1 minute."
        } else {
            text = "The next bus comes in " + String(time!) + " minutes."
        }
        print(text)
        speechSynthesizer.speakUtterance(AVSpeechUtterance(string: text))
        delay(Double(self.getAudioInterval() * 60 + 5)) {
            self.sayTimes()
        }
    }
    
    func saveToFavorites() {
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDel.managedObjectContext
        let entity = NSEntityDescription.entityForName("Fav_stop", inManagedObjectContext: managedContext)
        let favorite = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        favorite.setValue(agencyName, forKey: "agencyName")
        favorite.setValue(agencyID, forKey: "agencyID")
        favorite.setValue(lineName, forKey: "lineName")
        favorite.setValue(lineID, forKey: "lineID")
        favorite.setValue(directionName, forKey: "directionName")
        favorite.setValue(directionID, forKey: "directionID")
        favorite.setValue(stopName, forKey: "stopName")
        favorite.setValue(stopID, forKey: "stopID")
        do {
            try managedContext.save()
        } catch _ as NSError {
            print("Unsuccessful save.")
        }
    }
}
