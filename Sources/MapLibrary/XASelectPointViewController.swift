//
//  XASelectPointViewController.swift
//  XAOfficialBus
//
//  Created by zhonghangxun on 2018/12/4.
//  Copyright © 2018 zhonghangxun. All rights reserved.
//

import UIKit
import CoreLocation

public enum SelectPointOption {
    case startPoint,endPoint,fetchPoint,fetchHomeOrCompany
}

/// 选择gps点 from 高德

//class XASelectPointViewController: UIViewController {
//
//    private let keyWorldView = SeleKeyWorldView()
//
//    private var quickItem: QuickItemView!
//
//    private lazy var topStack: UIStackView = {
//        let ss = UIStackView(arrangedSubviews: [keyWorldView])
//        ss.axis = .vertical
//        ss.distribution = .equalSpacing
//        ss.heightAnchor.constraint(equalToConstant: 160).isActive = true
//        return ss
//    }()
//
//    private lazy var uiTableView: UITableView = {
//        var style: UITableView.Style = .plain
//        if #available(iOS 13.0, *) {
//            style = .insetGrouped
//        }
//        let tt = UITableView(frame: CGRect.zero, style: style)
//        tt.backgroundColor = UIColor.groupTableViewBackground
//        tt.delegate = self
//        tt.dataSource = self
//        tt.keyboardDismissMode = .onDrag
//        return tt
//    }()
//
//    private var keyWordIsEmpty = true
//
//    private var pageType:SelectPointOption!
//
//    private var callBackGPSPoint:((_ gps: GPSPoint)->Void)?
//
//    private var search:PumkinKeyWordsSearch!
//
//    private var dataArray:[GPSPoint] = []{
//        didSet{
//            uiTableView.reloadData()
//        }
//    }
//    private var dataCache:[GPSPoint] = []
//
//    public init(type:SelectPointOption = .fetchPoint,callBackPoint:((_ gps: GPSPoint)->Void)? = nil) {
//        self.callBackGPSPoint = callBackPoint
//        self.pageType = type
//        self.quickItem = QuickItemView(flag: pageType == .fetchHomeOrCompany ? false : true)
//        super.init(nibName: nil, bundle: nil)
//        self.topStack.addArrangedSubview(quickItem)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override public func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor.groupTableViewBackground
//        search = PumkinKeyWordsSearch(cityName: ConfigManager.share().getCityNamePinyin(), offset: 30)
//
//        self.view.addSubview(topStack)
//
//        topStack.translatesAutoresizingMaskIntoConstraints = false
//        topStack.topAnchor.constraint(equalTo: self.layoutGuide.topAnchor, constant: 12).isActive = true
//        topStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0).isActive = true
//        topStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true
//
//        self.view.addSubview(uiTableView)
//
//        uiTableView.translatesAutoresizingMaskIntoConstraints = false
//        uiTableView.bottomAnchor.constraint(equalTo: self.layoutGuide.bottomAnchor).isActive = true
//        uiTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        uiTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
//        uiTableView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 8).isActive = true
//
//        switch pageType {
//        case .startPoint:
//            navigationItem.title = "选择起点"
//        case .endPoint:
//            navigationItem.title = "选择目的地"
//        default:
//            navigationItem.title = "地图选点"
//        }
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: wly_image(named: "leftArrow"), style: .done, target: self, action: #selector(doneAction))
//        dataCache = UserDefaults.getpointCache()
//        dataArray = dataCache
//
//        keyWorldView.keyWorld.subscribe(onNext: { (key) in
//            self.keyWordsAction(key: key)
//        }).disposed(by: bag)
//
//        quickItem.quickItemAction.subscribe (onNext: { (option) in
//            self.dealQuickItem(option: option)
//        }).disposed(by: bag)
//    }
//    @objc private func doneAction() {
//        if pageType == SelectPointOption.fetchHomeOrCompany {
//            self.navigationController?.popViewController(animated: true)
//        }else{
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
//    /// 处理 快捷菜单
//    private func dealQuickItem(option: QuickItemView.QuickItemOption) {
//        switch option {
//        case .MY_LOCATION:
//            guard let point = UserDefaults.getMyLocation() else { return PumpkinHUD.showMessage("当前位置获取失败") }
//            UserDefaults.setPointCache(point: point)
//            goWherePage(point: point)
//        case .MAP_POINT:
//            let mapVc = XASelectPointMapViewController(pageType: self.pageType) { (point) in
//                if let callback = self.callBackGPSPoint {
//                    callback(point)
//                }
//            }
//            mapVc.title = self.title
//            self.navigationController?.pushViewController(mapVc, animated: true)
//        case .HOME:
//            guard let point = UserDefaults.getMyHome() else {
//                setHomeOrConpany(type: option)
//                return
//            }
//            UserDefaults.setPointCache(point: point)
//            goWherePage(point: point)
//        case .CONPANY:
//            guard let point = UserDefaults.getMyConpany() else {
//                // 设置我的公司
//                setHomeOrConpany(type: option)
//                return
//            }
//            UserDefaults.setPointCache(point: point)
//            goWherePage(point: point)
//        default:
//            break
//        }
//    }
//
//    private func setHomeOrConpany(type: QuickItemView.QuickItemOption) {
//        // 设置 家
//        let vc = XASelectPointViewController(type: .fetchHomeOrCompany) { [weak self] (point) in
//            let p_str = pumpkinEncoder(model: point)
//            if type == .HOME {
//                UserDefaults.setMyHome(location: p_str)
//                PumpkinHUD.showMessage("家设置成功")
//            }
//            if type == .CONPANY {
//                UserDefaults.setMyCompany(location: p_str)
//                PumpkinHUD.showMessage("公司设置成功")
//            }
//            /// 更新页面
//            self?.quickItem.update(type: type)
//
//        }
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    private func goWherePage(point:GPSPoint) {
//        if pageType == .fetchPoint {
//            if let callBackGPSPoint = callBackGPSPoint {
//                callBackGPSPoint(point)
//            }
////            self.dismiss(animated: true, completion: nil)
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
////            self.dismiss(animated: true, completion: nil)
//        }
//        doneAction()
//    }
//
//    private func keyWordsAction(key: String) {
//        if key == "" {
//            /// 显示缓存记录
//            self.keyWordIsEmpty = true
//            dataArray = dataCache
//        }else{
//            self.keyWordIsEmpty = false
//            /// 关键字搜索 发起搜索
//            dataArray = []
//            search.begainPoiSearch(keyword: key) { [weak self](points) in
//                self?.dataArray = points
//            }
//        }
//    }
//
//    func deleteAllPointCache() {
//
//        if self.dataArray.isEmpty {
//            return
//        }
//
//        let alert = UIAlertController(title: "提示", message: "清除所有历史缓存", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
//        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (alert) in
//            UserDefaults.deleteAllCacheGpsPoint()
//            self.dataArray = []
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }
//}

//extension XASelectPointViewController: UITableViewDelegate, UITableViewDataSource {
//    public func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataArray.count
//    }
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        var cell = uiTableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
//        if cell == nil {
//            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UITableViewCell")
//        }
//        let model = dataArray[indexPath.row]
//        cell?.textLabel?.text = model.name
//        cell?.detailTextLabel?.text = model.address
//        cell?.imageView?.image = wly_image(named: "POIPoint")
//        return cell!
//    }
//
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        /// 选择某一行
//        let point = dataArray[indexPath.row]
//        JJJReGeocodeSearch.share().begainGeoCodeSearch(location: CLLocationCoordinate2D(latitude: Double(point.latitude) ?? 0.0, longitude: Double(point.longitude) ?? 0.0)) {[weak self] gps in
//            UserDefaults.setPointCache(point: gps)
//            self?.goWherePage(point: gps)
//        }
//
//
//    }
//
//    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if keyWordIsEmpty {
//            return 44
//        }
//        return 0
//    }
//
//    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if keyWordIsEmpty {
//            let view = HistoryView.view()
//            view.deleteBlock = {[weak self] in
//                self?.deleteAllPointCache()
//            }
//            return view
//        }
//        return nil
//    }
//
//    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.1
//    }
//
//    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return nil
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        /// 编辑模式下的操作
//        let model = dataArray[indexPath.row]
//        UserDefaults.deletePoint(sid: model.uid)
//        dataCache = UserDefaults.getpointCache()
//        dataArray = dataCache
//    }
//
//    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        return "删除"
//    }
//}

/// 选择关键字的 视图
//class SeleKeyWorldView: UIView {
//
//    private lazy var textfiled: UITextField = {
//        let tt = UITextField(frame: CGRect.zero)
//        tt.placeholder = "请输入要搜索的关键字"
//        return tt
//    }()
//
////    fileprivate let keyWorldSubject = PublishSubject<String>()
//    // 对外，只提供了一个仅供订阅的Observable属性todo
//    var keyWorld: Observable<String>!
////    {
////        return keyWorldSubject.asObservable()
////    }
//
//    init() {
//        super.init(frame: CGRect.zero)
//        initUI()
//        loadData()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func loadData() {
//
//        keyWorld = textfiled.rx.text.orEmpty
////            .filter { $0.count > 2 }
//            .throttle(0.5, scheduler: MainScheduler.instance)
//    }
//
//    private func initUI() {
//        self.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        self.backgroundColor = UIColor.white
//        self.layer.cornerRadius = 10.0
//
//        self.addSubview(textfiled)
//        textfiled.jjjAnchorPutIn(faView: self, insets: UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
//    }
//}

//class QuickItemView: UIView {
//
//    enum QuickItemOption {
//        case MY_LOCATION
//        case MAP_POINT
//        case HOME
//        case CONPANY
//    }
//
//    private let bag = DisposeBag()
//
//    fileprivate let quickItemSubject = PublishSubject<QuickItemOption>()
//    // 对外，只提供了一个仅供订阅的Observable属性todo
//    var quickItemAction: Observable<QuickItemOption> {
//        return quickItemSubject.asObservable()
//    }
//
//    private var showCompanyOrHome = true
//
//    var homeItem: QuickItem!
//    var conmpanyItem: QuickItem!
//
//    init(flag: Bool) {
//        self.showCompanyOrHome = flag
//        super.init(frame: CGRect.zero)
//        self.layer.cornerRadius = 10.0
//        self.backgroundColor = UIColor.white
//        self.heightAnchor.constraint(equalToConstant: 88).isActive = true
//
//        let mylocation = QuickItem(title: "我的位置", icon: "POIPoint")
//        mylocation.itemAction.subscribe(onNext: { (_) in
//            self.quickItemSubject.onNext(.MY_LOCATION)
//        }).disposed(by: bag)
//
//        let mapPoint = QuickItem(title: "地图选点", icon: "POIPoint")
//        mapPoint.itemAction.subscribe(onNext: { (_) in
//            self.quickItemSubject.onNext(.MAP_POINT)
//        }).disposed(by: bag)
//
//        var stackSubView: [UIView] = [mylocation, createVerticalBar(), mapPoint]
//        if showCompanyOrHome {
//            var myhomeDes = "未设置"
//            if let _ = UserDefaults.getMyHome() {
//                myhomeDes = ""
//            }
//
//            homeItem = QuickItem(title: "家", icon: "POIPoint", description: myhomeDes)
//            homeItem.itemAction.subscribe(onNext: { (_) in
//                self.quickItemSubject.onNext(.HOME)
//            }).disposed(by: bag)
//
//            var mycompanyDes = "未设置"
//            if let _ = UserDefaults.getMyConpany() {
//                mycompanyDes = ""
//            }
//
//            conmpanyItem = QuickItem(title: "公司", icon: "POIPoint", description: mycompanyDes)
//            conmpanyItem.itemAction.subscribe(onNext: { (_) in
//                self.quickItemSubject.onNext(.CONPANY)
//            }).disposed(by: bag)
//            stackSubView.append(contentsOf: [createVerticalBar(), homeItem, createVerticalBar(), conmpanyItem])
//        }
//        let stack = UIStackView(arrangedSubviews: stackSubView)
//        stack.axis = .horizontal
//        stack.distribution = .equalCentering
//        stack.alignment = .center
//        self.addSubview(stack)
//
//        stack.jjjAnchorPutIn(faView: self, insets: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func update(type: QuickItemOption) {
//        if type == .HOME {
//            homeItem.updateDescription()
//        }
//        if type == .CONPANY {
//            conmpanyItem.updateDescription()
//        }
//    }
//
//    private func createVerticalBar() -> UIView {
//        let v = UIView(frame: CGRect.zero)
//        v.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        v.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
//        v.backgroundColor = UIColor.groupTableViewBackground
//        return v
//    }
//}

//class QuickItem: UIView {
//    
//    private lazy var action: UIButton = {
//        let bb = UIButton(frame: CGRect.zero)
//        bb.setTitle("我的位置", for: .normal)
//        bb.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
//        bb.setTitleColor(UIColor.black, for: .normal)
//        bb.setImage(wly_image(named: "POIPoint"), for: .normal)
//        bb.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        return bb
//    }()
//    
//    private lazy var des: UILabel = {
//        let ll = UILabel(frame: CGRect.zero)
//        ll.text = "未设置"
//        ll.textColor = UIColor.themeColor()
//        ll.textAlignment = .center
//        ll.font = UIFont.systemFont(ofSize: 12.0)
//        ll.heightAnchor.constraint(equalToConstant: 20).isActive = true
//        return ll
//    }()
//    
//    private lazy var stack: UIStackView = {
//        let ss = UIStackView(arrangedSubviews: [action, des])
//        ss.axis = .vertical
//        ss.distribution = .equalSpacing
//        ss.alignment = .center
//        return ss
//    }()
//    
//    private let bag = DisposeBag()
//    
//    fileprivate let itemSubject = PublishSubject<NSInteger>()
//    // 对外，只提供了一个仅供订阅的Observable属性todo
//    var itemAction: Observable<NSInteger> {
//        return itemSubject.asObservable()
//    }
//    
//    init(title: String, icon: String, description: String = "") {
//        super.init(frame: CGRect.zero)
//        action.setTitle(title, for: .normal)
//        action.setImage(wly_image(named: icon), for: .normal)
//        des.text = description
//        self.addSubview(stack)
//        stack.jjjAnchorPutIn(faView: self)
//        self.widthAnchor.constraint(equalToConstant: 88).isActive = true
//        action.rx.tap.subscribe(onNext: { (_) in
//            self.itemSubject.onNext(1)
//        }).disposed(by: bag)
//    }
//    
//    func updateDescription() {
//        self.des.text = ""
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        action.layoutButton(style: .top, imageTitleSpace: 10.0)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//}
