//
//  NewsViewController.swift
//  SpaceFlight News
//
//  Created by Nabbel on 11/02/2025.
//

import UIKit
import SwiftSoup

class NewsViewController: UIViewController {
    
    var article: Article?
    var articles: [Article] = []
    var currentIndex: Int = 0
  
    let darkerSkyBlue = UIColor(red: 11/255.0, green: 168/255.0, blue: 230/255.0, alpha: 1.0)
    
    @IBOutlet weak var imgView: UIImageView!
    
    
    @IBOutlet weak var summaryView: UIView!
    
    @IBOutlet weak var categoryLbl: UILabel!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    
    @IBOutlet weak var timeLbl: UILabel!
    
    
    @IBOutlet weak var summaryText: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        backtapped()
        imgView.layer.cornerRadius = 20
        imgView.clipsToBounds = true
        
        summaryView.layer.cornerRadius = 20
        summaryView.clipsToBounds = true
        
        categoryLbl.layer.cornerRadius = 15
        categoryLbl.clipsToBounds = true
        
        titleLbl.textColor = .white
        
        timeLbl.textColor = .white
        
        summaryText.font = UIFont(name: "Helvetica Neue", size: 16)
        
        summaryText.isEditable = false
        
        updateUI()
        
        setupGestures()
        
        let saveBtn = UIButton(type: .custom)
        saveBtn.setImage(UIImage(named: "save"), for: .normal)
        //saveBtn.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)

        // Set constraints for width and height
        saveBtn.widthAnchor.constraint(equalToConstant: 35).isActive = true
        saveBtn.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        
        let webBtn = UIButton(type: .custom)
        webBtn.setImage(UIImage(named: "globe"), for: .normal)
        webBtn.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)

        // Set constraints for width and height
        webBtn.widthAnchor.constraint(equalToConstant: 35).isActive = true
        webBtn.heightAnchor.constraint(equalToConstant: 35).isActive = true

        let webBarButtonItem = UIBarButtonItem(customView: webBtn)
        let saveBarButtonItem = UIBarButtonItem(customView: saveBtn)
        self.navigationItem.rightBarButtonItems = [saveBarButtonItem , webBarButtonItem]
        
    }
//MARK: - UI Updates
    
    func updateUI() {
        guard let article = article else { return }
        
        Task {
            await fetchArticleContent(from: article.url)
        }
        titleLbl.text = article.title
        categoryLbl.text = article.news_site
        print(article.url)
        print(article.id)
        categoryLbl.textColor = .white
        categoryLbl.backgroundColor = darkerSkyBlue
        print(article)
    
        if let imageUrl = URL(string: article.image_url.replacingOccurrences(of: "http://", with: "https://")) {
            // Load image asynchronously
            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imgView.image = image
                    }
                }
            }.resume()
        }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let updatedDate = isoFormatter.date(from: article.updated_at) else {
            print("Invalid date string: \(article.updated_at)")
            return
        }
        let currentDate = Date()
        let diffComponents = Calendar.current.dateComponents([.hour], from: updatedDate, to: currentDate)

        if let hoursSinceUpdate = diffComponents.hour {
            print("The article was updated \(hoursSinceUpdate) hours ago.")
           // timeLbl.text = "\(article.authors) • \(hoursSinceUpdate) hours ago"
            timeLbl.text = "Trending • \(hoursSinceUpdate) hours ago"
        } else {
            print("Could not calculate the time difference.")
        }
    }
      
    
    @objc func imageTapped() {
        guard let article = article else { return }
        
   //     guard let url = URL(string: "https://api.spaceflightnewsapi.net/v4/articles/\(article.id)") else {return}
        
        print(article.url)
        guard let url = URL(string: article.url) else {return}
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let webView = storyBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        print("loading id  : \(url)")
        webView.urlString = url.absoluteString
        navigationController?.pushViewController(webView, animated: true)
    }
    
    @objc func saveTapped() {
        
        
    }
    
  
    func fetchArticleContent(from urlString: String) async {
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let htmlContent = String(data: data, encoding: .utf8) {
                await parseHTML(htmlContent)
            }
        } catch {
            print("Error fetching article content: \(error)")
        }
    }

    func parseHTML(_ html: String) async {
        do {
            let document = try SwiftSoup.parse(html)
            // Extract the title
            if let title = try document.select("h1").first()?.text() {
                await MainActor.run {
                    self.titleLbl.text = title
                }
            }
            // Extract the body content
            if let bodyElement = try document.select("div.entry-content").first() {
                let bodyHTML = try bodyElement.html()
                await displayHTMLContent(bodyHTML)
            }
        } catch {
            print("Error parsing HTML: \(error)")
        }
    }

    
    func displayHTMLContent(_ html: String) async {
      
        guard let data = html.data(using: .utf8) else { return }
        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
            )
            await MainActor.run {
                    self.summaryText.attributedText = attributedString
            }
        } catch {
            print("Error displaying HTML content: \(error)")
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
    
    //MARK: - Gestures setup
    
    private func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            showNextArticle()
        } else if gesture.direction == .right {
            showPreviousArticle()
        }
    }
    
    
    func animateTransition(toNext next: Bool) {
        // Determine the direction of the animation
        let direction: CGFloat = next ? 1 : -1
        
        // Create a snapshot of the current view
        guard let currentViewSnapshot = view.snapshotView(afterScreenUpdates: true) else { return }
        currentViewSnapshot.frame = view.frame
        view.addSubview(currentViewSnapshot)
        
        // Update the article index
        if next {
            currentIndex += 1
        } else {
            currentIndex -= 1
        }
        article = articles[currentIndex]
        updateUI()
        
        // Position the new view off-screen
        view.transform = CGAffineTransform(translationX: direction * view.frame.width, y: 0)
        
        // Animate the transition
        UIView.animate(withDuration: 0.5, animations: {
            self.view.transform = .identity
            currentViewSnapshot.transform = CGAffineTransform(translationX: -direction * self.view.frame.width, y: 0)
        }) { _ in
            currentViewSnapshot.removeFromSuperview()
        }
    }
    private func showNextArticle() {
        guard currentIndex < articles.count - 1 else { return }
        animateTransition(toNext: true)
    }

    private func showPreviousArticle() {
        guard currentIndex > 0 else { return }
        animateTransition(toNext: false)
    }

    @objc func back() {
        
        self.navigationController?.popViewController(animated: true)

    }
}
