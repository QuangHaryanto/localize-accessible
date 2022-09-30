//
//  ViewController.swift
//  myLocalSwiftApp
//
//  Created by Haryanto Salim on 21/09/22.
//

import UIKit

struct Quote: Codable {
    let id, author, en: String
    
    static var dummyJSON: String = {
        return
"""
[
  {
    "id": "5a6ce86e2af929789500e7e4",
    "author": "Edsger W. Dijkstra",
    "en": "Computer Science is no more about computers than astronomy is about telescopes."
  },
  {
    "id": "5a6ce86e2af929789500e7d7",
    "author": "Edsger W. Dijkstra",
    "en": "Simplicity is prerequisite for reliability."
  },
  {
    "id": "5a6ce86d2af929789500e7ca",
    "author": "Edsger W. Dijkstra",
    "en": "The computing scientist’s main challenge is not to get confused by the complexities of his own making."
  },
  {
    "id": "5a6ce86f2af929789500e7f3",
    "author": "Edsger W. Dijkstra",
    "en": "If debugging is the process of removing software bugs, then programming must be the process of putting them in."
  },
  {
    "id": "5a6ce86e2af929789500e7d9",
    "author": "Edsger W. Dijkstra",
    "en": "A program is like a poem: you cannot write a poem without writing it. Yet people talk about programming as if it were a production process and measure „programmer productivity“ in terms of „number of lines of code produced“. In so doing they book that number on the wrong side of the ledger: We should always refer to „the number of lines of code spent“."
  },
  {
    "id": "5a6ce86f2af929789500e7f8",
    "author": "Tony Hoare",
    "en": "There are two ways of constructing a software design: One way is to make it so simple that there are obviously no deficiencies, and the other way is to make it so complicated that there are no obvious deficiencies. The first method is far more difficult."
  },
  {
    "id": "5a6ce86f2af929789500e807",
    "author": "Jeff Hammerbacher",
    "en": "The best minds of my generation are thinking about how to make people click ads."
  },
  {
    "id": "5a6ce86f2af929789500e7f9",
    "author": "Edsger W. Dijkstra",
    "en": "The tools we use have a profound and devious influence on our thinking habits, and therefore on our thinking abilities."
  }
]
"""
    }()
}

final class NetworkService {
    private let urlSession: URLSession
    private var dataTask: URLSessionDataTask?
    
    init(sessionConfiguration: URLSessionConfiguration) {
        self.urlSession = URLSession(configuration: sessionConfiguration)
    }
    
    func request(url: String, query: String?, httpMethod: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        dataTask?.cancel()
        
        guard var urlComponents = URLComponents(string: url) else {
            return
        }
        
        if let urlQuery = query {
            urlComponents.query = urlQuery
        }
        
        guard let validUrl = urlComponents.url else {
            return
        }
        
        var urlRequest = URLRequest(url: validUrl)
        urlRequest.httpMethod = httpMethod
        
        dataTask = urlSession.dataTask(with: urlRequest, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
            do {
                self?.dataTask = nil
            }
            
            guard error == nil else {
                let error = NSError(domain: "invalid endpoint", code: 900013, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            if let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(.success(data))
                return
            } else {
                let error = NSError(domain: "invalid response", code: 900014, userInfo: nil)
                completion(.failure(error))
            }
        })
        
        dataTask?.resume()
    }
    
    func parse<T: Decodable>(model: T.Type, json: Data) -> [T]{
        let decoder = JSONDecoder()
        
        if let jsonItems = try? decoder.decode([T].self, from: json) {
            return jsonItems
        }
        return []
    }
}

class QuoteViewController: UIViewController {
    
    var items: [Quote] = []
    var allItems: [Quote] = []
    
    var xnetworkService = NetworkService(sessionConfiguration: URLSessionConfiguration.default)
    
    lazy var searchBar:UISearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadDataDummy()
    }
    
    func setupView(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = true;
        navigationItem.title = "Quotes"
        
        setupSearchBar()
        
        //setup stackview
        self.view.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        // autolayout constraint
        let layoutGuide: UILayoutGuide = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
        ])
    }
    
    func loadDataFromNetwork(){
        xnetworkService.request(url: "https://programming-quotes-api.herokuapp.com/Quotes?count=16", query: nil, httpMethod: "GET") { [self] response in
            switch response {
            case .success(let data):
                DispatchQueue.main.async { [self] in
                    self.items = self.xnetworkService.parse(model: Quote.self, json: data)
                    self.allItems = items
                    self.quotesTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func loadDataDummy(){
        DispatchQueue.main.async { [self] in
            guard let data = Quote.dummyJSON.data(using: .utf8) else { return }
            
            self.items = self.xnetworkService.parse(model: Quote.self, json: data)
            self.allItems = items
            self.quotesTable.reloadData()
        }
    }
    
    func setupSearchBar(){
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = "Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = true
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        navigationItem.preferredSearchBarPlacement = .inline
    }
    
    @objc func endEditing(){
        searchBar.resignFirstResponder()
    }
    
    lazy var mainStackView: UIStackView = {
        //Stack View
        var stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 8.0
        
        stackView.addArrangedSubview(quotesTable)
        quotesTable.translatesAutoresizingMaskIntoConstraints = false
        quotesTable.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        
        stackView.addArrangedSubview(authorsButton)
        authorsButton.translatesAutoresizingMaskIntoConstraints = false
        authorsButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        
        stackView.addArrangedSubview(activityButton)
        activityButton.translatesAutoresizingMaskIntoConstraints = false
        activityButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        
        return stackView
    }()
    
    lazy var quotesTable: UITableView = {
        let myTable = UITableView()
        myTable.dataSource = self
        myTable.delegate = self
        myTable.register(MyCustomCell.self, forCellReuseIdentifier: "MyCell1")
        myTable.layer.cornerRadius = 10
        myTable.keyboardDismissMode = .onDrag
        return myTable
    }()
    
    lazy var authorsButton: UIButton = {
        let myButton = UIButton()
        myButton.setTitle("Authors", for: .normal)
        myButton.configuration = .bordered()
        myButton.configuration?.cornerStyle = .large
        myButton.configuration?.image = UIImage(systemName: "list.bullet.circle")?.imageFlippedForRightToLeftLayoutDirection()
        myButton.addTarget(self, action: #selector(didTapMyButton), for: .touchUpInside)
        return myButton
    }()
    
    lazy var activityButton: UIButton = {
        let myButton = UIButton()
        myButton.setTitle("Activity Folder", for: .normal)
        myButton.configuration = .tinted()
        myButton.configuration?.cornerStyle = .small
        myButton.configuration?.image = UIImage(systemName: "folder")?.imageFlippedForRightToLeftLayoutDirection()
        myButton.addTarget(self, action: #selector(didTapMyButton1), for: .touchUpInside)
        return myButton
    }()
    
    @objc func didTapMyButton(){
        present(AuthorViewController(), animated: true)
    }
    
    @objc func didTapMyButton1(){
        let sheetViewController = ActivitySheetViewController(nibName: nil, bundle: nil)
        
        // Present it w/o any adjustments so it uses the default sheet presentation.
        present(sheetViewController, animated: true, completion: nil)
    }
}

extension QuoteViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell1") as? MyCustomCell{
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = items[indexPath.row].en
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = items[indexPath.row].author
            cell.contentView.largeContentTitle = items[indexPath.row].id
            
            return cell
        }
        return UITableViewCell()
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension QuoteViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var filteredItems:[Quote] = []
        
        if !searchText.isEmpty {
            filteredItems = items.filter({ quote in
                if quote.en.lowercased().contains(searchText.lowercased()) ||
                    quote.author.lowercased().contains(searchText.lowercased()) {
                    return true
                }
                return false
            })
            
            items = filteredItems
        } else {
            items = allItems
        }
        
        DispatchQueue.main.async {
            self.quotesTable.reloadData()
        }
    }
}

class MyCustomCell: UITableViewCell{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
