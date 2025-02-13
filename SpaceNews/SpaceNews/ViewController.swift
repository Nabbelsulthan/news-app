//
//  ViewController.swift
//  SpaceFlight News
//
//  Created by Nabbel on 10/02/2025.
//

import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
  
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let categories = ["All", "Politic", "Sport", "Education", "Games"]
    private let categoryScrollView = UIScrollView()
    private let categoryStackView = UIStackView()
    private let viewModel = ViewModel()
    
    private let refreshControl = UIRefreshControl()
    
    private let lightBlue = UIColor(red: 11/255.0, green: 168/255.0, blue: 230/255.0, alpha: 1.0)
    private let unselectedColor = UIColor.lightGray
    
    private var filteredArticles: [Article] = []

    private var search : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        view.backgroundColor = .white

        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)

        // Set constraints for width and height
        backBtn.widthAnchor.constraint(equalToConstant: 35).isActive = true
        backBtn.heightAnchor.constraint(equalToConstant: 35).isActive = true

        let barButtonItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        view.addSubview(tableView)
        view.addSubview(searchBar)
        view.addSubview(categoryScrollView)
        categoryScrollView.addSubview(categoryStackView)

        setupHeader()
        setupSearchBar()
        setupCategoryScrollView()
        setupTableView()
  
        
        refreshControl.tintColor = .gray
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }

        
        // Fetch initial articles
        viewModel.onDataUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.fetchArticles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

        
    @objc func back() {
        print("Back Pressed")
    }
    
    @objc private func refreshData() {
        viewModel.fetchArticles()
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }
    
    
    //MARK: - Ui Setups & Constraints

    private func setupHeader() {
        let headerLabel = UILabel()
        headerLabel.text = "Discover"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 32)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "News from all around the world"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = .gray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [headerLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
    }
        
    private func setupSearchBar() {
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .prominent

        // Set up constraints for searchBar
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90)
        ])
    }
    

    private func setupCategoryScrollView() {
        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
           categoryScrollView.showsHorizontalScrollIndicator = false
           view.addSubview(categoryScrollView)
           
           NSLayoutConstraint.activate([
               categoryScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               categoryScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               categoryScrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
               categoryScrollView.heightAnchor.constraint(equalToConstant: 40)
           ])
           
           categoryStackView.axis = .horizontal
           categoryStackView.spacing = 10 // Adjust spacing as needed
           categoryStackView.translatesAutoresizingMaskIntoConstraints = false
           categoryScrollView.addSubview(categoryStackView)
           
           NSLayoutConstraint.activate([
               categoryStackView.topAnchor.constraint(equalTo: categoryScrollView.topAnchor),
               categoryStackView.leadingAnchor.constraint(equalTo: categoryScrollView.leadingAnchor),
               categoryStackView.trailingAnchor.constraint(equalTo: categoryScrollView.trailingAnchor),
               categoryStackView.bottomAnchor.constraint(equalTo: categoryScrollView.bottomAnchor),
               categoryStackView.heightAnchor.constraint(equalTo: categoryScrollView.heightAnchor)
           ])
           
           let labelHeight: CGFloat = 40
           for category in categories {
               let label = UILabel()
               label.text = category
               label.textAlignment = .center
               label.font = UIFont.systemFont(ofSize: 16)
               label.translatesAutoresizingMaskIntoConstraints = false
    
               if category == "All" {
                   label.backgroundColor = lightBlue
               } else {
                   label.backgroundColor = unselectedColor
               }
               
               label.isUserInteractionEnabled = true
               categoryStackView.addArrangedSubview(label)
               
               label.widthAnchor.constraint(equalToConstant: 100).isActive = true
               label.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true
               
               label.layer.cornerRadius = labelHeight / 2
               label.clipsToBounds = true

               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
               label.addGestureRecognizer(tapGesture)
           }
       }
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedLabel = sender.view as? UILabel else { return }
        
        for case let label as UILabel in categoryStackView.arrangedSubviews {
            label.backgroundColor = unselectedColor
        }
        
        tappedLabel.backgroundColor = lightBlue
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: "NewsTableViewCell")
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 10), // Constraint fixed
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    


    
    // MARK: - TableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if search {
            return filteredArticles.count
        } else {
             return viewModel.articles.count
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
      
        if search {
            let filterArticle = filteredArticles[indexPath.row]
            cell.configure(with: filterArticle)
        } else {
            let article = viewModel.articles[indexPath.row]
            cell.configure(with: article)
        }
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(identifier: "NewsViewController") as! NewsViewController
        detailVC.article = viewModel.articles[indexPath.row]
        detailVC.articles = viewModel.articles
        detailVC.currentIndex = indexPath.row
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if position > contentHeight - frameHeight * 2 {
            viewModel.fetchArticles()
        }
    }
    
    // MARK: - Search Bar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search = true
        if searchText.isEmpty {
            filteredArticles = viewModel.articles
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                let filtered = self.viewModel.articles.filter { article in
                    article.title.lowercased().contains(searchText.lowercased())
                }
                DispatchQueue.main.async {
                    self.filteredArticles = filtered
                    self.tableView.reloadData()
                }
            }
        }
    }

    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search = false
        searchBar.text = nil
        filteredArticles = viewModel.articles
        tableView.reloadData()
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder() 
    }

}




