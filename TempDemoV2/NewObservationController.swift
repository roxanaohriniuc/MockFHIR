//
//  NewObservationController.swift
//  TempDemoV2
//
//  Created by roxana ohriniuc on 10/20/15.
//  Copyright © 2015 roxana ohriniuc. All rights reserved.
//

import UIKit
import CoreBluetooth

class NewObservationController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate
 {
    // BLE
    var centralManager : CBCentralManager!
    var connectedPeripheral : CBPeripheral?
    // IR Temp UUIDs
    let ServiceUUID = CBUUID(string: "F000AA00-0451-4000-B000-000000000000");
    let DataUUID   = CBUUID(string: "F000AA01-0451-4000-B000-000000000000");

    //controls
    @IBOutlet weak var btn_Bluetooth: UIButton!
    @IBOutlet weak var label_BluetoothDevice: UILabel!
    @IBOutlet weak var tb_Type: UITextField!
    @IBOutlet weak var tb_Value: UITextField!
    @IBOutlet weak var tb_Unit: UITextField!
    
    //data
    var practitioner : Practitioner? = nil;
    var patient : Patient? = nil;
    //bluetooth device
    var btDeviceName : String? = nil;

    
    //events
    @IBAction func Bluetooth_Click(sender: UIButton) {
        if(connectedPeripheral == nil)
        {
            if centralManager?.state == CBCentralManagerState.PoweredOn {
                // Scan for peripherals if BLE is turned on
                centralManager?.scanForPeripheralsWithServices(nil, options: nil);
                label_BluetoothDevice.text = "Scanning...";
            }
        }
        else
        {
            self.centralManager?.stopScan();
            connectedPeripheral = nil;
            label_BluetoothDevice.text = "No Device Connected...";
            btn_Bluetooth.setImage(UIImage(named: "bt-disconnected.png"), forState: UIControlState.Normal);
        }
    }
    func centralManagerDidUpdateState(central: CBCentralManager){}
    
    // Check out the discovered peripherals to find Thermometer
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!,advertisementData: [NSObject : AnyObject]!){//, RSSI: NSNumber!){
        
        //let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        
        //if is my device
        if (true) {
            // Stop scanning
            self.centralManager?.stopScan();
            
            // Set as the peripheral to use and establish connection
            connectedPeripheral = peripheral;
            connectedPeripheral?.delegate = self
            self.centralManager?.connectPeripheral(peripheral, options: nil)
            
        }
    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.discoverServices(nil);//replace nil with something to find specific service
    }
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // check the uuid of each characteristic to find data characteristics
        for charateristic in service.characteristics! {
            let thisCharacteristic = charateristic as CBCharacteristic
            // check for data characteristic
            if thisCharacteristic.UUID == DataUUID {
                // Enable Sensor Notification
                self.connectedPeripheral?.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
        }
        
    }
    
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral?!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        // Update Status Label
        label_BluetoothDevice.text = peripheral?!.name;
        btn_Bluetooth.setImage(UIImage(named: "bt-connected.png"), forState: UIControlState.Normal);
        
        if characteristic.UUID == DataUUID {
            // Convert NSData to array of signed 16 bit values
            let dataBytes = characteristic.value
            let dataLength = dataBytes!.length
            var dataArray = [Int16](count: dataLength, repeatedValue: 0)
            dataBytes!.getBytes(&dataArray, length: dataLength * sizeof(Int16))
            
            // Element 1 of the array will be ambient temperature raw value
            //let ambientTemperature = Double(dataArray[1])/128
            //tb_Value.text = ambientTemperature;
        }
    }
    func PostObservation(observation : Observation)
    {
        let url = NSURL(string: "https://mock-fhir-api.herokuapp.com/api/observations");
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let postString = "patientId=" + (patient?.Identifier)! + "&type=temperature&practitionerId="  + (practitioner?.Identifier)! +
                            "&value=" + observation.Value + "&unit=" + observation.Unit;
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    @IBAction func Submit_Click(sender: UIButton) {
        if(ValidInput())
        {
            let newObservation : Observation = Observation(observer: practitioner!, observationType: tb_Type.text!, observationDate: NSDate(), value: tb_Value.text!, unit: tb_Unit.text!);
            patient?.Observations.insert(newObservation, atIndex: 0);
            
            //Post data to FHIR or web server!
            PostObservation(newObservation);
            
            self.performSegueWithIdentifier("NewObservation-Observation", sender: self);
        }
    }
    
    
    //validates input
    func ValidInput() -> Bool{
        if((tb_Type.text ?? "").isEmpty)
        {Alert("Validation Error", Message: "Type is required.");}
        else if((tb_Value.text ?? "").isEmpty)
        {Alert("Validation Error", Message: "Value is required.");}
        else if((tb_Unit.text ?? "").isEmpty)
        {Alert("Validation Error", Message: "Unit is required.");}
        else
        {return true;}
        
        return false;
    }
    
    func Alert(Title: String, Message : String)
    {
        let alertController = UIAlertController(title: Title, message:
            Message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    //prepare next page
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "NewObservation-Observation")
        {
            let svc : ObservationController = (segue.destinationViewController as! ObservationController);
            svc.practitioner = practitioner;
            svc.patient = patient;
        }

    }
    
    //on page load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize central manager on load
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
