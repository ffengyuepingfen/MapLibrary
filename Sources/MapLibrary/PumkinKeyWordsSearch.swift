//
//  PumkinKeyWordsSearch.swift
//  XAOfficialBus
//
//  Created by zhonghangxun on 2018/12/4.
//  Copyright © 2018 zhonghangxun. All rights reserved.
//

import Foundation
import AMapSearchKit

/*
 根据关键字搜索poi 结果
 */
public class PumkinKeyWordsSearch: NSObject {
    
    private var searcher:AMapSearchAPI!
    
    private var callBlock:(([GPSPoint])->())?
    
    private var cityName:String
    
    private var offset = 10
    
    public init(cityName:String,offset:NSInteger = 10) {
        
        self.cityName = cityName
        self.offset = offset
        searcher = AMapSearchAPI()
        super.init()
    }
    
    func begainPoiSearch(keyword:String,callBlock:@escaping (([GPSPoint])->())) {
        self.callBlock = callBlock
        if searcher == nil {
            searcher = AMapSearchAPI()
        }
        searcher.delegate = self
        let request = AMapPOIKeywordsSearchRequest()
        request.keywords = keyword
        request.city = cityName
        request.types = "通行设施|公共设施|地名地址信息|道路附属设施|公司企业|交通设施服务|科教文化服务|政府机构及社会团体|商务住宅|风景名胜|住宿服务|生活服务|购物服务|体育休闲服务|医疗保健服务|餐饮服务|金融保险服务|摩托车服务|汽车维修|汽车服务|汽车销售"
        request.offset = offset
        request.cityLimit        = true
        searcher.aMapPOIKeywordsSearch(request)
    }
    
}

extension PumkinKeyWordsSearch :AMapSearchDelegate{
    public func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if searcher != nil {
            searcher.delegate = nil
            searcher = nil
        }
        
//        let config = ConfigManager.share()
//        let mypoint:GPSPoint = GPSPoint(lat: config.getCityDefaultPoint().lat, lng: config.getCityDefaultPoint().lng)
//
//        if let pois:[AMapPOI] = response.pois, !pois.isEmpty {
//            var result:[GPSPoint] = []
//            //// 检索到的数据回调
//            for item in pois {
//                let distance = getTwoPointDistance(startPoint: (lat: mypoint.latitude, lng: mypoint.longitude), endPoint: (lat: "\(item.location.latitude)", lng: "\(item.location.longitude)"))
//                // 排除距离中心点15KM范围以外的
//                if distance >= 15000 {
//                    continue
//                }
//                var p = GPSPoint()
//                p.uid = item.uid
//                p.name = item.name
//                p.address = item.address
//                p.latitude = "\(item.location.latitude)"
//                p.longitude = "\(item.location.longitude)"
//                p.city = item.city
//                p.adcode = item.adcode
//                result.append(p)
//            }
//            if let callBlock = callBlock {
//                callBlock(result)
//            }
//        }
    }
    
    public func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        if searcher != nil {
            searcher.delegate = nil
            searcher = nil
        }
    }
}


public class JJJReGeocodeSearch: NSObject {
    
    private static let shareIntence = JJJReGeocodeSearch()
    
    /// 反地理查询
    private var search: AMapSearchAPI!
    
    public class func share() -> JJJReGeocodeSearch {
        return shareIntence
    }
    
    override private init() {
        super.init()
        search = AMapSearchAPI()
        search.delegate = self
    }
    
    private var call: ((_ gps: GPSPoint) -> Void)?
    
    /// 发起反地理查询
    func begainGeoCodeSearch(location: CLLocationCoordinate2D, callBack: @escaping (_ gps: GPSPoint) -> Void) {
        self.call = callBack
        let request = AMapReGeocodeSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(location.latitude), longitude: CGFloat(location.longitude))
        request.requireExtension = true
        search.aMapReGoecodeSearch(request)
    }
    
}

// MARK: - 反地理查询代理
extension JJJReGeocodeSearch: AMapSearchDelegate {
    public func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        
//        var gpsPoint = GPSPoint()
//        // 请求反查的原始经纬度
//        if let location = request.location {
//            gpsPoint.latitude = "\(location.latitude)"
//            gpsPoint.longitude = "\(location.longitude)"
//        }
//        // 反查的附近poi点
//        if let poiInfo = response.regeocode.pois.first {
//            gpsPoint.uid = poiInfo.uid
//            gpsPoint.name = poiInfo.name
//            gpsPoint.address = poiInfo.address
//            gpsPoint.city = poiInfo.city
//            gpsPoint.adcode = poiInfo.adcode
//        }
//        // 当前位置地理反差信息
//        if let pp = response.regeocode.addressComponent {
//            gpsPoint.adcode = pp.adcode
//            gpsPoint.city = pp.city.replacingOccurrences(of: "市", with: "")
//            if let address = response.regeocode.formattedAddress, address != "" {
//                gpsPoint.address = address.replacingOccurrences(of: "陕西省", with: "")
//            }
//        }
//
//        if let call = call {
//            call(gpsPoint)
//        }
    }
    
    public func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        if let call = call {
//            call(GPSPoint(gpsName: "上车地点获取失败", lat: "0", lng: "0"))
        }
    }
}
