//
//  ViewController.swift
//  Translate
//
//  Created by Robert O'Connor on 16/10/2015.
//  Copyright © 2015 WIT. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }


    @IBOutlet weak var input: UITextView!
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var inputLanguage: UIPickerView!
    @IBOutlet weak var translateButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.inputLanguage.dataSource = self;
        self.inputLanguage.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languagesText[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languagesText.count
    }
    @IBAction func translate(_ sender: AnyObject) {
        let frame = CGRect(x: 300, y: 300, width: 500, height: 500)
        let indicator = NVActivityIndicatorView(frame:frame,type:NVActivityIndicatorType.pacman)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()

        let (source,target) = getLanguagas()
        let str = input.text
        let escapedStr = str?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        print("Requesting translation for '\(str!)'")
        let langStr = (source + "|" + target).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        var result = "Network Error"
        var request = URLRequest(url: URL(string: "http://api.mymemory.translated.net/get?q="+escapedStr!+"&langpair="+langStr!)!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in

            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode == 200){
                    print("Received data, now parsing.")
                    let jsonDict: NSDictionary!=(try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                    if(jsonDict.value(forKey: "responseStatus") as! NSNumber == 200){
                        let responseData: NSDictionary = jsonDict.object(forKey: "responseData") as! NSDictionary
                        result = responseData.object(forKey: "translatedText") as! String
                    }
                }else{
                    print("Cannot connect to server or server is down")
                }
            }
            print(result)
            
            DispatchQueue.main.async {
                indicator.stopAnimating()
                self.output.text = result
            }
        }.resume()
        
    }
    
    
    var languagesText = ["Turkish","English","French","Italian","German","Russian"]
    
    var languagesCode = ["TR","EN","FR","IT","DE","RU"]
    
    func getLanguagas() -> (String,String){
        let sourceLang = languagesCode[inputLanguage.selectedRow(inComponent: 0)]
        let targetLang = languagesCode[inputLanguage.selectedRow(inComponent: 1)]
        return(sourceLang,targetLang)
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
