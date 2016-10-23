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
        let (source,target) = getLanguages()
        //Check if input language is same with desired one
        if(source == target){
            self.output.text = "Select different language to translate!"
        }else if(self.input.text == "<Text to Translate>") || self.input.text == ""{
            self.output.text = "Please enter something"
        }else{
            
            //Create indicator
            
            let screenSize: CGRect = UIScreen.main.bounds
            let frame = CGRect(x: screenSize.width/2, y: screenSize.height/2, width: 250, height: 250)
            let indicator = NVActivityIndicatorView(frame:frame,type:NVActivityIndicatorType.pacman,color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
            indicator.center = view.center
            view.addSubview(indicator)

            //Start it
            
            indicator.startAnimating()
            
            //Get text from input
            
            let str = input.text
            
            //Make it proper for request
            
            let escapedStr = str?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            print("Requesting translation for '\(str!)'")
            let langStr = (source + "|" + target).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            //Default result in case of network error.
            
            var result = "Network Error"
            //Create Request
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
                }
            }
            print(result)
            DispatchQueue.main.async {
                indicator.stopAnimating()
                self.output.text = result
            }
        }.resume()
        }
    }
    
    
    var languagesText = ["Turkish","English","French","Italian","German","Russian"]
    
    var languagesCode = ["TR","EN","FR","IT","DE","RU"]
    
    func getLanguages() -> (String,String){
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
