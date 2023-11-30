//
//  File.swift
//  
//
//  Created by Laowang on 2023/6/29.
//

import Foundation

struct GPSPoint:Codable {

    var uid: String
    var name: String
    var address: String
    var city: String
    var latitude: Double
    var longitude: Double
    var amapCode: String
    var cityCode: String
    /// 行政区
    var district: String

    init(uid: String, name: String, address: String, city: String, latitude: Double, longitude: Double, amapCode: String, cityCode: String, district: String) {
        self.uid = uid
        self.name = name
        self.address = address
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.amapCode = amapCode
        self.cityCode = cityCode
        self.district = district
    }
    
    init() {
        self.uid = ""
        self.name = ""
        self.address = ""
        self.city = ""
        self.latitude = 0.0
        self.longitude = 0.0
        self.amapCode = ""
        self.cityCode = ""
        self.district = ""
    }
    
}
/// 我的位置的key
let UserDefaultsKeysOption_myLocation = "UserDefaultsKeysOption.myLocation.rawValue"

extension UserDefaults {
    /// 存储当前位置
    static func setMyLocation(location:String?) {
        UserDefaults.standard.setValue(location, forKey: UserDefaultsKeysOption_myLocation)
        UserDefaults.standard.synchronize()
    }
}

/// 线路 规划 方案的 起始点
struct SearchPlan:Codable {
    public var startPoint:GPSPoint
    public var endPoint:GPSPoint
    
    public init(start:GPSPoint,end:GPSPoint) {
        startPoint = start
        endPoint = end
    }
}
