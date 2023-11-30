import Foundation
import AMapSearchKit
import AMapFoundationKit
import AMapLocationKit
import AMapNaviKit
import WLYUIKitBase
import MapKit


class Target_MapLibrary: NSObject {

    let keyParam = "keyParam"
    /// 开始定位
    @objc func Action_beiginLocation(_ params:NSDictionary) {
        PumkinLocation.share().beiginLocation()
    }
}
/// 地图模块对外接口
public struct MapLibraryOutter {
    
    /// 启动高德内部导航
    public static func startNaviAction(start: (name:String, lat: CGFloat, lng: CGFloat), end: (name:String, lat: CGFloat, lng: CGFloat)) {
        
        var compositeManager = AMapNaviCompositeManager.init()
        let config = AMapNaviCompositeUserConfig.init()
        config.setRoutePlanPOIType(.start, location: AMapNaviPoint.location(withLatitude: start.lat, longitude: start.lng), name: start.name, poiId: nil)
        config.setRoutePlanPOIType(.end, location: AMapNaviPoint.location(withLatitude: end.lat, longitude: end.lng), name: end.name, poiId: nil)  //传入终点
        config.setStartNaviDirectly(true) //直接进入导航界面
        compositeManager.presentRoutePlanViewController(withOptions: config)
    }
    
    /// 跳到地图界面 进行步行导航 type : 0 :苹果 1 是 高德 2 是百度3 是 qq 地图
    public static func driverNavigation(type: NSInteger, st: String , des: String) {
        
        do{
            let s = try pumpkinDecoder(jsonstr: st, modelType: GPSPoint.self)
            let e = try pumpkinDecoder(jsonstr: des, modelType: GPSPoint.self)
            
            MapTools.goMapAction(type: type, st: s, des: e, option: .driving)
            
        }catch {
            GConfig.log("跳转地图的时候 起点或者终点解析错误")
            GConfig.log("起点: \(st)")
            GConfig.log("z终点: \(des)")
        }
    }
    
    public static func getTwoPointDistance(startPoint:(lat:String,lng:String),endPoint:(lat:String,lng:String)) -> NSInteger {
        
        guard let lat1 = Double(startPoint.lat),
              let lng1 = Double(startPoint.lng),
              let lat2 = Double(endPoint.lat),
              let lng2 = Double(endPoint.lng) else { return 0 }
        
        let startCoor = CLLocationCoordinate2DMake(lat1, lng1)
        let endCoor = CLLocationCoordinate2DMake(lat2, lng2)
        let distance = MAMetersBetweenMapPoints(MAMapPointForCoordinate(startCoor), MAMapPointForCoordinate(endCoor))
        return NSInteger(distance)
    }
}

func wly_image(named:String) -> UIImage? {
    return UIImage(named: named, in: .main, compatibleWith: nil)
}


class MapTools {
//    public static func getPointPage(type:SelectPointOption,callbackPoint:((_ gps: GPSPoint)->Void)? = nil) -> UINavigationController {
//        return UINavigationController(rootViewController: XASelectPointViewController(type: type, callBackPoint: callbackPoint))
//
//    }
    
//    public static func getPointMapPage(type:SelectPointOption,areactrs: [(bordelColor: String, points:[CLLocationCoordinate2D])] = [],callbackPoint:((_ gps: GPSPoint)->Void)? = nil) -> UINavigationController {
//        return UINavigationController(rootViewController: XASelectPointMapViewController(pageType: type, areactrs: areactrs,callBack: callbackPoint))
//
//    }
    
    /// 打开地图步行导航
    static func openMap(desPoint: GPSPoint, option: NavigationType) {

//        var mapArray: [String] = ["苹果地图"]
//        if UIApplication.shared.canOpenURL(URL(string: "iosamap://")!) {
//            mapArray.append("高德地图")
//        }
//        if UIApplication.shared.canOpenURL(URL(string: "baidumap://")!){
//            mapArray.append("百度地图")
//        }
//
//        /// 打开地图
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//        for (index, item) in mapArray.enumerated() {
//            alert.addAction(UIAlertAction(title: item, style: .default, handler: {(aleraction) in
//                goMapAction(type: index, des: desPoint, option: option)
//            }))
//        }
//        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
//        UIApplication.k_keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    /// 跳到地图界面 进行步行导航 type : 0 :苹果 1 是 高德 2 是百度3 是 qq 地图
    static func goMapAction(type: NSInteger, st: GPSPoint , des: GPSPoint, option: NavigationType) {

        let lat = st.latitude
        let lng = st.longitude
        let endlat = des.latitude
        let endLng = des.longitude

        var iosMap = MKLaunchOptionsDirectionsModeTransit
        var aMap = "1"
        var baiduMap = "transit"
        var qqMap = "bus"

        switch option {
        case .driving:
            iosMap = MKLaunchOptionsDirectionsModeDriving
            aMap = "0"
            baiduMap = "driving"
            qqMap = "drive"
        case .walking:
            iosMap = MKLaunchOptionsDirectionsModeWalking
            aMap = "2"
            baiduMap = "walking"
            qqMap = "walk"
        default:
            break
        }

        switch type {
        case 0:
            let currentLocation:MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng), addressDictionary: nil))

            let toLocation:MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: endlat, longitude: endLng), addressDictionary: nil))
            MKMapItem.openMaps(with: [currentLocation,toLocation], launchOptions: [MKLaunchOptionsDirectionsModeKey:iosMap])
        case 1:
            if let iosmapUrl = URL(string: "iosamap://path?sourceApplication=cdpt&sid=&slat=\(lat)&slon=\(lng)&sname=A&did=&dlat=\(endlat)&dlon=\(endLng)&dname=B&dev=0&t=0") {
                UIApplication.shared.open(iosmapUrl, options: [:], completionHandler: nil)
            }
            
        case 2:
            if let url = URL(string: "baidumap://map/direction?origin=\(lat),\(lng)&destination=\(endlat),\(endLng)&mode=\(baiduMap)&coord_type=gcj02") {
                UIApplication.shared.open(url)
            }
        case 3:
            //
//            let urlStr = "qqmap://map/routeplan?type=\(qqMap)&fromcoord=\(lat),\(lng)&tocoord=\(endlat),\(endLng)&policy=1"
//            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
            break
        default:
            break
        }
    }
    
}

//MARK: - 0  默认 公交    1  驾车    2 步行
public enum NavigationType {
    case bus, driving, walking
}



/**
 
 高德
 
 t = 0 驾车；

 t = 1 公交；

 t = 2 步行；

 t = 3 骑行（骑行仅在V788以上版本支持）；
 
 百度
 
 导航模式，固定为transit、driving、navigation、walking，riding分别表示公交、驾车、导航、步行和骑行
 
 腾讯
 
 公交：bus
 驾车：drive
 步行：walk
 骑行：bike
 
 
 */
