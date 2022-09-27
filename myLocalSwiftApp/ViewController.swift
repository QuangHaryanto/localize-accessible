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

class NetworkService{
    
    func parse<T: Decodable>(model: T.Type, json: Data) -> [T]{
        let decoder = JSONDecoder()
        
        if let jsonItems = try? decoder.decode([T].self, from: json) {
//            for item in jsonItems{
//                //print(item)
//            }
            return jsonItems
        }
        return []
    }
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
//            for item in jsonItems{
//                //print(item)
//            }
            return jsonItems
        }
        return []
    }
    
}

class ViewController: UIViewController {
    
    var items: [Quote] = [Quote(id: "mari", author: "kita", en: "coba"), Quote(id: "mari", author: "kita", en: "coba"), Quote(id: "mari", author: "kita", en: "coba")]
    
    var networkService = NetworkService()
    var xnetworkService = ExampleNetworkService(sessionConfiguration: URLSessionConfiguration.default)
    
    let stackView   = UIStackView()
    var myTable = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        // Do any additional setup after loading the view.
        //        setupManualNavigationBar()
        navigationController?.navigationBar.prefersLargeTitles = true;
        //        let title:String = "My title"
        self.navigationItem.title = "My Title"~ //NSLocalizedString("My Title", comment: "This is a Title")
        
        loadData()
    }
    
    override func loadView() {
        super.loadView()
        print(#function)
        setupView()
    }
    
    
    func loadData(){
        xnetworkService.request(url: "https://programming-quotes-api.herokuapp.com/Quotes?count=8", query: nil, httpMethod: "GET") { [self] response in
            switch response {
            case .success(let data):
                DispatchQueue.main.async {
                    self.items = self.networkService.parse(model: Quote.self, json: data)
                    self.myTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setupView(){
        //Stack View
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalCentering
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        
        myTable.translatesAutoresizingMaskIntoConstraints = false
        myTable = setupTable()
        stackView.addArrangedSubview(myTable)
        myTable.leadingAnchor.constraint(equalTo: myTable.superview!.leadingAnchor).isActive = true
        myTable.heightAnchor.constraint(equalTo: myTable.superview!.heightAnchor, constant:-44).isActive = true
        myTable.backgroundColor = .systemCyan
        
        
        let myButton = setupButton()
        myButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(myButton)
        myButton.leadingAnchor.constraint(equalTo: myButton.superview!.leadingAnchor).isActive = true
        
        reLayout()
        
    }
    
    func reLayout(){
        // autolayout constraint
        let layoutGuide: UILayoutGuide = view.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            //            stackView.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor),
            //            stackView.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor),
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
        return myTable
    }
    
    func setupButton()->UIButton{
        let myButton = UIButton()
        myButton.setTitle(NSLocalizedString("Tap Me", comment: "A Button Tap"), for: .normal)
        myButton.setTitleColor(.white, for: .normal)
        myButton.backgroundColor = .systemBlue
        myButton.layer.cornerRadius = 5;
        myButton.addTarget(self, action: #selector(didTapMyButton), for: .touchUpInside)
        return myButton
    }
    
    @objc func didTapMyButton(){
        present(SecondViewController(), animated: true)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
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


class MyCustomCell: UITableViewCell{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
