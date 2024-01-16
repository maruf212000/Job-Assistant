//
//  JAChatViewController.swift
//  Job Assistant
//
//  Created by Maruf Memon on 16/01/24.
//

import UIKit

import UIKit
import SwiftUI

@available(iOS 13.0, *)
@objc class JAChatViewController : UIViewController {

    var chatView : JAChatView?
    var hostingController : UIHostingController<JAChatView>?
    var scrollView : UIScrollView?
    var height: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Job Assistant"
        self.navigationController?.title = ""
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(didPressClearBtn))
        
        let chatView = JAChatView()
        let margins = view.layoutMarginsGuide
        hostingController = UIHostingController(rootView: chatView)
        
        let contentView = hostingController!.view!;
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: margins.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        self.chatView = chatView
    }
    
    @objc func didPressClearBtn() {
        
    }
}
