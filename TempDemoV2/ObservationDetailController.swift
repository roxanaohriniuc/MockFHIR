//
//  ObservationDetailController.swift
//  TempDemoV2
//
//  Created by roxana ohriniuc on 10/25/15.
//  Copyright © 2015 roxana ohriniuc. All rights reserved.
//

import UIKit

class ObservationDetailController: UIViewController {
    //page controls
    @IBOutlet weak var view_ObservationContainer: UIView!
    @IBOutlet weak var label_ObservationDate: UILabel!
    @IBOutlet weak var label_ObservationType: UILabel!
    @IBOutlet weak var label_ObservationValue: UILabel!
    @IBOutlet weak var label_ObservationPractitioner: UILabel!
    
    //page data
    var practitioner : Practitioner? = nil;
    var patient : Patient? = nil;
    var observation : Observation? = nil;
    
    //prepare next page
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ObservationDetail-Observation")
        {
            let svc : ObservationController = (segue.destinationViewController as! ObservationController);
            svc.practitioner = practitioner;
            svc.patient = patient;
        }
        
    }
    
    //on page load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add border to conatiner
        view_ObservationContainer.layer.borderWidth = 5;
        view_ObservationContainer.layer.borderColor = UIColor(red: 132, green: 108, blue: 251, alpha: 1.0).CGColor;
        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MMMM dd, yyyy";
        let dateString : String = dateFormatter.stringFromDate((observation?.Date)!);
        
        label_ObservationDate.text = dateString;
        label_ObservationType.text = (observation?.Type)! + ":";
        label_ObservationValue.text = (observation?.Value)! + " " + (observation?.Unit)!;
        label_ObservationPractitioner.text = (observation?.Observer.Name)!;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
