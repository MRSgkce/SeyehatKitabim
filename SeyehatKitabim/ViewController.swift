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
    
    var selectedTitle = ""
    var selectedTitleIID : UUID?
    
    var annotationtitle = ""
    var annotationsubtitle = ""
    var annotationlatitdu = Double()
    var annotationlongitdu = Double()
    
    
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
        
        if selectedTitle != "" {
       
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleIID!.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    
                    for result in results as! [NSManagedObject]{
                        if let title = result.value(forKey: "title") as? String{
                            annotationtitle = title
                            if let subtitle = result.value(forKey: "subtitle") as? String{
                                annotationsubtitle = subtitle
                                if let latitude = result.value(forKey: "latitude") as? Double{
                                    annotationlatitdu = latitude
                                    if let longitude = result.value(forKey: "longitute") as? Double{
                                        annotationlongitdu = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationtitle
                                        annotation.subtitle = annotationsubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationlatitdu, longitude: annotationlongitdu)
                                        annotation.coordinate = coordinate
                                        mapKit.addAnnotation(annotation)
                                        
                                        nameplace.text = annotationtitle
                                        aciklamaplace.text = annotationsubtitle
                                        
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapKit.setRegion(region, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }catch {
                print("error")
            }
            
            
            
        }else{
            
        }
  
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
        if selectedTitle == ""{
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location, span: span)
            mapKit.setRegion(region, animated: true)
        } else{
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        //bu fonksiyonu yazarsak özelleştirmiş point oluyor
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation : annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }
        else{
            pinView?.annotation = annotation
        }
        return pinView
        
        
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //navigasyon ekleme için
        if selectedTitle != ""{
            var requestLocation = CLLocation(latitude: annotationlatitdu, longitude: annotationlongitdu)
            CLGeocoder().reverseGeocodeLocation(requestLocation){
                (placemarks,error ) in
                if let placemark = placemarks{
                    if placemark.count > 0{
                        
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        
                    let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.annotationtitle
                        let launchoptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchoptions)
                    }
                    
                }
            }
        }
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
        
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
        navigationController?.popViewController(animated: true)
    }
}

