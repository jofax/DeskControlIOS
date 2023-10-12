//
//  DepartmentsController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-05-08.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import EmptyStateKit

extension UIAlertController {
    
    func addDepartmentsPicker(selection: @escaping DepartmentsController.Selection) {
        var info: Department?
        let selection: DepartmentsController.Selection = selection
        let buttonSelect: UIAlertAction = UIAlertAction(title: "Select", style: .default) { action in
            selection(info)
        }
        buttonSelect.isEnabled = false
        
        let vc = DepartmentsController { new in
            info = new
            buttonSelect.isEnabled = new != nil
        }
        set(vc: vc)
        addAction(buttonSelect)
    }
}


class DepartmentsController: BaseController {

    struct UI {
        static let rowHeight = CGFloat(50)
        static let separatorColor: UIColor = UIColor.lightGray.withAlphaComponent(0.4)
    }
    
    // MARK: Properties
    
    public typealias Selection = (Department?) -> Swift.Void
    var selection: Selection?
    var viewModel = UserViewModel()
    var selectedInfo: Department?
    var departments: Departments?
    
    fileprivate lazy var tableView: UITableView = { [unowned self] in
        $0.dataSource = self
        $0.delegate = self
        $0.rowHeight = UI.rowHeight
        $0.separatorColor = UI.separatorColor
        $0.bounces = true
        $0.backgroundColor = nil
        $0.tableFooterView = UIView()
        $0.sectionIndexBackgroundColor = .clear
        $0.sectionIndexTrackingBackgroundColor = .clear
        return $0
    }(UITableView(frame: .zero, style: .plain))
    
    fileprivate lazy var indicatorView: UIActivityIndicatorView = {
        $0.color = .lightGray
        return $0
    }(UIActivityIndicatorView(style: .whiteLarge))
    
    required public init(selection: @escaping Selection) {
        self.selection = selection
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    override public func loadView() {
        view = tableView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(indicatorView)
        
        view.emptyState.format = DataState.noData.format
        view.emptyState.delegate = self
        
        //extendedLayoutIncludesOpaqueBars = true
        //edgesForExtendedLayout = .bottom
        definesPresentationContext = true
        tableView.register(DepartmentTableViewCell.self, forCellReuseIdentifier: DepartmentTableViewCell.identifier)
        
        updateInfo()
    }
    
    func updateInfo() {
        indicatorView.startAnimating()
        self.viewModel.getDepartmentLists { (object) in
            self.indicatorView.stopAnimating()
            if object is Departments {
                let _object = object as! Departments
                self.departments = _object
                
                if _object.Departments.count > 0 {
                    self.view.emptyState.hide()
                    self.tableView.reloadData()
                } else {
                    self.view.emptyState.show(DataState.noData)
                }
            } else {
                self.view.emptyState.show(DataState.noData)
            }
            
        }
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.tableHeaderView?.frame.size.height = 57
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        indicatorView.center = view.center
        preferredContentSize.height = tableView.contentSize.height
    }
 

}

extension DepartmentsController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let info = self.departments?.Departments[indexPath.row] else { return }
           selectedInfo = info
           selection?(selectedInfo)
       }
}

extension DepartmentsController: UITableViewDataSource {
       public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.departments?.Departments.count ?? 0
       }
       
       public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
           guard let info = self.departments?.Departments[indexPath.row] else { return UITableViewCell() }
           
           let cell: UITableViewCell
           
           cell = tableView.dequeueReusableCell(withIdentifier: DepartmentTableViewCell.identifier) as! DepartmentTableViewCell
           cell.textLabel?.text = info.Name
           
           if let selected = selectedInfo {
               cell.isSelected = true
           }
           
           return cell
       }
}

extension DepartmentsController: EmptyStateDelegate {
    
    func emptyState(emptyState: EmptyState, didPressButton button: UIButton) {
        updateInfo()
        view.emptyState.hide()
    }
}
