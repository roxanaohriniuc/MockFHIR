//
//  MockFhir.swift
//  TempDemoV2
//
//  Created by roxana ohriniuc on 11/5/15.
//  Copyright © 2015 roxana ohriniuc. All rights reserved.
//

import Foundation

public class Practitioner : NSObject
{
    var Identifier : String;
    var Name : String;
    
    init(identifier : String, name : String)
    {
        Identifier = identifier;
        Name = name;
    }
}

public class Observation : NSObject
{
    var Observer : Practitioner;
    var Type : String;
    var Date : NSDate;
    var Value : String;
    var Unit : String;
    
    init(observer : Practitioner, observationType : String, observationDate :  NSDate, value : String, unit : String)
    {
        Observer = observer;
        Type = observationType;
        Date = observationDate;
        Value = value;
        Unit = unit;
    }
    
}


public class Patient : NSObject
{
    var Identifier : String;
    var Name : String;
    var Observations : [Observation];
    
    init(identifier : String, name : String)
    {
        Identifier = identifier;
        Name = name;
        Observations = [];
    }
}