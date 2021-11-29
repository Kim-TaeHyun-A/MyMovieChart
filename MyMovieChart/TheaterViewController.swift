//
//  TheaterViewController.swift
//  MyMovieChart
//
//  Created by 김태현 on 2021/11/22.
//

import UIKit
import MapKit

class TheaterViewController: UIViewController {
    @IBOutlet var map:MKMapView!
    var param: NSDictionary!
    
    override func viewDidLoad() {
        self.navigationItem.title = self.param["상영관명"] as? String
        
        let lat = (param?["위도"] as! NSString).doubleValue
        let lng = (param?["경도"] as! NSString).doubleValue
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let regionRadius: CLLocationDistance = 100 // 단위: m, 크면 넓은 범위 표시
        let coordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        
        self.map.setRegion(coordinateRegion, animated: true)
        
        // 핀으로 위치 표시
        let point = MKPointAnnotation()
        
        point.coordinate = location
        self.map.addAnnotation(point)
    }
}
