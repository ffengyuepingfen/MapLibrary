//
//  File.swift
//  
//
//  Created by Laowang on 2023/6/29.
//

import UIKit
import AMapNaviKit
import AMapSearchKit
import WLYUIKitBase

// 代理协议
protocol JJMapViewProtocolProxy: AnyObject {
    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!)
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView!
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer!
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool)
    func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool)
    func mapView(_ mapView: MAMapView!, mapWillZoomByUser wasUserAction: Bool)
    
    func mapView(_ mapView: MAMapView!, mapWillMoveByUser wasUserAction: Bool)
    
    func mapView(_ mapView: MAMapView!, didDeselect view: MAAnnotationView!)
}
// 代理类
class JJMapViewProxyClass:NSObject, MAMapViewDelegate {
    
    init(delegate: JJMapViewProtocolProxy) {
        self.delegate = delegate
        super.init()
    }
    
    // delegate就是MyClass对象，注意要使用weak哦
    weak var delegate: JJMapViewProtocolProxy?
    
    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!){
        delegate?.mapViewRequireLocationAuth(locationManager)
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView!{
        return delegate?.mapView(mapView, viewFor: annotation)
    }
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer!{
        return delegate?.mapView(mapView, rendererFor: overlay)
    }
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool){
        delegate?.mapView(mapView, mapDidMoveByUser: wasUserAction)
    }
    
    func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
        delegate?.mapView(mapView, mapDidZoomByUser: wasUserAction)
    }
    
    func mapView(_ mapView: MAMapView!, mapWillZoomByUser wasUserAction: Bool) {
        delegate?.mapView(mapView, mapWillZoomByUser: wasUserAction)
    }
    
    func mapView(_ mapView: MAMapView!, mapWillMoveByUser wasUserAction: Bool){
        delegate?.mapView(mapView, mapWillMoveByUser: wasUserAction)
    }
    
    func mapView(_ mapView: MAMapView!, didDeselect view: MAAnnotationView!) {
        delegate?.mapView(mapView, didDeselect: view)
    }
    
}
/// 地图标注点的数据模型

public struct SpotMapMark {
    public let lat: Double
    public let lng: Double
    public let name: String
    public let id: String
    public let price: String
    public let fast: String
    public let slow: String
    
    public init(lat: Double, lng: Double, name: String, id: String, price: String, fast: String, slow: String) {
        self.lat = lat
        self.lng = lng
        self.name = name
        self.id = id
        self.price = price
        self.fast = fast
        self.slow = slow
    }
}


/// 地图标注的类型
public enum MapMarkOption {
    /// 充电厂
    case ACChargeSpot
}


public enum PloyLineOption: String {
    case normal
}

public protocol JJMapViewProtocol: AnyObject {
    func clickAnno(mapView: JJMapView , id: String)
    func mapDidMove(mapView: JJMapView, point: String)
    func mapwillMove(mapView: JJMapView, point: String)
}

extension JJMapViewProtocol {
    public func clickAnno(mapView: JJMapView , id: String){}
    public func mapDidMove(mapView: JJMapView, point: String){}
    public func mapwillMove(mapView: JJMapView, point: String){}
}

/*
 对map View 进行封装 方便项目内部使用
 */
public class JJMapView: UIView {
    /// 创建一个私有代理人去处理公开协议
    private lazy var proxy = JJMapViewProxyClass(delegate: self)
    
    public weak var delegate: JJMapViewProtocol?
    
    private lazy var uiMapView: MAMapView = {
        
//        var path = ResourceBundle.bundlePath
//        path.append("/style01.data")
//        let data = NSData.init(contentsOfFile: path)
//        let options = MAMapCustomStyleOptions.init()
//        options.styleData = data! as Data
        
        let mm = MAMapView(frame: CGRect.zero)
        mm.delegate = proxy
//        mm.showsUserLocation = true
        mm.userTrackingMode = .follow
        mm.mapType = .standard
//        mm.setCustomMapStyleOptions(options)
//        mm.customMapStyleEnabled = true
        mm.isShowTraffic = true//开启路况
        mm.setZoomLevel(17.5, animated: true)
        mm.isZoomEnabled = true
        mm.isRotateEnabled = false
        mm.isRotateCameraEnabled = false
        return mm
    }()
    
    /// 地图中心点的图标
    lazy var centerImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: GConfig.ScreenW/2 - 20, y: (GConfig.ScreenH - GConfig.NavigationBarH)/2 - 40, width: 40, height: 40))
//        imageView.image = wly_image(named: "mapCenter")?.withRenderingMode(.alwaysTemplate)
//        imageView.tintColor = UIColor.themeColor()
        return imageView
    }()
    
    /// 已经标注到地图上的点 （普通的点、站点、标记等等）
    private var annotations: [CICPointAnnotation] = []

    /// 线条
//    private var polylines: [MAPolyline] = []
    
    /// 当前选中的标记ID
    public var selectAnnoid: String? = nil
    private var selectAnnotation: CICPointAnnotation?
    
    private var search: AMapSearchAPI!
    
    public var isShowCenterLogo = false {
        didSet{
            centerImageView.isHidden = isShowCenterLogo
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        search = AMapSearchAPI()
        search.delegate = self
        self.addSubviewAnchor(subView: uiMapView)
        self.addSubview(centerImageView)
        centerImageView.isHidden = true
    }
    
    public func resetMapCenter(point: CLLocationCoordinate2D, mapShowStatus: NSInteger) {
        uiMapView.setZoomLevel(17.5, animated: true)
        //只有当位置是一半的时候，每次移动完成需要进行一次位置补偿
        //当前转移的坐标需要对 Latitude 进行偏移，获取当前的中心点的坐标
        let currentPoint = point
        var centerLatLng: CLLocationCoordinate2D
        if mapShowStatus == 1 {
            // 1 先获取地图的可显示高度
            let mapHeight = uiMapView.bounds.height
            //补偿高度为可显示区域的 20% 进行补偿
            let offsetHeight: Double = Double(mapHeight * 0.3)
            // 计算当前地图标尺的距离和显示像素之间的实际距离进行换算
            let realDistances: Double = uiMapView.metersPerPointForCurrentZoom * offsetHeight
            //获取实际需要向正南方向偏移的距离以后，进行分度的换算， 1000米 = 0.01 °
            let offsetLat = realDistances / 1000 * 0.01
            centerLatLng = CLLocationCoordinate2D(latitude: currentPoint.latitude - offsetLat, longitude: currentPoint.longitude)
        } else {
            centerLatLng = currentPoint
        }
        //获取这个偏移点的实际坐标
        uiMapView.setCenter(centerLatLng, animated: true)
    }
    /// 获取地图中心点的经纬度
    public func getMapCenterPoint() -> CLLocationCoordinate2D {
        return uiMapView.centerCoordinate
    }
    
    /// 发起反地理查询
    private func getGeoCodeSearch() {
        let request = AMapReGeocodeSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(uiMapView.centerCoordinate.latitude), longitude: CGFloat(uiMapView.centerCoordinate.longitude))
        request.requireExtension = true
        search.aMapReGoecodeSearch(request)
    }
    
    //MARK: - 手动更新选择的标记
    public func updateSelectMark(id: String) {
        self.selectAnnoid = id
//        uiMapView.removeAnnotations(annotations)
        
//        annotations = annotations.map {
//            if $0.cutomer_title == id {
//                $0.type = 0
//            }else{
//                $0.type = 1
//            }
//            return $0
//        }
//        uiMapView.addAnnotations(annotations)
    }
    
    public func setMapDarkModel(isDark: Bool) {
        self.uiMapView.mapType = isDark ? .standardNight : .standard
    }
    
    public func setMapCenter(_ center: CLLocationCoordinate2D) {
        self.uiMapView.setCenter(center, animated: true)
    }
    
    /// 绘制Mark标记到地图上
    /// - Parameters:
    ///   - isclear: 是否需要清理地图上已经存在的标记（某些情况回车牵扯）
    ///   -  showCenter: 是否显示到地图中心
    ///   -  datas: 需要显示的数据
    public func updateAnnotationViewsOnMap(isclear: Bool = false,
                                           showCenter: Bool = false,
                                           edge: UIEdgeInsets = UIEdgeInsets.zero,
                                           datas: [(option: MapMarkOption, data: [SpotMapMark])]) {
        // 如果数据为空 直接返回
        guard !datas.isEmpty else {
            return
        }
        // 清理 已经存在的数据
        if !annotations.isEmpty, isclear {
            uiMapView.removeAnnotations(annotations)
            annotations.removeAll()
        }
        ///  需要放到地图中心的位置的（默认选中的标签）
        var mapCenter: CLLocationCoordinate2D? = nil

        var annos: [CICPointAnnotation] = []
        
        datas.forEach {
            for value in $0.data {
                
                let deCoor = CLLocationCoordinate2DMake(value.lat, value.lng)
                
                let annotation = CICPointAnnotation(data: value, option: $0.option, sourceCoordinate: deCoor)
                annotation.title = value.name
                annotation.subtitle = value.name
                annotation.coordinate = deCoor
                if value.id == self.selectAnnoid {
                    mapCenter = deCoor
                    selectAnnotation = annotation
                }
                annos.append(annotation)
            }
        }
        uiMapView.addAnnotations(annos)
        annotations += annos

        if !showCenter, let mapCenter = mapCenter {
            uiMapView.setCenter(mapCenter, animated: true)
        }else{
            uiMapView.showAnnotations(annotations, edgePadding: edge, animated: true)
        }
    }
    
    /// draw Image AnnotationView
//    public func updateAnnotationViews(showCenter: Bool = false, datas: [(option: AnnotationViewOption,data: [AnnotationData])]) {
//        guard !datas.isEmpty else {
//            return
//        }
//        if !annotations.isEmpty {
//            uiMapView.removeAnnotations(annotations)
//            annotations.removeAll()
//        }
//        var mapCenter: CLLocationCoordinate2D? = nil
//
//        datas.forEach {
//            for value in $0.data {
//                let annotation = XARouteAnnotation()
//                annotation.title = value.name
//                annotation.cutomer_title = value.id
//                annotation.imageUrl = value.imageName
//                let deCoor = CLLocationCoordinate2DMake(value.lat, value.lng)
//                annotation.coordinate = deCoor
//                if value.id == self.selectAnnoid {
//                    annotation.type = 0
//                    mapCenter = deCoor
//                    selectAnnotation = annotation
//                }else{
//                    annotation.type = 1  /// 0 表示 选中
//                }
//                annotation.option = $0.option
//                annotations.append(annotation)
//            }
//        }
//        uiMapView.addAnnotations(annotations)
//
//        if showCenter, let mapCenter = mapCenter {
//            uiMapView.setCenter(mapCenter, animated: true)
//        }else{
//            uiMapView.showAnnotations(annotations, animated: true)
//        }
//    }
    
    //MARK:- 更新可移动的打头阵
//    public func updateAnimationAnnotationView(option: AnnotationViewOption = .RB_BUS ,data: [AnnotationData], cacheLine: [(lat: Double, lng: Double)]) {
//        guard !data.isEmpty else {
//            return
//        }
//        DispatchQueue.global().async {
//            var cacheBusAnnotation: [XARouteAnimationAnnotationView] = []
//            for item in data {
//
//                let coor = CLLocationCoordinate2DMake(item.lat, item.lng)
//                var oldCoor = CLLocationCoordinate2DMake(0.0, 0.0)
//                var oldAngle = 0.0
//                var oldSeq = -1
//
//                /// 判断是否有老值 的条件是 name 相同 并且不能为空； 否则取消动画显示
//                let arr: [XARouteAnimationAnnotationView] = self.animationAnnotationViews.filter { item.name != "" && $0.title == item.name }
//                if let first = arr.first {
//                    oldCoor = first.coordinate
//                    oldAngle = first.angle
//                    if let s = NSInteger(first.lineSeq ?? "-1") {
//                        oldSeq = s
//                    }
//                }
//                let  annotation = XARouteAnimationAnnotationView()
//                annotation.coordinate = arr.isEmpty ? coor : oldCoor
//                annotation.title = item.name
//                annotation.cutomer_title = item.name
//                annotation.option = option
//                annotation.lineSeq = item.lineSeq
//                annotation.oldAngle = oldAngle
//                if let angle = item.angle {
//                    annotation.angle =  angle
//                }
//                /// 有旧的信息
//                if !arr.isEmpty {
//                    var coords:[CLLocationCoordinate2D] = []
//                    coords.append(oldCoor)
//                    // 找到中间的过度点
//                    if let seq = NSInteger(item.lineSeq ?? "-1") {
//                        if seq > 0, oldSeq > 0,(seq - 1) >= oldSeq , seq < cacheLine.count {
//                            let middle = Array(cacheLine[(oldSeq)...(seq - 1)])
//                            for point in middle {
//                                coords.append(CLLocationCoordinate2DMake(point.lat, point.lng))
//                            }
//                        }
//                    }
//                    coords.append(coor)
//                    annotation.addMoveAnimation(withKeyCoordinates: &coords, count: UInt(coords.count), withDuration: 2.0, withName: "haha") { (finish) in
//                    }
//                }
//                cacheBusAnnotation.append(annotation)
//            }
//            DispatchQueue.main.async {
//                if !self.animationAnnotationViews.isEmpty {
//                    self.uiMapView.removeAnnotations(self.animationAnnotationViews)
//                }
//                self.uiMapView.addAnnotations(cacheBusAnnotation)
//                self.animationAnnotationViews = cacheBusAnnotation
//            }
//        }
//    }
    
//    public func updateAnimationAnnotationView(option: AnnotationViewOption = .RB_BUS ,data: [AnnotationData]) {
//        guard !data.isEmpty else {
//            return
//        }
//        DispatchQueue.global().async {
//            var cacheBusAnnotation: [XARouteAnimationAnnotationView] = []
//            for item in data {
//
//                let coor = CLLocationCoordinate2DMake(item.lat, item.lng)
//                var oldCoor = CLLocationCoordinate2DMake(0.0, 0.0)
//                var oldAngle = 0.0
//                var oldSeq = -1
//
//                /// 判断是否有老值 的条件是 name 相同 并且不能为空； 否则取消动画显示
//                let arr: [XARouteAnimationAnnotationView] = self.animationAnnotationViews.filter { item.name != "" && $0.title == item.name }
//                if let first = arr.first {
//                    oldCoor = first.coordinate
//                    oldAngle = first.angle
//                    if let s = NSInteger(first.lineSeq ?? "-1") {
//                        oldSeq = s
//                    }
//                }
//                let  annotation = XARouteAnimationAnnotationView()
//                annotation.coordinate = arr.isEmpty ? coor : oldCoor
//                annotation.title = item.name
//                annotation.cutomer_title = item.name
//                annotation.option = option
//                annotation.lineSeq = item.lineSeq
//                annotation.oldAngle = oldAngle
//                if let angle = item.angle {
//                    annotation.angle =  angle
//                }
//                /// 有旧的信息
//                if !arr.isEmpty {
//                    var coords:[CLLocationCoordinate2D] = []
//                    coords.append(oldCoor)
//                    coords.append(coor)
//                    annotation.addMoveAnimation(withKeyCoordinates: &coords, count: UInt(coords.count), withDuration: 2.0, withName: "haha") { (finish) in
//                    }
//                }
//                cacheBusAnnotation.append(annotation)
//            }
//            DispatchQueue.main.async {
//                if !self.animationAnnotationViews.isEmpty {
//                    self.uiMapView.removeAnnotations(self.animationAnnotationViews)
//                }
//                self.uiMapView.addAnnotations(cacheBusAnnotation)
//                self.animationAnnotationViews = cacheBusAnnotation
//            }
//        }
//    }
    //MARK:- 更新纹理
//    public func updateOverlayRenderer(showCenter: Bool = false , datas: [(option: PloyLineOption,data: [AnnotationData], lineColor: String)], inset: UIEdgeInsets = UIEdgeInsets.zero) {
//        guard !datas.isEmpty else {
//            return
//        }
//        polylines.forEach { uiMapView.remove($0) }
//        polylines = []
//
//        datas.forEach {
//            var coords:[CLLocationCoordinate2D] = []
//            for item in $0.data {
//                let pp = CLLocationCoordinate2D(latitude: item.lat, longitude:item.lng)
//                coords.append(pp)
//            }
//            let polyline:MAPolyline = MAPolyline(coordinates: &coords, count: UInt(coords.count))
//            polyline.title = $0.option.rawValue
//            polyline.subtitle = $0.lineColor
//            polylines.append(polyline)
//
//        }
//        ///在地图上添加折线对象
//        uiMapView.addOverlays(polylines)
//        if showCenter {
//            if inset == UIEdgeInsets.zero {
//                uiMapView.showOverlays(polylines, animated: true)
//            }else{
//                uiMapView.showOverlays(polylines, edgePadding: inset, animated: true)
//            }
//        }
//    }
    //MARK: - 更新纹理
//    public func updateOverlayRenderer(showCenter: Bool = false , datas: [(option: PloyLineOption,data: [String])], inset: UIEdgeInsets = UIEdgeInsets.zero) {
//        guard !datas.isEmpty else {
//            return
//        }
//        polylines.forEach { uiMapView.remove($0) }
//        polylines = []
//
//        datas.forEach {
//            var coords:[CLLocationCoordinate2D] = []
//            for item in $0.data {
//                let points = item.components(separatedBy: ";")
//                for point in points {
//                    let po = point.components(separatedBy: ",")
//                    if let latStr = po.last, let lngStr = po.first, let lat = Double(latStr), let lng =  Double(lngStr) {
//                        let pp = CLLocationCoordinate2D(latitude: lat, longitude:lng)
//                        coords.append(pp)
//                    }
//                }
//            }
//            let polyline:MAPolyline = MAPolyline(coordinates: &coords, count: UInt(coords.count))
//            polyline.title = $0.option.rawValue
//            polylines.append(polyline)
//
//        }
//        ///在地图上添加折线对象
//        uiMapView.addOverlays(polylines)
//        if showCenter {
//            if inset == UIEdgeInsets.zero {
//                uiMapView.showOverlays(polylines, animated: true)
//            }else{
//                uiMapView.showOverlays(polylines, edgePadding: inset, animated: true)
//            }
//        }
//    }
}


extension JJMapView: JJMapViewProtocolProxy {
    
    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
        locationManager.requestAlwaysAuthorization()
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {

//        if annotation.isKind(of: CICPointAnnotation.self) {
//            let anntation:CICPointAnnotation = annotation as! CICPointAnnotation
//
//            switch anntation.option {
//            case .CBOption(let op):
//                return transCBStation(anntation: anntation, op: op)
//            case .RBOption(let op):
//                break
//            default:
//                break
//            }
//
//
//        }
        ///  转换定制公交车站MARK
//        func transCBStation(anntation:CICPointAnnotation, op: CBOption) -> CICAnnotationView? {
//            var annoView = mapView.dequeueReusableAnnotationView(withIdentifier: "cb_CICPointAnnotation") as? CICAnnotationView
//            if annoView == nil {
//                annoView = CICAnnotationView(title: anntation.data.name, annotation: annotation, reuseIdentifier: "cb_CICPointAnnotation")
//            }
//            annoView?.canShowCallout = false      //设置气泡可以弹出，默认为NO
//            annoView?.calloutView.customCalloutViewClick = {[weak self] in
//                self?.delegate?.clickAnno(mapView: self!, id: anntation.data.id)
//            }
//            annoView?.image = wly_image(named: "defaultStation")?.scaleToSize(size: CGSize(width: 64, height: 64)).toCircle()
//            /// 如果站点带了地图 则显示站点自己的图片
//            if let imageurl = anntation.data.imageName, let url = URL(string: imageurl) {
//                ImageDownloader.default.downloadImage(with: url, options: [KingfisherOptionsInfoItem.originalCache(ImageCache(name: imageurl))]) { result  in
//                    switch result {
//                    case .success(let re):
//                        annoView?.image = re.image.scaleToSize(size: CGSize(width: 64, height: 64)).toCircle()
//                    case .failure(_):
//                        break
//                    }
//                }
//            }
//            annoView?.isSelected = true
//            return annoView
//        }

        //MARK: -
        if annotation.title == "当前位置" {
            return nil
        }

        if let annotation = annotation as? CICPointAnnotation {
            
            switch annotation.option {
                // 充电桩
            case .ACChargeSpot:
                let annotationView: CICAnnotationView = CICAnnotationView(annotation: annotation, reuseIdentifier: "CICPointAnnotation-spot", click: {
                    [weak self] in
                    guard let `self` = self else { return }
                    self.delegate?.clickAnno(mapView: self, id: annotation.data.id)
                    
                })
                return annotationView
            }
        }
        return nil
        
//        if annotation.isKind(of: CICPointAnnotation.self) {
//            if annotation.title == "当前位置" {
//                return nil
//            }
//            let anno :XARouteAnnotation = annotation as! XARouteAnnotation
//            if routeAnntation.option == .RB_STATION {
//                //MARK:- 实时公交的车站视图
//                let annotationView:CustomStationAnnotationView = CustomStationAnnotationView(annotation:routeAnntation,reuseIdentifier:"CustomAnnotationView_rb_station")
//
//            }else {
//                var annotationView:XAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "MAAnnotationViewIndetifier") as? XAAnnotationView
//                if annotationView == nil {
//                    annotationView = XAAnnotationView(annotation:routeAnntation,reuseIdentifier:"MAAnnotationViewIndetifier")
//                }
//                annotationView?.title = routeAnntation.title
//                annotationView?.canShowCallout = false
//
//                switch routeAnntation.option {
//                case .BEGIN:
//                    annotationView?.image = wly_image(named: "default_common_route_startpoint_normal")
//                case .END:
//                    annotationView?.image = wly_image(named: "default_common_route_endpoint_normal")
//                case .UP_DOWN:
//                    annotationView?.image = wly_image(named: "route_map_icon_bus")
//                case .HP_Seelected:
//                    annotationView?.image = wly_image(named: AnnotationViewOption.HP_Seelected.rawValue)
//                    annotationView?.isSelected = true
//                    annotationView?.calloutView.CustomCalloutViewClickBlock = {[weak self] in
//                        self?.delegate?.clickAnno(mapView: self!, id: routeAnntation.cutomer_title)
//                    }
//                case .HP_UnSelect:
//                    annotationView?.image = wly_image(named: AnnotationViewOption.HP_UnSelect.rawValue)
//                    annotationView?.isSelected = true
//                    annotationView?.calloutView.CustomCalloutViewClickBlock = {[weak self] in
//                        self?.delegate?.clickAnno(mapView: self!, id: routeAnntation.cutomer_title)
//                    }
//                case .Other:
//                    if routeAnntation.type == 0 {
//                        annotationView?.viewType = 0
//                        annotationView?.image = wly_image(named: "home_ ellipse_rb")
//                        annotationView?.isSelected = true
//                        if let anno_view = annotationView {
//                            anno_view.superview?.bringSubviewToFront(anno_view)
//                        }
//                    }else{
//                        annotationView?.viewType = 1
//                        annotationView?.image = wly_image(named: "home_ ellipse_rb")
//                        annotationView?.isSelected = true
//                        annotationView?.calloutView.CustomCalloutViewClickBlock = {[weak self] in
//                            self?.delegate?.clickAnno(mapView: self!, id: routeAnntation.cutomer_title)
//                        }
//                    }
//                default:
//                    break
//                }
//
//                if let myhome = UserDefaults.getMyHome(), routeAnntation.cutomer_title == myhome.uid {
//                    annotationView?.image = wly_image(named: "my_home_icon")
//                }
//
//                if let mycompany = UserDefaults.getMyConpany(), routeAnntation.cutomer_title == mycompany.uid {
//                    annotationView?.image = wly_image(named: "my_company_icon")
//                }
//                return annotationView
//            }
//        }

//        /// 移动的车辆
//        if annotation.isKind(of: XARouteAnimationAnnotationView.self) {
//
//            let routeAnntation:XARouteAnimationAnnotationView = annotation as! XARouteAnimationAnnotationView
//
//            if routeAnntation.option == .RB_BUS {
//                //MARK:- 实时公交的车辆视图
//                let annotationView:CustomAnnotationView = CustomAnnotationView(annotation:routeAnntation,reuseIdentifier:"CustomAnnotationView_rb_bus")
//                annotationView.zIndex = 1
//                // 必须先设置
//                annotationView.calloutName = routeAnntation.title
//                annotationView.canShowCallout = false
//                if mapView.zoomLevel >= 14.5 {
//                    annotationView.isShowCalloutView = true
//                }else{
//                    annotationView.isShowCalloutView = false
//                }
//
//                annotationView.portrait = wly_image(named: "jjj_map_bus")
//                annotationView.superview?.bringSubviewToFront(annotationView)
//                return annotationView
//            }else if routeAnntation.option == .RB_BUS_DirectionAngle {
//                let annotationView:CustomBusAnnotationView = CustomBusAnnotationView(annotation:routeAnntation, name: routeAnntation.title, image: wly_image(named: "bus_onMap"))
//                annotationView.zIndex = 1
//                annotationView.oldAngle = routeAnntation.oldAngle
//                annotationView.angle = routeAnntation.angle
//                annotationView.superview?.bringSubviewToFront(annotationView)
//                return annotationView
//            } else if routeAnntation.option == .NetWork_Car_DirectionAngle {
//                // 网约车
//                let annotationView:NetWorkCarAnnotationView = NetWorkCarAnnotationView(annotation:routeAnntation,reuseIdentifier:"CustomAnnotationView_rb_bus_Angle")
//                annotationView.zIndex = 1
//                // 必须先设置
//                annotationView.calloutName = routeAnntation.title
//                annotationView.canShowCallout = false
//                annotationView.isShowCalloutView = false
//                annotationView.portrait = wly_image(named: "special_car")
//                annotationView.angle = routeAnntation.angle
//                annotationView.superview?.bringSubviewToFront(annotationView)
//                return annotationView
//            }
//        }
//        return nil;
    }
    
    /// 纹理线条的绘制
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if overlay.isKind(of: MAPolyline.self) {
            let polylineRenderer = MAPolylineRenderer(polyline: overlay as? MAPolyline)
            polylineRenderer?.lineWidth    = 20.0
            if let name = overlay.title as? String {
                let option = PloyLineOption(rawValue: name)
                polylineRenderer?.strokeImage = wly_image(named: "custtexture")
//                switch option {
//                case .BIKE:
//                    polylineRenderer?.strokeImage = wly_image(named: "custtexture")
//                case .BUS:
//                    polylineRenderer?.strokeImage = wly_image(named: "custtexture_custom")
//                case .WALK:
//                    polylineRenderer?.strokeImage = wly_image(named: "walking_texture")
//                case .none:
//                    polylineRenderer?.strokeImage = wly_image(named: "custtexture")
//                case .Line:
//                    polylineRenderer?.strokeImage = wly_image(named: "custtexture")
//                    /// 拥挤度的时候用
//                    //                    if let colorStr = overlay.subtitle as? String, colorStr != "" {
//                    //                        polylineRenderer?.strokeColor = UIColor.hex(hexString: colorStr)
//                    //                    }else{
//                    //                        polylineRenderer?.strokeColor = UIColor.themeColor()
//                    //                    }
//                    //                    polylineRenderer?.lineWidth = 6.0
//                }
            }
            return polylineRenderer
        }
        return nil;
    }
    
    /**
     * @brief 地图移动结束后调用此接口
     * @param mapView       地图view
     * @param wasUserAction 标识是否是用户动作
     */
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            // 达到一定范围从心获取附近站点 必须是用户手动移动
//            delegate?.mapDidMove(mapView: self, point: GPSPoint(gpsName: "正在获取上车地点", lat: "0", lng: "0"))
            getGeoCodeSearch()
        }
    }
    
    func mapView(_ mapView: MAMapView!, mapWillZoomByUser wasUserAction: Bool){
        
    }
    
    func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
        // 达到一定范围从心获取附近站点 必须是用户手动移动
//        if !fromNealyStationMap {
//            mapView.removeAnnotations(annotations)
//            mapView.addAnnotations(annotations)
//        }
    }
    
    func mapView(_ mapView: MAMapView!, mapWillMoveByUser wasUserAction: Bool) {
//        delegate?.mapwillMove(mapView: self, point: GPSPoint(gpsName: "正在获取上车地点", lat: "0", lng: "0"))
    }
    
    /**
     * @brief 当取消选中一个annotation view时，调用此接口
     * @param mapView 地图View
     * @param view 取消选中的annotation view
     */
    func mapView(_ mapView: MAMapView!, didDeselect view: MAAnnotationView!) {
        
    }
}

extension JJMapView: AMapSearchDelegate {
    
    public func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if response.regeocode != nil, response.regeocode.pois.count >= 1 {
            
            let poiInfo = response.regeocode.pois[0]
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
//            delegate?.mapDidMove(mapView: self, point: gpsPoint)
        }
    }
    
    public func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
//        delegate?.mapDidMove(mapView: self, point: GPSPoint(gpsName: "上车地点获取失败", lat: "0", lng: "0"))
    }
}

