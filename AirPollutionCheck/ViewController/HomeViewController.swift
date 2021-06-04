//
//  ViewController.swift
//  AirPollutionCheck
//
//  Created by 장주명 on 2021/05/28.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import Then

class HomeViewController: UIViewController {
    
    struct userLocation {
        var latitude: Double!
        var longitude: Double!
    }
    
    lazy var locationManager = CLLocationManager().then {
        $0.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        $0.distanceFilter = kCLHeadingFilterNone
        $0.requestWhenInUseAuthorization()
    }
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dataTimeLabel: UILabel!
    @IBOutlet weak var PMLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var PMGradeImage: UIImageView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let coord = locationManager.location?.coordinate
        LocationInfo.shared.latitude = coord?.latitude
        LocationInfo.shared.longitude = coord?.longitude
        
        getLocation(url: NAVER_API.NAVER_REVERSGEOCODE_URL, longitude: coord!.longitude, latitude: coord!.latitude) { location in
            DispatchQueue.main.async {
                self.locationLabel.text = location
            }
        }
        

        TM(url: KAKAO_API.KAKAO_TRANSCOORD_URL, longitude: coord!.longitude, latitude: coord!.latitude) { userLocation in
            self.getNearbyMsrstn(url: AIR_POLLUTION_STATION_API.AIR_POLLUTION_STATION_URL, tmX: userLocation.longitude, tmY: userLocation.latitude ) { station in
                DispatchQueue.main.async {
                    self.stationLabel.text = "측정 장소 : \(station)"
                }
                self.getfinedust(url: AIR_POLLUTION_API.AIR_POLLUTION_URL, stationName: station) { pm,pmGrade,time in
                    DispatchQueue.main.async {
                        switch pmGrade {
                        case "1" :
                            self.PMGradeImage.image = UIImage(named: "smile.png")
                        case "2" :
                            self.PMGradeImage.image = UIImage(named: "normal.png")
                        case "3" :
                            self.PMGradeImage.image = UIImage(named: "bad.png")
                        case "4" :
                            self.PMGradeImage.image = UIImage(named: "evil.png")
                        default :
                            print("Unkown")
                        }
                        self.dataTimeLabel.text = "측정 시간 : \(time)"
                        self.PMLabel.text = "\(pm)㎍/㎥"
                    }
                }
            }
        }
        
    }
    
    func getLocation(url: String, longitude: Double, latitude: Double, handler: @escaping(String) -> Void) {
            let header1 = HTTPHeader(name: "X-NCP-APIGW-API-KEY-ID", value: NAVER_API.NAVER_CLIENT_ID)
            let header2 = HTTPHeader(name: "X-NCP-APIGW-API-KEY", value: NAVER_API.NAVER_CLIENT_SECRET)
            let headers = HTTPHeaders([header1,header2])
            let parameters : Parameters = [
                "coords" : "\(longitude),\(latitude)",
                "output" : "json"
            ]
            
            let alamo = AF.request(url,method: .get,parameters: parameters,headers: headers)
            alamo.validate().responseJSON { response in
        //                debugPrint(response)
                switch response.result {
                case .success(let value) :
                    let json = JSON(value)
                    let data = json["results"]
                    let address = data[0]["region"]["area2"]["name"].string!
                    LocationInfo.shared.nowLocationName = address
                    handler(address)
                case .failure(_):
                    let alert = UIAlertController(title: nil, message: "네트워크를 다시 확인해주세요", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                
                    }
            }
    }
    
    func TM(url: String, longitude: Double, latitude: Double, handler: @escaping(userLocation) -> Void) {
        
            var result = userLocation()
        
            let headers:HTTPHeaders = ["Authorization" : KAKAO_API.KAKAO_KEY]
            let parameters: Parameters = [
                "x" : longitude,
                "y" : latitude,
                "output_coord" : "TM"
            ]
            let alamo = AF.request(url, method: .get,parameters: parameters, encoding: URLEncoding.queryString ,headers: headers)
            alamo.responseJSON() { response in
                debugPrint(response)
               switch response.result {
               case .success(let value):
                   let json = JSON(value)
                   let documents = json["documents"].arrayValue
                   result.longitude = documents[0]["x"].double
                   result.latitude = documents[0]["y"].double
                   handler(result)
               case .failure(_):
                   let alert = UIAlertController(title: nil, message: "네트워크를 다시 확인해주세요", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                   self.present(alert, animated: true, completion: nil)
                   return
               }
           }
       }
    
    func getNearbyMsrstn(url: String, tmX: Double, tmY: Double, handler: @escaping(String) -> Void) {
            let parameters: Parameters = [
                "serviceKey" : AIR_POLLUTION_STATION_API.AIR_POLLUTION_STATION_KEY,
                "tmX" : tmX,
                "tmY" : tmY,
                "returnType" : "json"
            ]
            
            let alamo = AF.request(url, method: .get,parameters: parameters, encoding: URLEncoding.default)
            alamo.responseJSON() { response in
                debugPrint(response)
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let stationName = json["response"]["body"]["items"][0]["stationName"].string!
                    LocationInfo.shared.stationName = stationName
                    handler(stationName)
                case .failure(_):
                    let alert = UIAlertController(title: nil, message: "네트워크를 다시 확인해주세요", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
        }
        
    
    func getfinedust(url: String, stationName: String, handler: @escaping(String, String, String) -> Void) {
         let parameters: Parameters = [
            "serviceKey" : AIR_POLLUTION_API.AIR_POLLUTION_KEY,
            "stationName" : stationName,
            "dataTerm" : "DAILY",
            "returnType" : "json"
         ]
         
         let alamo = AF.request(url, method: .get,parameters: parameters, encoding: URLEncoding.default)
         alamo.responseJSON() { response in
             switch response.result {
             case .success(let value):
                 let json = JSON(value)
                 let pm10Value = json["response"]["body"]["items"][0]["pm10Value"].string!
                 let pm10GradeValue = json["response"]["body"]["items"][0]["pm10Grade"].string!
                 let dataTime = json["response"]["body"]["items"][0]["dataTime"].string!
                
                 LocationInfo.shared.pmGradeValue = pm10GradeValue
                 LocationInfo.shared.dataTime = dataTime
                 LocationInfo.shared.pmValue = pm10Value
                 handler(pm10Value,pm10GradeValue, dataTime)
             case .failure(_):
                 let alert = UIAlertController(title: nil, message: "네트워크를 다시 확인해주세요", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                 self.present(alert, animated: true, completion: nil)
                 return
             }
         }
     }
    
//
    


}

