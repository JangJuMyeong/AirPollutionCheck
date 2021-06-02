//
//  PraciceViewController.swift
//  AirPollutionCheck
//
//  Created by 장주명 on 2021/05/28.
//

import UIKit
import CoreLocation

class PraciceViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var label: UILabel!

    private var loactionManger : CLLocationManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "reday!"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loactionManger = CLLocationManager()
        loactionManger?.requestAlwaysAuthorization()
        loactionManger?.startUpdatingLocation()
        loactionManger?.delegate = self
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let loaction = locations.last else {
            return
        }
        
        label.text = "Lat : \(loaction.coordinate.latitude) /nLng: \(loaction.coordinate.longitude)"
        
        
        
    }

    

}
