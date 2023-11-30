//
//  PumkinLocation.swift
//  XAOfficialBus
//
//  Created by zhonghangxun on 2018/12/4.
//  Copyright © 2018 zhonghangxun. All rights reserved.
//

import Foundation
import AMapLocationKit
import AMapSearchKit
import AMapNaviKit
import WLYUIKitBase

public class PumkinLocation:NSObject {
    
    private static let shareIntence = PumkinLocation()
    
    private var locationManager: AMapLocationManager!
    
    public class func share() -> PumkinLocation {
        return shareIntence
    }
    
    override private init() {
        // 隐私需要
        MAMapView.updatePrivacyAgree(.didAgree)
        MAMapView.updatePrivacyShow(.didShow, privacyInfo: .didContain)
        AMapSearchAPI.updatePrivacyAgree(.didAgree)
        AMapSearchAPI.updatePrivacyShow(.didShow, privacyInfo: .didContain)
        AMapLocationManager.updatePrivacyAgree(.didAgree)
        AMapLocationManager.updatePrivacyShow(.didShow, privacyInfo: .didContain)
        
        locationManager = AMapLocationManager()
        super.init()
        locationManager.locatingWithReGeocode = true
        locationManager.distanceFilter = 50
//        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
    }
    
    public func beiginLocation() {
        locationManager.startUpdatingLocation()
    }
    
    public func endLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    private let newLocation = NSNotification.Name("NotificationRawkey.newLocation.rawValue")
    
    private func storageMyPoint(poi: AMapLocationReGeocode?, location:CLLocation?) {
        
        var myLocation = GPSPoint()
        if let loca = location {
            if let p = poi {
                myLocation.name = p.aoiName ?? ""
                myLocation.cityCode = p.citycode ?? ""
                myLocation.address = p.formattedAddress ?? ""
                myLocation.city = p.city ?? ""
                myLocation.amapCode = p.adcode ?? "0"
                myLocation.district = p.district ?? "''"
            }
            myLocation.latitude = loca.coordinate.latitude
            myLocation.longitude = loca.coordinate.longitude
            let myLocationStr = pumpkinEncoder(model: myLocation)
            GConfig.log("当前定位结果🌎🌎🌎🌎 \(myLocationStr)")
            UserDefaults.setMyLocation(location: myLocationStr)
            NotificationCenter.default.post(name: newLocation, object: self, userInfo: ["post":"Newlocation"])
        }
    }
}

extension PumkinLocation: AMapLocationManagerDelegate {
    /**
     *  @brief 当定位发生错误时，会调用代理的此方法。
     *  @param manager 定位 AMapLocationManager 类。
     *  @param error 返回的错误，参考 CLError 。
     */
    public func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        
        storageMyPoint(poi: nil, location: nil)
        if CLLocationManager.authorizationStatus() == .denied {
            //定位不能用
            let alert = UIAlertController(title: "提醒", message: "为了更好的体验,请到设置开启定位服务,已便获取附近信息!", preferredStyle:.alert)
            let alertAction = UIAlertAction(title: "好的", style: .default) { (alert) in
                let url = URL(string: UIApplication.openSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                }
            }
            let alertAction2 = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(alertAction)
            alert.addAction(alertAction2)
            UIApplication.k_keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    public func amapLocationManager(_ manager: AMapLocationManager!, doRequireLocationAuth locationManager: CLLocationManager!) {
        locationManager.requestWhenInUseAuthorization()
    }
    /**
     *  @brief 连续定位回调函数.注意：如果实现了本方法，则定位信息不会通过amapLocationManager:didUpdateLocation:方法回调。
     *  @param manager 定位 AMapLocationManager 类。
     *  @param location 定位结果。
     *  @param reGeocode 逆地理信息。
     */
    public func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode!) {
        storageMyPoint(poi: reGeocode, location: location)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
