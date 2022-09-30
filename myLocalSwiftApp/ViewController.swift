//
//  ViewController.swift
//  myLocalSwiftApp
//
//  Created by Haryanto Salim on 21/09/22.
//

import UIKit
import Combine


/**
 Typing NSLocalizedString("key", comment: "comment") every time is tedious and make your code look heavier and harder than it needs to be. To make your life easier you can implement a custom post-fix operator:
 */
postfix operator ~
postfix func ~ (string: String) -> String {
    return NSLocalizedString(string, comment: "")
}

struct Quote: Codable {
    let id, author, en: String
    
    static var initialJSON = """
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
    
}

final class ExampleNetworkService {
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

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

class ViewController: UIViewController {
    
    var items: [Quote] = [Quote(id: "mari", author: "kita", en: "coba"), Quote(id: "mari", author: "kita", en: "coba"), Quote(id: "mari", author: "kita", en: "coba")]
    var allItems: [Quote] = []
    
    var xnetworkService = ExampleNetworkService(sessionConfiguration: URLSessionConfiguration.default)
    
    var stackView   = UIStackView()
    var myTable = UITableView()
    
    lazy var searchBar:UISearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true;
        
        self.navigationItem.title = NSLocalizedString("Quotes", comment: "This is a Title")
        setupSearchBar()
        setupView()
        
        loadData()
    }
    
    func loadDataFromNetwork(){
        xnetworkService.request(url: "https://programming-quotes-api.herokuapp.com/Quotes?count=16", query: nil, httpMethod: "GET") { [self] response in
            switch response {
            case .success(let data):
                DispatchQueue.main.async { [self] in
                    self.items = self.xnetworkService.parse(model: Quote.self, json: data)
                    self.allItems = items
                    self.myTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func loadData(){
        DispatchQueue.main.async { [self] in
            guard let data = Quote.initialJSON.data(using: .utf8) else { return }
            
            self.items = self.xnetworkService.parse(model: Quote.self, json: data)
            self.allItems = items
            self.myTable.reloadData()
            
        }
    }
    
    func setupSearchBar(){
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = "Search..."~
        searchBar.sizeToFit()
        searchBar.isTranslucent = true
        //        searchBar.backgroundImage = UIImage()
        
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        navigationItem.preferredSearchBarPlacement = .inline
    }
    
    @objc func endEditing(){
        searchBar.resignFirstResponder()
    }
    
    func setupView(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        //Stack View
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        
        myTable.translatesAutoresizingMaskIntoConstraints = false
        myTable.keyboardDismissMode = .onDrag
        myTable = setupTable()
        stackView.addArrangedSubview(myTable)
        myTable.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        
        let myButton = setupButton()
        myButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(myButton)
        myButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        
        
        let myButton1 = setupButton1()
        myButton1.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(myButton1)
        myButton1.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        
        // autolayout constraint
        let layoutGuide: UILayoutGuide = view.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
            
        ])
        
    }
    
    func setupTable()->UITableView{
        let myTable = UITableView()
        myTable.dataSource = self
        myTable.delegate = self
        myTable.register(MyCustomCell.self, forCellReuseIdentifier: "MyCell1")
        myTable.layer.cornerRadius = 10
        
        return myTable
    }
    
    func setupButton()->UIButton{
        let myButton = myCustomButton()
        myButton.setTitle(NSLocalizedString("Authors", comment: "A Button Tap"), for: .normal)
        myButton.configuration = .bordered()
        myButton.configuration?.image = UIImage(systemName: "list.bullet.circle")?.imageFlippedForRightToLeftLayoutDirection()
        myButton.addTarget(self, action: #selector(didTapMyButton), for: .touchUpInside)
        return myButton
    }
    
    func setupButton1()->UIButton{
        let myButton = myCustomButton()
        myButton.setTitle(NSLocalizedString("Activity Folder", comment: "To open folder"), for: .normal)
        myButton.configuration = .tinted()
        myButton.configuration?.image = UIImage(systemName: "folder")?.imageFlippedForRightToLeftLayoutDirection()
        myButton.addTarget(self, action: #selector(didTapMyButton1), for: .touchUpInside)
        return myButton
    }
    
    @objc func didTapMyButton(){
        present(SecondViewController(), animated: true)
    }
    
    @objc func didTapMyButton1(){
        let sheetViewController = SheetViewController(nibName: nil, bundle: nil)
        
        // Present it w/o any adjustments so it uses the default sheet presentation.
        present(sheetViewController, animated: true, completion: nil)
    }
}

//extension ViewController:UISearchResultsUpdating{
//    func updateSearchResults(for searchController: UISearchController) {
//
//    }
//
//}

class myCustomButton: UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setup()
    }
    
    func setup(){
        if let lbl = titleLabel{
            lbl.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            lbl.adjustsFontForContentSizeCategory = true
        }
        configuration?.cornerStyle = .dynamic
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
}

class myCustomLabel: UILabel{
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        font = UIFont.preferredFont(forTextStyle: .title1, compatibleWith: .current)
        adjustsFontForContentSizeCategory = true
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell1") as? MyCustomCell{
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = items[indexPath.row].en~
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
    }
}

extension ViewController: UISearchBarDelegate{
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
            self.myTable.reloadData()
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
