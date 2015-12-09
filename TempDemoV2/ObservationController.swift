//
//  ObservationController.swift
//  TempDemoV2
//
//  Created by roxana ohriniuc on 11/2/15.
//  Copyright © 2015 roxana ohriniuc. All rights reserved.
//

import UIKit

class ObservationController: UITableViewController {
    
    //page data
    var practitioner : Practitioner? = nil;
    var patient : Patient? = nil;
    
    //format header
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! TableViewHeader
        if(patient != nil)
        {
            headerCell.headerLabel.text = (patient?.Name)!;
        }
        
        return headerCell;
    }
    
    //format list
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ObservationCell", forIndexPath: indexPath) as! ObservationCell;
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MMM, yyyy";
        let dateString : String = dateFormatter.stringFromDate((patient?.Observations[indexPath.row].Date)!);
        cell.DateLabel?.text = dateString;
        cell.TypeLabel?.text = patient?.Observations[indexPath.row].Type;
        
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (patient?.Observations.count)!;
    }
    
    //prepare next page
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "Observation-Patient")
        {
            let svc : PatientController = (segue.destinationViewController as! PatientController);
            svc.practitioner = practitioner;
        }
        else if(segue.identifier == "Observation-NewObservation") {
            let svc : NewObservationController = (segue.destinationViewController as! NewObservationController);
            svc.practitioner = practitioner;
            svc.patient = patient;
        }
        else if(segue.identifier == "Observation-ObservationDetail"){
            let svc : ObservationDetailController = (segue.destinationViewController as! ObservationDetailController);
            svc.practitioner = practitioner;
            svc.patient = patient;
            
            let index = tableView.indexPathForSelectedRow;
            svc.observation = patient?.Observations[(index?.row)!];
        }
        
    }
    
    //on page load
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
