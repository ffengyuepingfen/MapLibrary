//
//  XASelectPointMapViewController.swift
//  XAOfficialBus
//
//  Created by zhonghangxun on 2018/12/4.
//  Copyright © 2018 zhonghangxun. All rights reserved.
//

import UIKit
import AMapNaviKit
import AMapSearchKit


//class XASelectPointMapViewController: UIViewController {
//
//    @IBOutlet weak var resultString: UILabel!
//
//    @IBOutlet weak var mapView: UIView!
//
//    @IBOutlet weak var imageViewCenter: UIImageView!
//
//    var selectPoint:GPSPoint? = nil
//    var map:MAMapView!
//
//    var pageType:SelectPointOption!
//
//    private var callBackGPSPoint:((_ gps: GPSPoint)->Void)?
//
//    init() {
//        super.init(nibName: "XASelectPointMapViewController", bundle: ResourceBundle)
//    }
//
//    var areactrs: [(bordelColor: String, points:[CLLocationCoordinate2D])] = []
//
//    init(pageType:SelectPointOption = .fetchPoint,areactrs: [(bordelColor: String, points:[CLLocationCoordinate2D])] = [],callBack:((GPSPoint)->Void)? = nil) {
//        super.init(nibName: "XASelectPointMapViewController", bundle: ResourceBundle)
//        self.callBackGPSPoint = callBack
//        self.pageType = pageType
//        self.areactrs = areactrs
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    /// 记录自己当前的位置;
//    var myposition:CLLocationCoordinate2D? = nil
//    var polylines: [MAPolygon] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor.backGroundColor()
//        map = MAMapView(frame: mapView.bounds)
//        map.showsUserLocation = true
//        map.userTrackingMode = .follow
//        map.isRotateEnabled = false
//        map.zoomLevel = 16.0
//        map.delegate = self
//        mapView.addSubview(map)
//
//        imageViewCenter.image = wly_image(named: "mapCenter")?.withRenderingMode(.alwaysTemplate)
//        imageViewCenter.tintColor = UIColor.themeColor()
//        mapView.bringSubviewToFront(imageViewCenter)
//
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: wly_image(named: "refresh"), style: .plain, target: self , action: #selector(myPosition))
//        myPosition()
//
//        for (index, item) in areactrs.enumerated() {
//            var ps = item.points
//            let polygon: MAPolygon = MAPolygon(coordinates: &ps, count: UInt(ps.count))
//            polygon.title = "\(index)"
//            map.add(polygon)
//            polylines.append(polygon)
//        }
//
//        map.showOverlays(polylines, animated: true)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: wly_image(named: "leftArrow"), style: .done, target: self, action: #selector(doneAction))
//    }
//
//    @objc private func doneAction() {
//        if pageType == SelectPointOption.fetchHomeOrCompany {
//            self.navigationController?.popToRootViewController(animated: true)
//        }else{
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        map.delegate = self
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        map.delegate = nil
//    }
//
//    @objc private func myPosition() {
//        /// 设置当前的位置
//        let config = ConfigManager.share()
//        var mypoint:GPSPoint = GPSPoint(lat: config.getCityDefaultPoint().lat, lng: config.getCityDefaultPoint().lng)
//        if let point = UserDefaults.getMyLocation() {
//            if point.amapCode == config.getRealCityCode() {
//                mypoint = point
//            }
//        }
//        let mapCenter = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(mypoint.latitude)!), longitude: CLLocationDegrees(Double(mypoint.longitude)!))
//        map.setCenter(mapCenter, animated: true)
//    }
//
//    private func goWherePage(point:GPSPoint) {
//        if pageType == .fetchPoint {
//            if let callBackGPSPoint = callBackGPSPoint {
//                callBackGPSPoint(point)
//            }
//            //            self.dismiss(animated: true, completion: nil)
//        }else{
//            let str = pumpkinEncoder(model: point)
//            switch pageType {
//            case .startPoint:
//                UserDefaults.setFirstPoint(point: str)
//                break
//            case .endPoint:
//                UserDefaults.setSecondPoint(point: str)
//                break
//            default:
//                break
//            }
//            if let callBackGPSPoint = callBackGPSPoint {
//                callBackGPSPoint(point)
//            }
//            //            self.dismiss(animated: true, completion: nil)
//        }
//        doneAction()
//    }
//
//    @IBAction func submitAction(_ sender: UIButton) {
//
//        if let point = self.selectPoint {
//            UserDefaults.setPointCache(point: point)
//            // 是否需要进行范围判断
//            if !areactrs.isEmpty, let lat = Double(point.latitude), let lng = Double(point.longitude) {
//                let pointCache = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lng))
//                let flag = judgePointInRect(point: pointCache)
//                if !flag {
//                    self.view.showMessage("当前点不在可选范围内")
//                    return
//                }
//            }
//            goWherePage(point: point)
//        }else {
//            self.view.showMessage("站点查询失败")
//        }
//    }
//    /// 发起反地理查询
//    private func getGeoCodeSearch() {
//
//        JJJReGeocodeSearch.share().begainGeoCodeSearch(location: map.centerCoordinate) {[weak self] gps in
//            self?.selectPoint = gps
//            self?.resultString.text = "\(gps.name ?? "\\")→\(gps.address ?? "\\")"
//        }
//    }
//    /// 判断一个点有木有在确定的范围内
//    private func judgePointInRect(point: CLLocationCoordinate2D) -> Bool {
//        var flag = false
//        for areac in areactrs {
//            var points = areac.points
//            let ss =  MAPolygonContainsCoordinate(point,&points,UInt(points.count))
//            flag = flag || ss
//        }
//        return flag
//    }
//}

//extension XASelectPointMapViewController: MAMapViewDelegate {
//
//    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
//        locationManager.requestAlwaysAuthorization()
//    }
//
//    func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
//        /// 在地图加载完成的时候记录当前地图中间的位置
//        if myposition == nil {
//            myposition = mapView.centerCoordinate
//            getGeoCodeSearch()
//        }
//    }
//
//    func mapView(_ mapView: MAMapView!, mapWillMoveByUser wasUserAction: Bool) {
//        resultString.text = "正在查询..."
//    }
//
//    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
//        getGeoCodeSearch()
//    }
//
//    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
//        if overlay.isKind(of: MAPolygon.self) {
//            if overlay.title == "0" {
//                let renderer: MAPolygonRenderer = MAPolygonRenderer(overlay: overlay)
//                renderer.lineWidth = 4.0
//                renderer.fillColor = UIColor(displayP3Red: 128.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 100/255.0)
//                renderer.strokeColor = UIColor(displayP3Red: 50.0/255.0, green: 1.0/255.0, blue: 1.0/255.0, alpha: 1.0)
//                return renderer
//            }
//            if overlay.title == "1" {
//                let renderer: MAPolygonRenderer = MAPolygonRenderer(overlay: overlay)
//                renderer.lineWidth = 4.0
//                renderer.fillColor = UIColor(displayP3Red: 128.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 100/255.0)
//                renderer.strokeColor = UIColor(displayP3Red: 50.0/255.0, green: 1.0/255.0, blue: 1.0/255.0, alpha: 1.0)
//                return renderer
//            }
//
//        }
//        return nil
//    }
//}

//extension XASelectPointMapViewController: AMapSearchDelegate {
//    public func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
//        if response.regeocode != nil, response.regeocode.pois.count >= 1 {
//
//            let poiInfo = response.regeocode.pois[0]
//            let config = ConfigManager.share()
//            var gpsPoint = GPSPoint(lat: config.getCityDefaultPoint().lat, lng: config.getCityDefaultPoint().lng)
//            gpsPoint.uid = poiInfo.uid
//            gpsPoint.name = poiInfo.name
//            gpsPoint.address = poiInfo.address
//            gpsPoint.latitude = "\(poiInfo.location.latitude)"
//            gpsPoint.longitude = "\(poiInfo.location.longitude)"
//            gpsPoint.city = poiInfo.city
//            gpsPoint.adcode = poiInfo.adcode
//            if let pp = response.regeocode.aois.first {
//                gpsPoint.adcode = pp.adcode
//            }
//            selectPoint = gpsPoint
//            self.resultString.text = "\(poiInfo.name ?? "\\")→\(poiInfo.address ?? "\\")"
//        }
//    }
//
//    public func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
////        TransferLog("地图反差========error:\(String(describing: error))")
//    }
//}

//struct TransferLocationKey {
//
//    static let firstPoint = "TransferFirstPoint"
//
//    static let secondPoint = "TransfersecondPoint"
//
//    static let gpspoint = "Transfer_GpsPoint_Cache"
//
//}

//extension UserDefaults {
//
//    /// 存储换乘的开始点
//    public static func setFirstPoint(point:String) {
//        UserDefaults.standard.setValue(point, forKey: TransferLocationKey.firstPoint)
//        UserDefaults.standard.synchronize()
//    }
//    /// 存储换乘的结束点
//    public static func setSecondPoint(point:String) {
//        UserDefaults.standard.setValue(point, forKey: TransferLocationKey.secondPoint)
//        UserDefaults.standard.synchronize()
//    }
//
//    /// 获取换乘的开始点
//    public static func getFirstPoint() -> String? {
//        return UserDefaults.standard.string(forKey: TransferLocationKey.firstPoint)
//    }
//    /// 获取换乘的结束点
//    public static func getSecondPoint() -> String? {
//        return UserDefaults.standard.string(forKey: TransferLocationKey.secondPoint)
//    }
//
//    /// 获取所有的缓存Gps点
//    static func getpointCache() -> [GPSPoint] {
//        guard let pointsString = UserDefaults.standard.string(forKey: TransferLocationKey.gpspoint) else { return []}
//
//        do {
//            let result = try pumpkinDecoder(jsonstr: pointsString, modelType: [GPSPoint].self)
//            return result
//        } catch {
//            return []
//        }
//    }
//    /// 存储gps点
//    static func setPointCache(point:GPSPoint) {
//        var pointstr = ""
//        do {
//            var result = try pumpkinDecoder(jsonstr: UserDefaults.standard.string(forKey: TransferLocationKey.gpspoint) ?? "", modelType: [GPSPoint].self)
//            if (result.filter{ $0.uid == point.uid}).isEmpty {
//                result.insert(point, at: 0)
//            }
//            pointstr = pumpkinEncoder(model: result)
//        } catch {
//            pointstr = pumpkinEncoder(model: [point])
//        }
//        UserDefaults.standard.setValue(pointstr, forKey: TransferLocationKey.gpspoint)
//        UserDefaults.standard.synchronize()
//    }
//    /// 删除所有缓存的GPS点
//    static func deleteAllCacheGpsPoint() {
//        UserDefaults.standard.setValue(nil, forKey: TransferLocationKey.gpspoint)
//        UserDefaults.standard.synchronize()
//    }
//
//    /// 删除某一条记录
//    static func deletePoint(sid: String) -> Bool {
//        var pointstr = ""
//        do {
//            var result = try pumpkinDecoder(jsonstr: UserDefaults.standard.string(forKey: TransferLocationKey.gpspoint) ?? "", modelType: [GPSPoint].self)
//            result = result.reject { sid == $0.uid }
//            pointstr = pumpkinEncoder(model: result)
//            UserDefaults.standard.setValue(pointstr, forKey: TransferLocationKey.gpspoint)
//            UserDefaults.standard.synchronize()
//            return true
//        } catch {
//            return false
//        }
//    }
//}
