//
//  PatientController.swift
//  TempDemoV2
//
//  Created by roxana ohriniuc on 10/25/15.
//  Copyright © 2015 roxana ohriniuc. All rights reserved.
//

import UIKit

class PatientController: UIViewController {
    
    @IBOutlet weak var label_PatientStatus: UILabel!
    @IBOutlet weak var Label_Practitioner: UILabel!;
    @IBOutlet weak var btn_PatientLogin: UIButton!;
    
    var practitioner : Practitioner? = nil;
    var practitioners : [Practitioner] = [];
    var patient : Patient? = nil;
    var patients : [Patient] = [];
    
    func LoadPractitioners()
    {
        let url = NSURL(string : "https://mock-fhir-api.herokuapp.com/api/practitioners");
        let request = NSMutableURLRequest(URL: url!);
        let session = NSURLSession.sharedSession();
        request.HTTPMethod = "GET";
        
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if(error != nil){
                print(error!.localizedDescription)
            }
            
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSArray {
                    for prac in jsonResult{
                        self.practitioners.append(Practitioner(identifier: prac["_id"] as! String, name: prac["name"] as! String));
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        })
        
        task.resume();
        
    }
    
    func LoadPatients()
    {
        let url = NSURL(string : "https://mock-fhir-api.herokuapp.com/api/patients");
        let request = NSMutableURLRequest(URL: url!);
        let session = NSURLSession.sharedSession();
        request.HTTPMethod = "GET";
        
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if(error != nil){
                print(error!.localizedDescription)
            }
            
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSArray {
                    for pat in jsonResult{
                        self.patients.append(Patient(identifier: pat["_id"] as! String, name: pat["name"] as! String));
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        });
        
        task.resume();
    }
    
    func getPatientObservations()
    {
        let url = NSURL(string : "https://mock-fhir-api.herokuapp.com/api/patients/"+(patient?.Identifier)!+"/observations");
        let request = NSMutableURLRequest(URL: url!);
        let session = NSURLSession.sharedSession();
        request.HTTPMethod = "GET";
        
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if(error != nil){
                print(error!.localizedDescription)
            }
            
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSArray {
                    for obs in jsonResult{
                        let obsPrac = self.getObservationPractitioner(obs["practitionerId"] as! String);
                        let type = obs["type"] as! String;
                        
                        let sdate = (obs["date"] as! String);
                        let index : String.Index = sdate.startIndex.advancedBy(10);
                        let dateFormatter = NSDateFormatter();
                        dateFormatter.dateFormat = "yyyy-MM-dd";
                        let sdate2 = sdate.substringToIndex(index);
                        let date = dateFormatter.dateFromString(sdate2);
                        let value = obs["value"] as! String;
                        let unit = obs["unit"] as! String;
                        
                        self.patient?.Observations.append(Observation(observer: obsPrac, observationType: type, observationDate: date!, value: value, unit: unit));
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        });
        
        task.resume();
    }
    
    func getObservationPractitioner(practitionerId : String)-> Practitioner
    {
        for p in practitioners{
            if(p.Identifier == practitionerId){
                return p;
            }
        }
        return Practitioner(identifier: practitionerId, name: "Unknown");
    }
    
    func validatePatient(code : String) -> Bool
    {
        for p in patients{
            if(p.Identifier == code){
                patient = p;
                return true;
            }
        }
        return false;
    }

    func patientFromCode(code : String)
    {
        if(validatePatient(code)){
            label_PatientStatus.text = "Open Records for " + (patient?.Name)!;
            label_PatientStatus.textColor = UIColor.greenColor();
            btn_PatientLogin.enabled = true;
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "Patient-Observation") {
            getPatientObservations();
            let svc : ObservationController = (segue.destinationViewController as! ObservationController)
            svc.practitioner = practitioner;
            svc.patient = patient;
        }
        
    }
    
    @IBAction func OpenPatient_Click(sender: UIButton) {
        
        if patient != nil {
            self.performSegueWithIdentifier("Patient-Observation", sender: self)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Label_Practitioner.text = (practitioner?.Name)!;
        LoadPractitioners();
        LoadPatients();
        
        
        btn_PatientLogin.enabled = false;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

