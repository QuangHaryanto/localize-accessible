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
}

typealias Quotes = [Quote]

//class NetworkService{
//    
//    func parse<T: Decodable>(model: T.Type, json: Data) -> [T]{
//        let decoder = JSONDecoder()
//        
//        if let jsonItems = try? decoder.decode([T].self, from: json) {
//            return jsonItems
//        }
//        return []
//    }
//}

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
        //        setupManualNavigationBar()
        navigationController?.navigationBar.prefersLargeTitles = true;
        //        let title:String = "My title"
        self.navigationItem.title = "My Title"~ //NSLocalizedString("My Title", comment: "This is a Title")
        
        setupSearchBar()
        setupView()
        loadData()
    }
    
    func loadData(){
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
        myButton.setTitle(NSLocalizedString("Tap Me", comment: "A Button Tap"), for: .normal)
//        myButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
//        myButton.titleLabel?.adjustsFontForContentSizeCategory = true
        myButton.configuration = .bordered()
//        myButton.configuration?.cornerStyle = .capsule
        myButton.configuration?.image = UIImage(systemName: "list.bullet.circle")?.imageFlippedForRightToLeftLayoutDirection()
        myButton.addTarget(self, action: #selector(didTapMyButton), for: .touchUpInside)
        return myButton
    }
    
    func setupButton1()->UIButton{
        let myButton = myCustomButton()
        myButton.setTitle(NSLocalizedString("Open Folder", comment: "To open folder"), for: .normal)
//        myButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
//        myButton.titleLabel?.adjustsFontForContentSizeCategory = true
        myButton.configuration = .tinted()
//        myButton.configuration?.cornerStyle = .capsule
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
        font = UIFont.preferredFont(forTextStyle: .largeTitle, compatibleWith: .current)
        adjustsFontForContentSizeCategory = true
    }
}

class SheetViewController: UIViewController{
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [
                .medium(),
                .large(),
            ]
            presentationController.delegate = self
            presentationController.prefersGrabberVisible = true
        }
    }
}

extension SheetViewController:UISheetPresentationControllerDelegate{
//    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
//        return false
//    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell1") as? MyCustomCell{
            cell.textLabel?.numberOfLines = 0
//            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
//            cell.textLabel?.adjustsFontForContentSizeCategory = true
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
