//
//  TableViewController.swift
//  WalletPreview
//
//  Created by Ju on 2017/5/27.
//  Copyright © 2017年 Ju. All rights reserved.
//

import UIKit
import PassKit

class TableViewController: UITableViewController, PKAddPassesViewControllerDelegate {
    
    // [.pkpass]
    private var passes = [String]()
    private var passLibrary: PKPassLibrary!
    private var selectedPass: PKPass!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check whether PKPassLibrary is available
        if !PKPassLibrary.isPassLibraryAvailable() {
            let alert = UIAlertController(title: "Wallet", message: "Pass kit not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        if let path = Bundle.main.resourcePath {
            if let passFiles = try? FileManager.default.contentsOfDirectory(atPath: path) {
                for pathFile in passFiles {
                    if pathFile.hasSuffix(".pkpass") {
                        passes.append(pathFile)
                    }
                }
            }
        }
        
    }
    
    // MARK: - Table view datasource & delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "passIdentifier", for: indexPath)
        cell.textLabel?.text = passes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = passes[indexPath.row]
        let components = path.components(separatedBy: ".")
        let pathFile = Bundle.main.path(forResource: components[0], ofType: components[1])
        if let data = try? Data(contentsOf: URL(fileURLWithPath: pathFile!)) {
            var error: NSError?
            let pass = PKPass(data: data, error: &error)
            if error != nil {
                let alert = UIAlertController(title: "Pass error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .destructive, handler: nil))
                present(alert, animated: true, completion: nil)
            }
            
            passLibrary = PKPassLibrary()
            
            selectedPass = pass
            
            let addPass = PKAddPassesViewController(pass: pass)
            addPass.delegate = self
            present(addPass, animated: true, completion: nil)
        }
    }
    
    // MARK: - Pass controller delegate
    
    
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
