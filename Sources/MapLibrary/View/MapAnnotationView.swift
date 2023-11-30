//
//  XAAnnotationView.swift
//  XAOfficialBus
//
//  Created by 王相博 on 2018/12/12.
//  Copyright © 2018 zhonghangxun. All rights reserved.
//

import Foundation
import AMapNaviKit
import WLYUIKitBase


/// 自定义中航讯标记视图
class CICAnnotationView: MAAnnotationView {
    
    private let CICCalloutHeight: CGFloat = 54.0
    private var callout = CICCalloutView()

    private var anno: CICPointAnnotation
    
    init(annotation: CICPointAnnotation, reuseIdentifier: String, click: (()->())?) {
        self.anno = annotation
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = false
        self.image = UIColor.systemBlue.image(size: CGSize(width: 4, height: 4)).isCircleImage()
        self.addSubview(callout)
        callout.center = CGPoint(x: self.bounds.width/2 + calloutOffset.x, y: -callout.bounds.height/2 + calloutOffset.y)
        callout.updateUI(data: annotation.data)
        callout.calloutViewClick = click
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //处理超出区域点击无效的问题
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, with: event)
        if view == nil {
            let tempoint = callout.convert(point, from: self)
            if callout.bounds.contains(tempoint) {
                view = callout
            }
        }
        return view
    }
}

//public class CustomAnnotationView: MAAnnotationView {
//
//    //MARK:- constant let
//    let kWidth = 20.0
//    let kHeight = 20.0
//
//    let kHoriMargin = 5.0
//    let kVertMargin = 5.0
//
//    let kCalloutWidth = 80.0
//    let kCalloutHeight: CGFloat = 30.0
//
//    //MARK:- public
//    public var calloutName: String = "-"
//
//    public var portrait: UIImage? = nil {
//        didSet {
//            portraitImageView.image = portrait
//        }
//    }
//
//    public var calloutView: UIView?
//
//    //MARK:-
//    private var portraitImageView: UIImageView!
//
//    public var isShowCalloutView = false {
//        didSet {
//            // 确定要显示文字气泡的时候 需要判断气泡是否有值
//            if isShowCalloutView, calloutName != "" {
//                if self.calloutView == nil {
//                    /* Construct custom callout. */
//                    let width:CGFloat = calloutName.getNormalStrW(strFont: 12.0, h: CGFloat(kCalloutHeight)) + 20
//                    self.calloutView = CustomCalloutView(frame: CGRect(x: 0, y: 0, width: width < 80 ? 80 : width, height: CGFloat(kCalloutHeight)))
//                    self.calloutView!.center = CGPoint(x: self.bounds.width/2 + self.calloutOffset.x, y: -kCalloutHeight/2 + calloutOffset.y)
//
//                    let label = UILabel(frame: calloutView!.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)))
//                    label.backgroundColor = UIColor.clear
//                    label.font = UIFont.systemFont(ofSize: 10.0)
//                    label.textAlignment = .center
//                    label.textColor = UIColor.label
//                    label.text = calloutName
//                    self.calloutView?.addSubview(label)
//                    self.addSubview(self.calloutView!)
//                }
//            }
//            calloutView?.isHidden = !isShowCalloutView
//        }
//    }
//
//    public override func setSelected(_ selected: Bool, animated: Bool) {
//        if self.isSelected == selected {
//            return
//        }
//
//        if selected {
//            if self.calloutView == nil {
//                /* Construct custom callout. */
//                let width:CGFloat = calloutName.getNormalStrW(strFont: 12.0, h: CGFloat(kCalloutHeight)) + 20
//                self.calloutView = CustomCalloutView(frame: CGRect(x: 0, y: 0, width: width < 80 ? 80 : width, height: CGFloat(kCalloutHeight)))
//                self.calloutView!.center = CGPoint(x: self.bounds.width/2 + self.calloutOffset.x, y: -kCalloutHeight/2 + calloutOffset.y)
//
//                let label = UILabel(frame: calloutView!.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)))
//                label.backgroundColor = UIColor.clear
//                label.font = UIFont.systemFont(ofSize: 10.0)
//                label.textAlignment = .center
//                label.textColor = UIColor.label
//                label.text = calloutName
//                self.calloutView?.addSubview(label)
//            }
//            self.addSubview(self.calloutView!)
//        }else{
//            self.calloutView?.removeFromSuperview()
//        }
//
//        super.setSelected(selected, animated: animated)
//    }
//
//
//    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//
//        var inside = super.point(inside: point, with: event)
//        /* Points that lie outside the receiver’s bounds are never reported as hits,
//         even if they actually lie within one of the receiver’s subviews.
//         This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
//         */
//        if !inside && self.isSelected, calloutView != nil {
//            inside = self.calloutView!.point(inside: self.convert(point, to: self.calloutView), with: event)
//        }
//        return inside
//    }
//
//    //处理超出区域点击无效的问题
//    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        var view = super.hitTest(point, with: event)
//        if view == nil ,calloutView != nil {
//            let tempoint = calloutView!.convert(point, from: self)
//            if calloutView!.bounds.contains(tempoint) {
//                view = calloutView
//            }
//        }
//        return view
//    }
//
//    //MARK:-- Life Cycle
//
//    public override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
//        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//
//        self.bounds =  CGRect(x: 0, y: 0, width: kWidth, height: kHeight)
//        self.backgroundColor = UIColor.clear
//
//        /* Create portrait image view and add to view hierarchy. */
//        self.portraitImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: kWidth, height: kHeight))
//        self.addSubview(self.portraitImageView)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//
//
//public class CustomStationAnnotationView: MAAnnotationView {
//
//    //MARK:- constant let
//    let kWidth = 20.0
//    let kHeight = 20.0
//
//    let kHoriMargin = 5.0
//    let kVertMargin = 5.0
//
//    let kCalloutWidth = 80.0
//    let kCalloutHeight: CGFloat = 20.0
//
//    //MARK:- public
//    public var calloutName: String = "-"
//    public var id: String = "-"
//    public var portrait: UIImage? = nil {
//        didSet {
//            portraitImageView.image = portrait
//        }
//    }
//
//    public var calloutView: UIView?
//
//    //MARK:-
//    private var portraitImageView: UIImageView!
//
//    public var CustomCalloutViewClickBlock:(()->())?
//
//    public var isShowCalloutView = false {
//        didSet {
//            if isShowCalloutView {
//                if self.calloutView == nil {
//                    /* Construct custom callout. */
//                    let width:CGFloat = calloutName.getNormalStrW(strFont: 14.0, h: CGFloat(kCalloutHeight)) + 20
//                    let label = UIButton(frame: CGRect(x: CGFloat(kWidth + 10), y: 0, width: width < 80 ? 80 : width, height: CGFloat(kCalloutHeight)))
//                    label.backgroundColor = UIColor.clear
//                    label.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
//                    label.setTitleColor(UIColor.hex(hexString: "#333333"), for: .normal)
//                    label.setTitle(calloutName, for: .normal)
//                    label.contentHorizontalAlignment = .left
//                    label.addTarget(self, action: #selector(calloutButtonClick), for: .touchUpInside)
//                    label.layer.cornerRadius = 6.0
//                    label.layer.borderWidth = 1.0
//                    label.layer.borderColor = UIColor.systemBlue.cgColor
//                    label.contentHorizontalAlignment = .center
//                    label.backgroundColor = UIColor.white
//                    self.calloutView = label
//                    self.addSubview(self.calloutView!)
//                }
//            }
//            calloutView?.isHidden = !isShowCalloutView
//        }
//    }
//
//    public override func setSelected(_ selected: Bool, animated: Bool) {
//        if self.isSelected == selected {
//            return
//        }
//
//        if selected {
//            if self.calloutView == nil {
//                /* Construct custom callout. */
//                let width:CGFloat = calloutName.getNormalStrW(strFont: 12.0, h: CGFloat(kCalloutHeight)) + 20
//                let label = UIButton(frame: CGRect(x: CGFloat(kWidth + 10), y: 0, width: width < 80 ? 80 : width, height: CGFloat(kCalloutHeight)))
//                label.backgroundColor = UIColor.clear
//                label.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
//                label.setTitleColor(UIColor.hex(hexString: "#333333"), for: .normal)
//                label.setTitle(calloutName, for: .normal)
//                label.contentHorizontalAlignment = .left
//                label.addTarget(self, action: #selector(calloutButtonClick), for: .touchUpInside)
//                label.layer.cornerRadius = 6.0
//                label.layer.borderWidth = 1.0
//                label.layer.borderColor = UIColor.systemBlue.cgColor
//                label.contentHorizontalAlignment = .center
//                label.backgroundColor = UIColor.white
//                self.calloutView = label
//            }
//            self.addSubview(self.calloutView!)
//        }else{
//            self.calloutView?.removeFromSuperview()
//        }
//
//        super.setSelected(selected, animated: animated)
//    }
//
//    @objc private func calloutButtonClick() {
//        if CustomCalloutViewClickBlock != nil {
//            CustomCalloutViewClickBlock!()
//        }
//    }
//
//    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//
//        var inside = super.point(inside: point, with: event)
//        /* Points that lie outside the receiver’s bounds are never reported as hits,
//         even if they actually lie within one of the receiver’s subviews.
//         This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
//         */
//        if !inside && self.isSelected, calloutView != nil {
//            inside = self.calloutView!.point(inside: self.convert(point, to: self.calloutView), with: event)
//        }
//        return inside
//    }
//
//    //处理超出区域点击无效的问题
//    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        var view = super.hitTest(point, with: event)
//        if view == nil ,calloutView != nil {
//            let tempoint = calloutView!.convert(point, from: self)
//            if calloutView!.bounds.contains(tempoint) {
//                view = calloutView
//            }
//        }
//        return view
//    }
//
//    //MARK:-- Life Cycle
//
//    public override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
//        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//
//        self.bounds =  CGRect(x: 0, y: 0, width: kWidth, height: kHeight)
//        self.backgroundColor = UIColor.clear
//
//        /* Create portrait image view and add to view hierarchy. */
//        self.portraitImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: kWidth, height: kHeight))
//        self.addSubview(self.portraitImageView)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//// 地图上带 方向角的bus
//public class CustomBusAnnotationView: MAAnnotationView {
//
//    //MARK:- constant let
//    let kWidth = 44.0
//    let kHeight = 44.0
//
//    let kHoriMargin = 5.0
//    let kVertMargin = 5.0
//
//    let kCalloutWidth = 60.0
//    let kCalloutHeight: CGFloat = 20.0
//
//    //MARK:- public
//    private var calloutName: String = "-"
//
//    public var oldAngle: Double = 0 {
//        didSet {
//            // 旋转 图片
//            let transform = CGAffineTransform.init(rotationAngle: CGFloat(self.oldAngle/180*Double.pi))
//            //            portraitImageView.transform = transform;//旋转
//            self.transform = transform;//旋转
//        }
//    }
//
//    public var angle: Double = 0 {
//        didSet {
//            UIView.animate(withDuration: 2.0) {
//                // 旋转 图片
//                let transform = CGAffineTransform.init(rotationAngle: CGFloat(self.angle/180*Double.pi))
//                //            portraitImageView.transform = transform;//旋转
//                self.transform = transform;//旋转
//            }
//        }
//    }
//
//    public var calloutView: UIView?
//
//    //MARK:-
//    private var portraitImageView: UIImageView!
//
//    private func showCalloutView() {
//        // 确定要显示文字气泡的时候 需要判断气泡是否有值
//        if !calloutName.isEmpty {
//            if self.calloutView == nil {
//                /* Construct custom callout. */
//                let width:CGFloat = calloutName.getNormalStrW(strFont: 12.0, h: CGFloat(kCalloutHeight)) + 20
//                self.calloutView = CustomCalloutView(frame: CGRect(x: 0, y: 0, width: width < kCalloutWidth ? kCalloutWidth : width, height: CGFloat(kCalloutHeight)))
//                self.calloutView!.center = CGPoint(x: self.bounds.width/2 + self.calloutOffset.x, y: -kCalloutHeight/2 + calloutOffset.y)
//
//                let label = UILabel(frame: calloutView!.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
//                label.backgroundColor = UIColor.clear
//                label.font = UIFont.systemFont(ofSize: 10.0)
//                label.textAlignment = .center
//                label.textColor = UIColor.systemBlue
//                label.text = calloutName
//                self.calloutView?.addSubview(label)
//                self.addSubview(self.calloutView!)
//            }
//        }
//        calloutView?.isHidden = calloutName.isEmpty
//    }
//
//    //MARK:-- Life Cycle
//    public init(annotation: MAAnnotation!, name: String = "-", image: UIImage?) {
//        super.init(annotation: annotation, reuseIdentifier: "CustomBusAnnotationView_reuseIdentifier")
//        self.bounds =  CGRect(x: 0, y: 0, width: kWidth, height: kHeight)
//        self.backgroundColor = UIColor.clear
//        self.calloutName = name
//        self.portraitImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: kWidth, height: kHeight))
//        self.addSubview(self.portraitImageView)
//        self.portraitImageView.image = image
//        self.canShowCallout = false
//        showCalloutView()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//
//        var inside = super.point(inside: point, with: event)
//        if !inside && self.isSelected, calloutView != nil {
//            inside = self.calloutView!.point(inside: self.convert(point, to: self.calloutView), with: event)
//        }
//        return inside
//    }
//}
//
///// 网约车专用
//public class NetWorkCarAnnotationView: MAAnnotationView {
//
//    //MARK:- constant let
//    let kWidth = 32.0
//    let kHeight = 32.0
//
//    let kHoriMargin = 5.0
//    let kVertMargin = 5.0
//
//    let kCalloutWidth = 80.0
//    let kCalloutHeight: CGFloat = 20.0
//
//    //MARK:- public
//    public var calloutName: String = "-"
//
//    public var angle: Double = 0 {
//        didSet {
//            // 旋转 图片
//            let transform = CGAffineTransform.init(rotationAngle: CGFloat(angle/180*Double.pi))
//            portraitImageView.transform = transform;//旋转
//        }
//    }
//
//    public var portrait: UIImage? = nil {
//        didSet {
//            portraitImageView.image = portrait
//        }
//    }
//
//    public var calloutView: UIView?
//
//    //MARK:-
//    private var portraitImageView: UIImageView!
//
//    public var isShowCalloutView = false {
//        didSet {
//            // 确定要显示文字气泡的时候 需要判断气泡是否有值
//            if isShowCalloutView, calloutName != "" {
//                if self.calloutView == nil {
//                    /* Construct custom callout. */
//                    let width:CGFloat = calloutName.getNormalStrW(strFont: 12.0, h: CGFloat(kCalloutHeight)) + 20
//                    self.calloutView = CustomCalloutView(frame: CGRect(x: 0, y: 0, width: width < 80 ? 80 : width, height: CGFloat(kCalloutHeight)))
//                    self.calloutView!.center = CGPoint(x: self.bounds.width/2 + self.calloutOffset.x, y: -kCalloutHeight/2 + calloutOffset.y)
//
//                    let label = UILabel(frame: calloutView!.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
//                    label.backgroundColor = UIColor.clear
//                    label.font = UIFont.systemFont(ofSize: 10.0)
//                    label.textAlignment = .center
//                    label.textColor = UIColor.systemBlue
//                    label.text = calloutName
//                    self.calloutView?.addSubview(label)
//                    self.addSubview(self.calloutView!)
//                }
//            }
//            calloutView?.isHidden = !isShowCalloutView
//        }
//    }
//
//    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//
//        var inside = super.point(inside: point, with: event)
//        /* Points that lie outside the receiver’s bounds are never reported as hits,
//         even if they actually lie within one of the receiver’s subviews.
//         This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
//         */
//        if !inside && self.isSelected, calloutView != nil {
//            inside = self.calloutView!.point(inside: self.convert(point, to: self.calloutView), with: event)
//        }
//        return inside
//    }
//
//    //MARK:-- Life Cycle
//
//    public override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
//        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//
//        self.bounds =  CGRect(x: 0, y: 0, width: kWidth, height: kHeight)
//        self.backgroundColor = UIColor.clear
//
//        /* Create portrait image view and add to view hierarchy. */
//        self.portraitImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: kWidth, height: kHeight))
//        self.addSubview(self.portraitImageView)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
