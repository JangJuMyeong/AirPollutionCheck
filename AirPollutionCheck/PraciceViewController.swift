//
//  PraciceViewController.swift
//  AirPollutionCheck
//
//  Created by 장주명 on 2021/05/28.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class PraciceViewController: UIViewController, CLLocationManagerDelegate {
    
    var x : Double = 0
    var y : Double = 0
    let finAddress = ""
    var station = ""
    let encodeAddress = API.홍대입구역.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tmLocation: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
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
        
        label.text = "Lat : \(loaction.coordinate.latitude) "
        label2.text = "Lng: \(loaction.coordinate.longitude)"
        
        makeLoaction()
        makeTMPoint()
        makeStation()
        makeAirPollution()
        
        
        
        
        func makeTMPoint() {
            let tmHeader = HTTPHeader(name: "Authorization", value:"KakaoAK 9ae0251fb810e925feb20d449658abc0")
            let tmheaders = HTTPHeaders([tmHeader])
            
            AF.request("https://dapi.kakao.com/v2/local/geo/transcoord.json?x=\(loaction.coordinate.longitude)&y=\(loaction.coordinate.latitude)&input_coord=WGS84&output_coord=TM",method: .get,headers: tmheaders).validate().responseJSON { response in
                switch response.result{
                case .success(let value as [String:Any]) :
                    let json = JSON(value)
                    let data = json["documents"]
                    let tmLocationX = data[0]["x"].double
                    let tmLocationY = data[0]["y"].double
                    if let xPoint = tmLocationX, let yPoint = tmLocationY {
                        self.x = xPoint
                        self.y = yPoint
                        self.tmLocation.text = "\(xPoint),\(yPoint)"
                    }
                case .failure(let error):
                    print(error.errorDescription ?? "")
                default :
                    fatalError()
                }
                
                
    //            debugPrint(response)
            }
        }
        
       
        
        
        func makeLoaction() {
            let header1 = HTTPHeader(name: "X-NCP-APIGW-API-KEY-ID", value: API.NAVER_CLIENT_ID)
            let header2 = HTTPHeader(name: "X-NCP-APIGW-API-KEY", value: API.NAVER_CLIENT_SECRET)
            let headers = HTTPHeaders([header1,header2])
            

                AF.request("https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=\(loaction.coordinate.longitude),\(loaction.coordinate.latitude)&output=json",method: .get,headers: headers).validate().responseJSON { response in
    //                debugPrint(response)
                    switch response.result {
                    case .success(let value as [String:Any]) :
                        let json = JSON(value)
                        let data = json["results"]
                        let address2 = data[0]["region"]["area2"]["name"]
                        self.locationLabel.text = "위치는 \(address2)"
                        print("위치는 \(address2)")
                        
                    case .failure(let error):
                        print(error.errorDescription ?? "")
                    default :
                        fatalError()
                    }
                }
        }
        
        
        
        
        func makeStation() {
            let stationParm : Parameters =  [
                "serviceKey" : "tCUBcpiddCWQrSAOOhbScnr97iDYA+Eogo/YLeey66UUq2y2FM8lzCqk8RgJL0xmW/VL+y/LTqsygjeZxRj2Vw==",
                "tmX" : x,
                "tmY" : y,
                "returnType" : "json"
            ]
            
            AF.request("http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList?",method: .get,parameters: stationParm).validate().responseJSON { response in
    //            debugPrint(response)
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let stationName = json["response"]["body"]["items"][0]["stationName"].string!
                    self.station = stationName
                    print(stationName)
                    
                case .failure(let error):
                    print(error.errorDescription ?? "")
                }
                
            }
        }
        
        func makeAirPollution() {
            let airPollutionParm : Parameters = [
                "serviceKey" : "tCUBcpiddCWQrSAOOhbScnr97iDYA+Eogo/YLeey66UUq2y2FM8lzCqk8RgJL0xmW/VL+y/LTqsygjeZxRj2Vw==",
                "stationName" : self.station,
                "dataTerm" : "DAILY",
                "returnType" : "json"
            ]
            
            
            AF.request("http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty",method: .get,parameters: airPollutionParm).validate().responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let pm10Value = json["response"]["body"]["items"][0]["pm10Grade"].string
                    let dataTime = json["response"]["body"]["items"][0]["dataTime"].string
                    
                    print("\(pm10Value),\(dataTime)")
                    if let airPollution = pm10Value, let time = dataTime {
                        print("\(airPollution),\(time)")
                                            self.dataLabel.text = airPollution
                                            self.timeLabel.text = time
                    }
                    

                    
                case .failure(let error):
                    print(error.errorDescription ?? "")
                }
                
            }
        }
        

    }



}
