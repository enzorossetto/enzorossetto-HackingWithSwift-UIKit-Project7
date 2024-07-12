//
//  ViewController.swift
//  Project7
//
//  Created by Enzo Rossetto on 11/07/24.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var petitionsToDisplay = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterPetitions))
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
        
        showError()
    }
    
    @objc func filterPetitions() {
        let ac = UIAlertController(title: "This data comes from the We The People API of the Whitehouse", message: "Type a term to search for petitions with it", preferredStyle: .alert)
        ac.addTextField()
        
        let searchAction = UIAlertAction(title: "Search", style: .default) { [weak self, weak ac] _ in
            guard let searchTerm = ac?.textFields?.first?.text?.lowercased() else { return }
            guard let petitions = self?.petitions else { return }
            
            if self?.petitions != nil {
                if searchTerm.isEmpty {
                    self?.petitionsToDisplay = petitions
                } else {
                    self?.petitionsToDisplay = petitions.filter { petition in
                        petition.title.lowercased().contains(searchTerm) || petition.body.lowercased().contains(searchTerm)
                    }
                }
            }
            self?.tableView.reloadData()
        }
        
        ac.addAction(searchAction)
        present(ac, animated: true)
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try againg.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            petitionsToDisplay = jsonPetitions.results
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        petitionsToDisplay.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitionsToDisplay[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitionsToDisplay[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

