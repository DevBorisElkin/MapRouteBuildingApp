//
//  ViewController.swift
//  MapRouteBuildingApp
//
//  Created by test on 15.05.2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    let mapView : MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let addAddressButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "button_address"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let routeButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "button_route"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let resetButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "button_reset"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    var annotationsArray = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setConstraints()
        
        //print(testClassVariable.number)
        //testClassVariable = TestClass()
        
        addAddressButton.addTarget(self, action: #selector(addAddressButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }

    @objc func addAddressButtonTapped(){
        //print("TapAdd")
        alertAddAddress(title: "Add", placeholder: "Enter Address") { [self] (text) in
            print(text)
            setupPlacemark(addressPlace: text)
        }
        
        //alertError(title: "Error", message: "Something went wrong")
    }
    
    @objc func routeButtonTapped(){
        
        for index in 0...annotationsArray.count - 2{
            
            createDirectionRequest(startCoordinate: annotationsArray[index].coordinate, destinationCoordinate: annotationsArray[index + 1].coordinate)
        }
        
        mapView.showAnnotations(annotationsArray, animated: true)
        
    }
    
    @objc func resetButtonTapped(){
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }
    
    private func setupPlacemark(addressPlace : String){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressPlace) { [self] (placemarks, error) in
            
            if let error = error{
                print(error)
                alertError(title: "Error", message: "Server is not available, try to add address one more time")
                return
            }
            
            guard let placemarks = placemarks else {
                return
            }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            
            annotation.title = "\(addressPlace)"
            
            guard let placemarkLocation = placemark?.location else {
                return
            }
            
            annotation.coordinate = placemarkLocation.coordinate
            
            annotationsArray.append(annotation)
            if(annotationsArray.count > 2){
                routeButton.isHidden = false
                resetButton.isHidden = false
            }
            
            mapView.showAnnotations(annotationsArray, animated: true)
        }
    }
    
    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D){
        
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else{
                self.alertError(title: "Error", message: "Route is unavailable")
                return
            }
            
            print("found \(response.routes.count) routes")
            
            var minRoute = response.routes[0]
            
            if(response.routes.count > 0){
                var counter = 0
                for route in response.routes{
                    print("rounte \(counter) distance is \(route.distance)")
                    minRoute = route.distance < minRoute.distance ? route : minRoute
                    counter += 1
                }
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
        
    }

}

extension ViewController : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        return renderer
    }
    
}

extension ViewController {
    
    func setConstraints(){
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        mapView.addSubview(addAddressButton)
        NSLayoutConstraint.activate([
            addAddressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAddressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            addAddressButton.heightAnchor.constraint(equalToConstant: 55),
            addAddressButton.widthAnchor.constraint(equalToConstant: 140)
        ])
        
        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            routeButton.heightAnchor.constraint(equalToConstant: 55),
            routeButton.widthAnchor.constraint(equalToConstant: 140)
        ])

        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            resetButton.heightAnchor.constraint(equalToConstant: 55),
            resetButton.widthAnchor.constraint(equalToConstant: 140)
        ])
    }
    
}



