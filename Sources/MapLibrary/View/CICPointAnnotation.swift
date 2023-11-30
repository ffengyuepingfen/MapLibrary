//
//  XARouteAnnotation.swift
//  XAOfficialBus
//
//  Created by zhonghangxun on 2018/12/6.
//  Copyright © 2018 zhonghangxun. All rights reserved.
//

import UIKit
import AMapNaviKit

///  带数据的地图坐标
class CICPointAnnotation: MAPointAnnotation {

    var isSelected = false

    var data: SpotMapMark

    var sourceCoordinate: CLLocationCoordinate2D
    
    var option: MapMarkOption = .ACChargeSpot

    init(isSelected: Bool = false, data: SpotMapMark, option: MapMarkOption ,sourceCoordinate: CLLocationCoordinate2D) {
        self.option = option
        self.isSelected = isSelected
        self.data = data
        self.sourceCoordinate = sourceCoordinate
        super.init()
    }
}
