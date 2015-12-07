//
//  StopView.swift
//  Busy Buses
//
//  Created by Jonathan Sheu on 12/5/15.
//  Copyright © 2015 Jonathan Sheu. All rights reserved.
//

import UIKit
import AVFoundation

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
    var intervalPicker: UIPickerView!
    let intervalPickerValues = ["1", "2"]
    @IBOutlet var intervalInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = stopName
        listView.dataSource = self
        listView.delegate = self
        intervalPicker = UIPickerView()
        intervalPicker.dataSource = self
        intervalPicker.delegate = self
        intervalInput.inputView = intervalPicker
        
        audioEnabled.setOn(false, animated: false)
        self.loadPredictions()
    }
    
    override func viewWillDisappear(animated: Bool) {
        audioEnabled.setOn(false, animated: false)
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
    }
    
    func loadPredictions() {
        let url = NSURL(string: "http://restbus.info/api/agencies/" + agencyID + "/routes/" + lineName + "/stops/" + stopID + "/predictions")
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
            if lastTime.isEmpty || abs(Int(lastTime)! - Int(self.predictions[0])!) >= 1 {
                self.sayTimes()
            }
            self.delayedRefresh()
        }
    }
    
    @IBAction func buttonClicked(sender: AnyObject) {
        self.sayTimes()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PredictionCell", forIndexPath: indexPath)
        let time = Int(predictions[indexPath.row])
        if time == 0 {
            cell.textLabel?.text = "Arriving"
        } else if time == 1 {
            cell.textLabel?.text = "1 minute"
        } else {
            cell.textLabel?.text = String(time!) + " minutes"
        }
        cell.imageView!.image = UIImage(named: "bus.png")!
        return cell
    }
    
    func delayedRefresh() {
        let seconds = 60.0
        let delay = seconds * Double(NSEC_PER_SEC)
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.loadPredictions()
        })
    }
    
    func sayTimes() {
        if !audioEnabled.on {
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
        let utterance = AVSpeechUtterance(string: text)
        speechSynthesizer.speakUtterance(utterance)
    }
}
