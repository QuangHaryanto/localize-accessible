//
//  SecondViewController.swift
//  myLocalSwiftApp
//
//  Created by Haryanto Salim on 21/09/22.
//

import UIKit

struct AuthorDetail: Codable {
    let name: String?
    let wikiURL: String?
    let quoteCount: Int?
    
    static var dummyJSON: String = {
        return """
{
  "Haryanto Salim": {
    "name": "Haryanto Salim",
    "wikiUrl": "https://",
    "quoteCount": 0
  },
  "Edsger W. Dijkstra": {
    "name": "Edsger W. Dijkstra",
    "wikiUrl": "https://en.wikipedia.org/wiki/Edsger W. Dijkstra",
    "quoteCount": 23
  },
  "Tony Hoare": {
    "name": "Tony Hoare",
    "wikiUrl": "https://en.wikipedia.org/wiki/Tony Hoare",
    "quoteCount": 1
  },
  "Jeff Hammerbacher": {
    "name": "Jeff Hammerbacher",
    "wikiUrl": "https://en.wikipedia.org/wiki/Jeff Hammerbacher",
    "quoteCount": 1
  },
  "Fred Brooks": {
    "name": "Fred Brooks",
    "wikiUrl": "https://en.wikipedia.org/wiki/Fred Brooks",
    "quoteCount": 35
  },
  "Michael Stal": {
    "name": "Michael Stal",
    "wikiUrl": "https://en.wikipedia.org/wiki/Michael Stal",
    "quoteCount": 1
  },
  "Jeff Sickel": {
    "name": "Jeff Sickel",
    "wikiUrl": "https://en.wikipedia.org/wiki/Jeff Sickel",
    "quoteCount": 1
  },
  "Ken Thompson": {
    "name": "Ken Thompson",
    "wikiUrl": "https://en.wikipedia.org/wiki/Ken Thompson",
    "quoteCount": 8
  },
  "Donald Knuth": {
    "name": "Donald Knuth",
    "wikiUrl": "https://en.wikipedia.org/wiki/Donald Knuth",
    "quoteCount": 14
  },
  "Grace Hopper": {
    "name": "Grace Hopper",
    "wikiUrl": "https://en.wikipedia.org/wiki/Grace Hopper",
    "quoteCount": 1
  },
  "Rick Osborne": {
    "name": "Rick Osborne",
    "wikiUrl": "https://en.wikipedia.org/wiki/Rick Osborne",
    "quoteCount": 1
  },
  "John Ousterhout": {
    "name": "John Ousterhout",
    "wikiUrl": "https://en.wikipedia.org/wiki/John Ousterhout",
    "quoteCount": 1
  },
  "Poul Anderson": {
    "name": "Poul Anderson",
    "wikiUrl": "https://en.wikipedia.org/wiki/Poul Anderson",
    "quoteCount": 1
  },
  "Robert C. Martin": {
    "name": "Robert C. Martin",
    "wikiUrl": "https://en.wikipedia.org/wiki/Robert C. Martin",
    "quoteCount": 4
  },
  "David Gelernter": {
    "name": "David Gelernter",
    "wikiUrl": "https://en.wikipedia.org/wiki/David Gelernter",
    "quoteCount": 1
  },
  "Edward V. Berard": {
    "name": "Edward V. Berard",
    "wikiUrl": "https://en.wikipedia.org/wiki/Edward V. Berard",
    "quoteCount": 1
  },
  "Brian Kernighan": {
    "name": "Brian Kernighan",
    "wikiUrl": "https://en.wikipedia.org/wiki/Brian Kernighan",
    "quoteCount": 3
  },
  "Chris Wenham": {
    "name": "Chris Wenham",
    "wikiUrl": "https://en.wikipedia.org/wiki/Chris Wenham",
    "quoteCount": 1
  },
  "Haryanto Salim": {
    "name": "Haryanto Salim",
    "wikiUrl": "https://",
    "quoteCount": 0
  }
}
"""}()
}

class AuthorViewController: UIViewController {
    var items: [AuthorDetail] = []
    
    var networkService = NetworkService(sessionConfiguration: URLSessionConfiguration.default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        loadDataDummy()
    }
    
    func setupView(){
        view.backgroundColor = .systemBackground
        
        //setup navbar
        view.addSubview(myCustomNavigationBar)
        myCustomNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            myCustomNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myCustomNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        //setup stackView
        view.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        // autolayout constraint
        let layoutGuide: UILayoutGuide = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 60),
            mainStackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
        ])
    }
    
    func loadDataFromNetwork(){
        networkService.request(url: "https://programming-quotes-api.herokuapp.com/Authors", query: nil, httpMethod: "GET") { [self] response in
            switch response {
            case .success(let data):
                DispatchQueue.main.async { [self] in
                    do{
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                            return
                        }
                        items = []
                        for item in json{
                            let data = try JSONSerialization.data(withJSONObject: item.value, options: [])
                            let author = try JSONDecoder().decode(AuthorDetail.self, from: data)
                            items.append(author)
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                    self.authorsTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func loadDataDummy(){
        DispatchQueue.main.async { [self] in
            guard let data = AuthorDetail.dummyJSON.data(using: .utf8) else { return }
            
            do{
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    return
                }
                items = []
                for item in json{
                    let data = try JSONSerialization.data(withJSONObject: item.value, options: [])
                    let author = try JSONDecoder().decode(AuthorDetail.self, from: data)
                    items.append(author)
                }
            }catch{
                print(error.localizedDescription)
            }
            authorsTable.reloadData()
        }
    }
    
    lazy var mainStackView: UIStackView = {
        //Stack View
        let stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 8.0
        
        stackView.addArrangedSubview(authorsTable)
        authorsTable.translatesAutoresizingMaskIntoConstraints = false
        authorsTable.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        stackView.addArrangedSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        return stackView
    } ()
    
    lazy var closeButton: UIButton = {
        let myButton = UIButton()
        myButton.setTitle("Close", for: .normal)
        myButton.backgroundColor = .systemBlue
        myButton.tintColor = .white
        myButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        myButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        return myButton
    }()
    
    @objc func didTapCloseButton(){
        self.dismiss(animated: true)
    }
    
    lazy var authorsTable: UITableView = {
        let myTable = UITableView()
        myTable.dataSource = self
        myTable.delegate = self
        myTable.register(MyCustomCell.self, forCellReuseIdentifier: "MyCell")
        myTable.layer.cornerRadius = 10
        return myTable
    }()
    
    lazy var myCustomNavigationBar: UIView = {
        let navBar = UINavigationBar()
        let navItem = UINavigationItem(title: "Author List")
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        navItem.rightBarButtonItem = doneItem
        navBar.setItems([navItem], animated: false)
        
        return navBar
    }()
    
    @objc func didTapDone(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension AuthorViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as? MyCustomCell{
            cell.textLabel?.textColor = .systemGray
            cell.backgroundColor = .systemYellow
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "\(items[indexPath.row].name ?? "") has \(items[indexPath.row].quoteCount ?? 0) quote(s)"
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = items[indexPath.row].wikiURL
            
            return cell
        }
        return UITableViewCell()
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


