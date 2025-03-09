//
//  ViewController.swift
//  SeyehatKitabim
//
//  Created by Mürşide Gökçe on 9.03.2025.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var aciklamaplace: UITextField!
    @IBOutlet weak var nameplace: UITextField!
    
    var locationManager = CLLocationManager()
    @IBOutlet weak var mapKit: MKMapView!
    var choselongitude = Double()
    var chosenlatitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapKit.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooselocation(gestureRecognizer:)))
        
        gestureRecognizer.minimumPressDuration = 2
        mapKit.addGestureRecognizer(gestureRecognizer)
  
    }
    
    @objc func chooselocation(gestureRecognizer: UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began{
            let touchedPoint = gestureRecognizer.location(in: self.mapKit)
            let touchedCoordinate = self.mapKit.convert(touchedPoint, toCoordinateFrom: self.mapKit)
            chosenlatitude = touchedCoordinate.latitude
            choselongitude = touchedCoordinate.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinate
            annotation.title = nameplace.text!
            annotation.subtitle = aciklamaplace.text!
            self.mapKit.addAnnotation(annotation)
            
            
        }}
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapKit.setRegion(region, animated: true)
    }


    @IBAction func save(_ sender: Any) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(nameplace.text, forKey: "title")
        newPlace.setValue(aciklamaplace.text, forKey: "subtitle")
        newPlace.setValue(UUID(), forKey: "id")
        newPlace.setValue(choselongitude, forKey: "longitute")
        newPlace.setValue(chosenlatitude, forKey: "latitude")
        
        do{
             try context.save()
            print("başarılı")
        }catch{
            
        }
    }
}

