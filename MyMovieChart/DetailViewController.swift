//
//  DetailViewController.swift
//  MyMovieChart
//
//  Created by 김태현 on 2021/11/21.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    @IBOutlet var wv: WKWebView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    var mvo: MovieVO!
    
    override func viewDidLoad() {
        self.wv.navigationDelegate = self
        
        NSLog("LinkURL = \(self.mvo.detail!), title = \(String(describing: self.mvo.title))")
        
        self.navigationItem.title = self.mvo.title
        
        if let url = self.mvo.detail {
            if let urlObj = URL(string: url) {
                let req = URLRequest(url: urlObj)
                self.wv.load(req)
            } else {
                self.alert("잘못된 URL") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        } else {
            self.alert("파라매터 누락") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// Mark: - WKNavigationDelegate 프로토콜
extension DetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.spinner.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.spinner.stopAnimating()
    }
    
    // 지하철, 엘리베이터에서 종종 네트워크 끊어짐
    // 영원히 로딩 아이콘 돌아가지 않게 하기 위해
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating()
        
        self.alert("상세 페이지 읽기 실패") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating()
        self.alert("상세페이지 읽기 실패") {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - 심플한 경고창 함수 정의
extension DetailViewController {
    func alert(_ message: String, onClick: (() -> ())?) {
        let controller = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
                onClick?()
        })
        
        DispatchQueue.main.async {
            self.present(controller, animated: false, completion: nil)
        }
    }
}
