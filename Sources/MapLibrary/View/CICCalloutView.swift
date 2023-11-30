//
//  XACustomCalloutView.swift
//  XAOfficialBus
//
//  Created by 王相博 on 2018/12/12.
//  Copyright © 2018 zhonghangxun. All rights reserved.
//

import UIKit
import WLYUIKitBase
import QuartzCore

/// 自定义
public class CICCalloutView: UIView {
//    let kArrorHeight: CGFloat = 10
    /// 点击事件
    public var calloutViewClick: (()->())?

    private lazy var titleLabel: UILabel = {
        let tt = UILabel.footnote("", weight: .medium)
        tt.text = "￥0.9822"
        tt.textAlignment = .center
        return tt
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let tt = UILabel.footnote("", color: UIColor.systemRed)
        tt.text = "快 99闲｜慢 99闲"
        tt.textAlignment = .center
        return tt
    }()

    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 144, height: 72))
        backgroundColor = UIColor.clear
        initSubViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initSubViews() {

        let vstack = VStack()
        vstack.addArrangedSubviews([titleLabel, subTitleLabel, vstack.spacer()]) {
            
        }
        addSubviewAnchor(subView: vstack, insets: UIEdgeInsets(top: 8, left: 4, bottom: 14, right: 4))

        let tap = UITapGestureRecognizer(target: self, action: #selector(calloutButtonClick))
        self.addGestureRecognizer(tap)
    }

    func updateUI(data: SpotMapMark) {
        titleLabel.text = data.price
        subTitleLabel.text = "\(data.fast)｜\(data.slow)"
    }
    
    @objc func calloutButtonClick() {
        if let calloutViewClick {
            calloutViewClick()
        }
    }

    public override func draw(_ rect: CGRect) {
        drawInContext(context: UIGraphicsGetCurrentContext()!)
        self.layer.shadowColor = UIColor.systemOrange.cgColor
        self.layer.shadowOpacity = 2.0
        self.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
    }

    func drawInContext(context : CGContext) {
        context.setLineWidth(2.0)
        context.setFillColor(UIColor.white.cgColor)
        getDrawPath(context: context)
        context.fillPath()
        context.strokePath()
    }

    func getDrawPath(context : CGContext) {
        let kArrorHeight = 10
        let rect = self.bounds
        let radius = 6.0
        let minx = rect.minX
        let midx = rect.midX
        let maxx = rect.maxX
        let miny = rect.minY
        let maxy = rect.maxY - 10

        context.move(to: CGPoint.init(x: midx + CGFloat(kArrorHeight), y: maxy))
        context.addLine(to: CGPoint.init(x: midx, y: maxy + CGFloat(kArrorHeight)))
        context.addLine(to: CGPoint.init(x: midx - CGFloat(kArrorHeight), y: maxy))

        context.addArc(tangent1End: CGPoint.init(x: minx, y: maxy), tangent2End: CGPoint.init(x: minx, y: miny), radius: CGFloat(radius))
        context.addArc(tangent1End: CGPoint.init(x: minx, y: minx), tangent2End: CGPoint.init(x: maxx, y: miny), radius: CGFloat(radius))
        context.addArc(tangent1End: CGPoint.init(x: maxx, y: miny), tangent2End: CGPoint.init(x: maxx, y: maxx), radius: CGFloat(radius))
        context.addArc(tangent1End: CGPoint.init(x: maxx, y: maxy), tangent2End: CGPoint.init(x: midx, y: maxy), radius: CGFloat(radius))
        context.closePath();
    }
}



//class CustomCalloutView: UIView {
//
//    let kArrorHeight: CGFloat = 6.0
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.backgroundColor = UIColor.white
//        self.layer.borderColor = UIColor.systemBlue.cgColor
//        self.layer.borderWidth = 1.0
//        self.layer.cornerRadius = 4.0
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func draw(_ rect: CGRect) {
//        if let context = UIGraphicsGetCurrentContext() {
//            drawInContext(context: context)
//        }
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOpacity = 1.0
//        self.layer.shadowOffset = CGSize.zero
//    }
//
//    private func drawInContext(context: CGContext) {
//        context.setLineWidth(2.0);
//        context.setFillColor(UIColor.hex(hexString: "#FFFFFF").cgColor)
//        getDrawPath(context: context)
//        context.fillPath()
//    }
//
//    private func getDrawPath(context: CGContext) {
//
//        let rrect = self.bounds
//        let radius: CGFloat = 6.0
//
//        let minx = rrect.minX
//        let midx = rrect.midX
//        let maxx = rrect.maxX
//
//        let miny = rrect.minY
//        let maxy = rrect.maxY - kArrorHeight
//
//        context.move(to: CGPoint(x: midx+kArrorHeight, y: maxy))
//        context.addLine(to: CGPoint(x: midx, y: maxy+kArrorHeight))
//        context.addLine(to: CGPoint(x: midx - kArrorHeight, y: maxy))
//        context.addArc(tangent1End: CGPoint(x: minx, y: maxy), tangent2End: CGPoint(x: minx, y: miny), radius: radius)
//        context.addArc(tangent1End: CGPoint(x: minx, y: miny), tangent2End: CGPoint(x: maxx, y: miny), radius: radius)
//        context.addArc(tangent1End: CGPoint(x: maxx, y: miny), tangent2End: CGPoint(x: maxx, y: maxy), radius: radius)
//        context.addArc(tangent1End: CGPoint(x: maxx, y: maxy), tangent2End: CGPoint(x: midx, y: maxy), radius: radius)
//        context.closePath()
//    }
//
//}
