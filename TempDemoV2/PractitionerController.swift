//
//  PractitionerController.swift
//  TempDemoV2
//
//  Created by roxana ohriniuc on 10/20/15.
//  Copyright © 2015 roxana ohriniuc. All rights reserved.
//

import UIKit

class PractitionerController: UIViewController {
    
    var practitioner : Practitioner? = nil;
    var practitioners : [Practitioner] = [];
    
    @IBOutlet weak var label_PractitionerStatus: UILabel!
    @IBOutlet weak var btn_Login: UIButton!;
    
    @IBAction func PractitionerLogin_Click(sender: UIButton) {
        if practitioner != nil {
            self.performSegueWithIdentifier("Practitioner-Patient", sender: self)
        }
    }
    
    func LoadPractitoners()
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
    
    func validateInput(code : String) -> Bool {
        for p in practitioners {
            if(p.Identifier == code){
                practitioner = p;
                return true;
            }
        }
        return false;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // prepare for next view: send practitioner name to the next screen
        if(segue.identifier == "Practitioner-Patient") {
            let svc : PatientController = (segue.destinationViewController as! PatientController)
            svc.practitioner = practitioner;
            
        }
        for child in childViewControllers
        {
            if let child = child as? ScannerViewController{
                child.stop();
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadPractitoners();
        btn_Login.enabled = false;

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func practicionerFromCode(code : String)
    {
        if(validateInput(code))
        {
            label_PractitionerStatus.text = "Login as " + (practitioner?.Name)!;
            label_PractitionerStatus.textColor = UIColor.greenColor();
            btn_Login.enabled = true;
        }
    }
    
    func Alert(Title: String, Message : String)
    {
        let alertController = UIAlertController(title: Title, message:
            Message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}