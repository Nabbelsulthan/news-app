//
//  WebViewController.swift
//  SpaceNews
//
//  Created by Nabbel on 11/02/2025.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    
    @IBOutlet weak var webView: WKWebView!
    
    
    var urlString = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backtapped()
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            print("Invalid URL string: \(urlString)")
        }
    }
    
    
    func backtapped() {
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)

        backBtn.widthAnchor.constraint(equalToConstant: 35).isActive = true
        backBtn.heightAnchor.constraint(equalToConstant: 35).isActive = true

        let barButtonItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = barButtonItem
    }
    
    @objc func back() {
        
        self.navigationController?.popViewController(animated: true)

    }

}
