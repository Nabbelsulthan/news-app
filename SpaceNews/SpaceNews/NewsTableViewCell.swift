//
//  NewsTableViewCell.swift
//  SpaceFlight News
//
//  Created by Nabbel on 10/02/2025.
//

import UIKit



class NewsTableViewCell: UITableViewCell {
    
    private let articleImageView = UIImageView()
    private let titleLabel = UILabel()
    private let categoryLabel = UILabel()
    private let metadataLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        articleImageView.contentMode = .scaleAspectFill
        articleImageView.layer.cornerRadius = 8
        articleImageView.clipsToBounds = true
        articleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        categoryLabel.font = UIFont.systemFont(ofSize: 14)
        categoryLabel.textColor = .gray
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        metadataLabel.font = UIFont.systemFont(ofSize: 12)
        metadataLabel.textColor = .lightGray
        metadataLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [categoryLabel, titleLabel, metadataLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(articleImageView)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            articleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            articleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            articleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            articleImageView.widthAnchor.constraint(equalToConstant: 100),
            articleImageView.heightAnchor.constraint(equalToConstant: 100),
            
            stackView.leadingAnchor.constraint(equalTo: articleImageView.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with article: Article) {
        titleLabel.text = article.title
        categoryLabel.text = article.news_site
        
        
        
        let isoFormatter = ISO8601DateFormatter()
           isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = isoFormatter.date(from: article.updated_at) else {
            print("Invalid date string: \(article.updated_at)")
               return
           }
        // date format
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "MMM dd yyyy"
           dateFormatter.timeZone = TimeZone.current // desired zone
           let formattedDateString = dateFormatter.string(from: date)

        metadataLabel.text = "\(article.authors) * \(formattedDateString)"
        
        if let imageUrl = URL(string: article.image_url.replacingOccurrences(of: "http://", with: "https://")) {
            // Load image asynchronously
            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.articleImageView.image = image
                    }
                }
            }.resume()
        }

    }
}
