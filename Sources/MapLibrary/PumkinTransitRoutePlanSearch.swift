//
//  PumkinTransitRoutePlanSearch.swift
//  XAOfficialBus
//
//  Created by zhonghangxun on 2018/12/5.
//  Copyright © 2018 zhonghangxun. All rights reserved.
//

import Foundation
import AMapSearchKit
import AMapFoundationKit
import AMapLocationKit
import AMapNaviKit

/// 公交换乘策略
public enum SearchPlanOption:NSInteger {
    /// 最快捷模式
    case Fastest = 0
    /// 最经济模式
    case Cheapest  = 1
    /// 最少换乘模式
    case LittleChange = 2
    /// 最少步行模式
    case LittleWalk = 3
    /// 最舒适模式
    case Comfortable = 4
    /// 不乘地铁模式
    case NoSubWay = 5
    /// 骑行查询
    case Ridding = 1000
    /// 步行
    case Walk = 2000
    /// 驾车
    case Car = 3000
}

public class PumkinSearchPlan:NSObject {
    
    struct ErrorInfo {
        static let NOTranse = "没有换乘方案"
        static let TranseError = "换乘方案查询失败"
    }
    
    private var searcher:AMapSearchAPI!
    private var searchType:SearchPlanOption
    private var callBlock:(([TranPlanDetaile],_ errorInfo:String?)->())?
    var CallBlock:(([TranPlanDetaile],_ errorInfo:String?)->())?
    private var cityName:String
    public var CallWalkStrBlock:((String,[String])->())?
    /// 当为骑行查询的时候 需要的字段
    var bikeStr = ""
    
    var driverCallBlock:(((ployline: String, distance: String, duration: String),_ errorInfo:String?)->())?
    
    public init(searchType:SearchPlanOption,cityName:String) {
        self.searchType = searchType
        
        self.cityName = cityName
        self.searcher = AMapSearchAPI()
        super.init()
    }
    /// 驾车路径规划
//    public func beginDriverRoutePlanSearch(plan:SearchPlan,callBlock:@escaping (((ployline: String, distance: String, duration: String),_ errorInfo:String?)->())){
//        self.driverCallBlock = callBlock
//        searcher.delegate = self
//        let request = AMapDrivingRouteSearchRequest()
//        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(Double(plan.endPoint.latitude)!), longitude: CGFloat(Double(plan.endPoint.longitude)!))
//        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(Double(plan.startPoint.latitude)!), longitude: CGFloat(Double(plan.startPoint.longitude)!))
//        request.requireExtension = true
//        // request.strategy //：路径规划的策略，可选，默认为0-速度优先
//        searcher.aMapDrivingRouteSearch(request)
//    }
    
//    public func begainTransitRoutePlanSearch(plan:SearchPlan,callBlock:@escaping (([TranPlanDetaile],_ errorInfo:String?)->())) {
//        self.callBlock = callBlock
//        if searcher == nil {
//            searcher = AMapSearchAPI()
//        }
//        searcher.delegate = self
//        let navi = AMapTransitRouteSearchRequest()
//        navi.requireExtension = true
//        navi.city = cityName
//        navi.strategy = searchType.rawValue
//        navi.nightflag = true
//        navi.destination = AMapGeoPoint.location(withLatitude: CGFloat(Double(plan.endPoint.latitude)!), longitude: CGFloat(Double(plan.endPoint.longitude)!))
//        navi.origin = AMapGeoPoint.location(withLatitude: CGFloat(Double(plan.startPoint.latitude)!), longitude: CGFloat(Double(plan.startPoint.longitude)!))
//
//        searcher.aMapTransitRouteSearch(navi)
//    }
    
//    public func begainBicycleSearch(plan:SearchPlan,bikeStr:String,callBlock:@escaping (([TranPlanDetaile],_ errorInfo:String?)->())) {
//        self.CallBlock = callBlock
//        self.bikeStr = bikeStr
//        if searcher == nil {
//            searcher = AMapSearchAPI()
//        }
//        searcher.delegate = self
//        let request = AMapRidingRouteSearchRequest()
//        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(Double(plan.endPoint.latitude)!), longitude: CGFloat(Double(plan.endPoint.longitude)!))
//        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(Double(plan.startPoint.latitude)!), longitude: CGFloat(Double(plan.startPoint.longitude)!))
//        searcher.aMapRidingRouteSearch(request)
//    }
    
    public func begainWalk(startPoint:(Double,Double),endPoint:(Double,Double)) {
        if searcher == nil {
            searcher = AMapSearchAPI()
        }
        searcher.delegate = self
        let request = AMapWalkingRouteSearchRequest()
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startPoint.0), longitude: CGFloat(startPoint.1))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(endPoint.0), longitude: CGFloat(endPoint.1))
        searcher.aMapWalkingRouteSearch(request)
    }
    
}

extension PumkinSearchPlan: AMapSearchDelegate{
    public func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
        
//        switch searchType {
//        case .Ridding: /// 骑行
//            if response.count >= 1 {
//                let result = goBicycle(route: response.route, topStr: bikeStr)
//                if CallBlock != nil {
//                    CallBlock!(result, "")
//                }
//            }
//            break
//        case .Walk: /// 步行行
//            if response.count >= 1 {
//                let result = goBicycleWalk(route: response.route)
//                if let callWalkStrBlock = CallWalkStrBlock {
//                    callWalkStrBlock(result.0,result.1)
//                }
//            }
//            break
//        case .Car:
//            if response.count >= 1 {
//                if let result = response.route.paths.first, let call = driverCallBlock {
//                    call((result.polyline, "\(result.distance)", "\(result.duration)"), nil)
//                }
//            }
//            break
//        default:
//            if response.count >= 1,let plans = response.route.transits , plans.count >= 1 {
//                let planSort = plans.sorted { (m1, m2) -> Bool in
//                    return m1.duration < m2.duration
//                }
//                let result = poiToBusLineString(plans: planSort)
//                if let callback = callBlock {
//                    callback(result,nil)
//                }
//            }else{
//                if let callback = callBlock {
//                    callback([],ErrorInfo.NOTranse)
//                }
//            }
//        }
    }
    public func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        if let callBlock = callBlock {
            callBlock([],ErrorInfo.TranseError)
        }
        if let ca = driverCallBlock {
            ca(("","",""), "没有可规划路线")
        }
    }
}

/// 自行车步行解析
func goBicycleWalk(route:AMapRoute) -> (String,[String]) {
    var polyLine:[String] = []
    var distance = 0
    if let paths = route.paths {
        for path in paths {
            distance = distance + path.distance
            for poly in path.steps {
                polyLine.append(poly.polyline)
            }
            
        }
    }
    return ("\(distance)",polyLine)
}
//// 自从车解析
func goBicycle(route:AMapRoute,topStr:String) -> [TranPlanDetaile] {
    var result:[TranPlanDetaile] = []
    if let paths = route.paths {
        for path in paths {
            var bottomString = "--"
            let hour = path.duration/60/60
            if hour > 0 {
                bottomString = "骑行距离:\(path.distance/1000)公里,大约耗时:\(hour)小时\(path.duration/60%60)分钟"
            }else{
                bottomString = "骑行距离:\(path.distance/1000)公里,大约耗时:\(path.duration/60%60)分钟"
            }
            
            var polyLines:[String] = []
            for poly in path.steps {
                polyLines.append(poly.polyline)
            }
            let plan = TranPlanDetaile(lineNames: topStr, transferPlanDescrip: bottomString, startPointName: "", endPointName: "", plan: nil, bicyclePloyLine: polyLines, walkPloyLine: nil)
            result.append(plan)
        }
    }
    return result
}

//func poiToBusLineString(plans:[AMapTransit]) -> [TranPlanDetaile] {
//    let citylines = ServiceDictionary.getCityConfigLines()
//    var result:[TranPlanDetaile] = []
//    for routeLine in plans {
//        var startSite = ""
//        var endSite = ""
//        /// 线路描述
//        var topString = ""
//        var bottomString = ""
//
//        let hour = routeLine.duration/60/60
//        if hour > 0 {
//            bottomString = "大约\(hour)小时\(routeLine.duration/60%60)分钟·全程\(routeLine.distance/1000)公里·步行\(routeLine.walkingDistance)米"
//        }else{
//            bottomString = "大约\(routeLine.duration/60%60)分钟·全程\(routeLine.distance/1000)公里·步行\(routeLine.walkingDistance)米"
//        }
//
//        /// 详细的换乘方案
//        let Transit = poiToDetailsContorllerDatas(Transit: routeLine)
//
//
//        for routeStep in routeLine.segments {
//            /// 获取外层信息
//            if let busArray = routeStep.buslines {
//                for busWay in busArray {
//                    startSite = busWay.departureStop.name
//                    endSite = busWay.arrivalStop.name
//
//                    if let ss = busWay.name {
//                        var newString = ss
//                        newString = newString.components(separatedBy: "(")[0]
//                        //                        newString = newString.replacingOccurrences(of: "路", with: "")
//                        //                        newString = newString.components(separatedBy: "/")[0]
//                        // 在这里匹配本地线路名称
//                        if let line = citylines.filter { $0.0 == newString }.first?.1 {
//                            newString = line
//                        }
//                        topString = topString + newString + "/"
//                    }
//
//                }
//            }
//            /// 是否包含箭头
//            if topString.contains("→") {
//                let str = topString.components(separatedBy: "→")
//                if str.count == 2 {
//                    let ss = str[1]
//                    if ss != "" {
//                        topString = topString.substring(to: topString.count - 1)
//                        topString = topString + "→"
//                    }else{
//                        if routeLine.segments.count > 2 {
//                            topString = ""
//                        }
//                    }
//                }
//
//            }else{
//                if topString != "" {
//                    topString = topString.substring(to: topString.count - 1)
//                    topString = topString + "→"
//                }
//            }
//
//        }
//        topString = topString.substring(to: topString.count - 1)
//        /// 组合
//        if topString != "" , topString != " " {
//            let model = TranPlanDetaile(lineNames: topString, transferPlanDescrip: bottomString, startPointName: startSite, endPointName: endSite, plan: Transit, bicyclePloyLine: nil, walkPloyLine: nil)
//            result.append(model)
//        }
//    }
//    return result
//}

func poiToDetailsContorllerDatas(Transit:AMapTransit) -> [[PlanStepDetaile]] {
    var result:[[PlanStepDetaile]] = []
    //// 步行
    for i in 0..<Transit.segments.count {
        let segment = Transit.segments[i]
        
        if  let walk = segment.walking, walk.steps.count >= 1 {
            var walkPolyLine = ""
            var siteName = ""
            var byWalkType = ""
            if i == 0 {
                byWalkType = "start"
            }else if i == Transit.segments.count - 1 {
                byWalkType = "end"
            }else{
                byWalkType = "middle"
            }
            
            let min = segment.walking.duration/60
            for step in segment.walking.steps {
                if step.polyline != "" {
                    walkPolyLine = walkPolyLine + step.polyline
                }
                if step.assistantAction != "",step.assistantAction.count > 2 {
                    siteName = step.assistantAction.substring(to: 2)
                }
            }
            
            /// buxing
            let walk = PlanStepDetaile(busPlan: nil,
                                       walkPlan: stepWalk(polyLine: walkPolyLine,
                                                          siteName: siteName,
                                                          stepType: "walk",
                                                          byWalkType: byWalkType,
                                                          instruction: "步行\(segment.walking.distance)米、大约\(min)分钟",
                                                          startPoint: planPoint(ptLat: "\(segment.walking.origin.latitude)",
                                                                                ptLong: "\(segment.walking.origin.longitude)",
                                                                                uid: nil,
                                                                                title: segment.enterName),
                                                          endPoint: planPoint(ptLat: "\(segment.walking.destination.latitude)",
                                                                              ptLong: "\(segment.walking.destination.longitude)",
                                                                              uid: nil,
                                                                              title: segment.exitName)))
            
            result.append([walk])
        }
        
        /// 坐车
        if segment.buslines.count > 0 {
            var byBusStr = ""
            for busWay in segment.buslines {
                if let ss = busWay.name {
                    var newString = ss
                    newString = newString.components(separatedBy: "(")[0]
                    //                    newString = newString.replacingOccurrences(of: "路", with: "")
                    newString = newString.components(separatedBy: "/")[0]
                    byBusStr = byBusStr + newString
                }
            }
            if byBusStr.count >= 1{
                byBusStr = byBusStr.substring(to: byBusStr.count - 1)
            }
            
            let busLine = segment.buslines[0]
            let busPolyLine = busLine.polyline
            /// 开始组建数据
            let startBus = PlanStepDetaile(busPlan: stepBus(stepType: "bus", instruction: "\(busLine.departureStop.name ?? "---")", startPoint: planPoint(ptLat: nil, ptLong: nil, uid: busLine.departureStop.uid, title: busLine.departureStop.name), endPoint: planPoint(ptLat: nil, ptLong: nil, uid: busLine.arrivalStop.uid, title: busLine.arrivalStop.name), polyLine: busPolyLine, busType: "start", corlorType: "\(i)", vehicleInfo: nil, statesType: true), walkPlan: nil)
            
            let middleBus = PlanStepDetaile(busPlan: stepBus(stepType: "bus", instruction: "乘坐\(byBusStr)", startPoint: planPoint(ptLat: nil, ptLong: nil, uid: busLine.departureStop.uid, title: busLine.departureStop.name), endPoint: planPoint(ptLat: nil, ptLong: nil, uid: busLine.arrivalStop.uid, title: busLine.arrivalStop.name), polyLine: nil, busType: "middle", corlorType: "\(i)", vehicleInfo: busLine.viaBusStops, statesType: true), walkPlan: nil)
            
            let endBus = PlanStepDetaile(busPlan: stepBus(stepType: "bus", instruction: "\(busLine.arrivalStop.name ?? "---")", startPoint: planPoint(ptLat: nil, ptLong: nil, uid: busLine.departureStop.uid, title: busLine.departureStop.name), endPoint: planPoint(ptLat: nil, ptLong: nil, uid: busLine.arrivalStop.uid, title: busLine.arrivalStop.name), polyLine: "", busType: "end", corlorType: "\(i)", vehicleInfo: nil, statesType: true), walkPlan: nil)
            
            result.append([startBus])
            result.append([middleBus])
            result.append([endBus])
        }
    }
    
    return result
}

/// 车辆换乘方案
public struct TranPlanDetaile {
    /// 方案的线路名称
    public let lineNames:String?
    /// 方案的描述
    public let transferPlanDescrip:String?
    
    /// 方案的起点
    public let startPointName:String?
    /// 方案的终点
    public let endPointName:String?
    /// 步骤数组 : bus的分解步骤
    public var plan:[[PlanStepDetaile]]?
    /// 骑行的步骤信息: 自行车方案
    public var bicyclePloyLine:[String]?
    /// 自行车方案的步行方案
    public var walkPloyLine:[[String]]?
}

public struct PlanStepDetaile {
    public var busPlan:stepBus?
    public let walkPlan:stepWalk?
}

public struct stepWalk {
    /// 步行轨迹点
    public let polyLine:String?
    /// 路段导航名
    public let siteName:String?
    /// walk 走路 bus 坐车
    public let stepType:String?
    /// start end middle
    public let byWalkType:String?
    /// 步行描述
    public let instruction:String?
    /// 起点坐标
    public let startPoint:planPoint?
    /// 终点坐标
    public let endPoint:planPoint?
}

public struct stepBus {
    /// 步骤类型
    public let stepType:String?
    /// 描述
    public let instruction:String?
    /// 起点信息
    public let startPoint:planPoint?
    /// 终点信息
    public let endPoint:planPoint?
    /// 轨迹点
    public let polyLine:String?
    /// start middle end
    public let busType:String?
    /// ...
    public let corlorType:String?
    /// 途径的公交站
    public let vehicleInfo:[AMapBusStop]?
    /// 展开状态
    public var statesType:Bool = false
}

public struct planPoint {
    ///
    public let ptLat:String?
    ///
    public let ptLong:String?
    /// uid
    public let uid:String?
    /// 名称
    public let title:String?
}


