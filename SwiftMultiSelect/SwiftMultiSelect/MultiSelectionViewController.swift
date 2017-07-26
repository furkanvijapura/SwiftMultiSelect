//
//  MultiSelectionViewController.swift
//  SwiftMultiSelect
//
//  Created by Luca Becchetti on 26/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Foundation

/// Class that represent the selection view
class MultiSelecetionViewController: UIViewController,UIGestureRecognizerDelegate {
    
    /// Screen total with
    public var totalWidth:CGFloat{
        get{
            return UIScreen.main.bounds.width
        }
    }
    
    /// Screen total height
    public var totalHeight:CGFloat{
        get{
            return UIScreen.main.bounds.height
        }
    }
    
    /// Array of selected items
    open var selectedItems : [SwiftMultiSelectItem] = [SwiftMultiSelectItem]()
    
    /// Lazy view that represent a selection scrollview
    open fileprivate(set) lazy var selectionScrollView: UICollectionView = {
        
        //Build layout
        let layout                      = UICollectionViewFlowLayout()
        layout.sectionInset             = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection          = UICollectionViewScrollDirection.horizontal
        layout.minimumInteritemSpacing  = 0
        layout.minimumLineSpacing       = 0
        
        //Build collectin view
        let selected                = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        selected.backgroundColor    = .white
        selected.isHidden           = (SwiftMultiSelect.initialSelected.count <= 0)
        return selected
        
    }()
    
    /// Lazy view that represent a selection scrollview
    open fileprivate(set) lazy var separator: UIView = {
        
        //Build layout
        let sep                 = UIView()
        sep.autoresizingMask    = [.flexibleWidth]
        sep.backgroundColor     = Config.separatorColor
        return sep
        
    }()
    
    /// Lazy var for table view
    open fileprivate(set) lazy var tableView: UITableView = {
        
        let tableView:UITableView = UITableView()
        return tableView
        
    }()
    
    /// Lazy var for global stackview container
    open fileprivate(set) lazy var stackView: UIStackView = {
        
        let stackView           = UIStackView(arrangedSubviews: [self.selectionScrollView,self.tableView])
        stackView.axis          = .vertical
        stackView.distribution  = .fill
        stackView.alignment     = .fill
        stackView.spacing       = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
        
    }()
    
    /// Calculate the nav bar height if present
    var navBarHeight:CGFloat{
        get{
            if (self.navigationController != nil) {
                return self.navigationController!.navigationBar.frame.size.height + (UIApplication.shared.isStatusBarHidden ? 0 : 20)
            }else{
                return 0
            }
        }
    }
    
    var lefButtonBar : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(MultiSelecetionViewController.dismissSelector))
    
    
    /// Function to build a views and set constraint
    func createViewsAndSetConstraints(){

        //Add stack view to current view
        view.addSubview(stackView)
        
        selectionScrollView.addSubview(separator)
        separator.frame = CGRect(x: 0.0, y: Config.selectionHeight-Config.separatorHeight, width: Double(self.view.frame.size.width), height: Config.separatorHeight)
        separator.layer.zPosition = CGFloat(separator.subviews.count+1)
        
        //Register tableview delegate
        tableView.delegate      =  self
        tableView.dataSource    =  self
        //Register cell class
        tableView.register(CustomTableCell.classForCoder(), forCellReuseIdentifier: "cell")
        
        //Register collectionvie delegate
        selectionScrollView.delegate    =   self
        selectionScrollView.dataSource  =   self
        //Register cell class
        selectionScrollView.register(CustomCollectionCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        
        //Prevent adding top margin to collectionviewcell
        self.automaticallyAdjustsScrollViewInsets = false
        
        //autolayout the stack view and elements
        let viewsDictionary = [
            "stackView" :   stackView,
            "selected"  :   self.selectionScrollView
            ] as [String : Any]
        
        //constraint for stackview
        let stackView_H = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[stackView]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary
        )
        //constraint for stackview
        let stackView_V = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-\(navBarHeight)-[stackView]-0-|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil,
            views: viewsDictionary
        )
        //constraint for scrollview
        let selected_V  = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[selected(\(Config.selectionHeight))]",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil,
            views: viewsDictionary
        )
        //constraint for scrollview
        let selected_H  = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[selected]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary
        )
        
        //Add all constraints to view
        view.addConstraints(stackView_H)
        view.addConstraints(stackView_V)
        view.addConstraints(selected_V)
        view.addConstraints(selected_H)
    }
    
    
    /// Toggle de selection view
    ///
    /// - Parameter sender:
    func toggleSelectionScrollView(show:Bool) {
        UIView.animate(withDuration: 0.2) {
            self.selectionScrollView.isHidden = !show
        }
    }
    
    @objc func dismissSelector(){
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = Config.viewTitle
        
        self.navigationItem.leftBarButtonItem = lefButtonBar
        
        self.view.backgroundColor = .white
        
        createViewsAndSetConstraints()
        
        self.tableView.reloadData()
        
        if(SwiftMultiSelect.initialSelected.count>0){
            self.selectionScrollView.reloadData()
        }
        
    }
}
