/*
*  Copyright © 2019 DiHola S.L. All rights reserved.
*/

import DiHolaShakingAPI

class ViewController: UIViewController {
    
    @IBOutlet var button: UIButton!
    @IBOutlet var actionLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    
    let API_KEY = "Get one at www.diholapp.com"
    
    var USER_ID: String!
    
    var shakingAPI: ShakingAPI!
    
    var stopped = true
    
    @IBAction func button(_ sender: Any) {
        
        if stopped {
            self.startAPI()
        } else {
            self.stopAPI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.USER_ID = self.randomString(length: 8)
        self.actionLabel.text = "My ID: " + self.USER_ID
        
        self.shakingAPI = ShakingAPI(API_KEY: API_KEY,
                                     USER_ID: USER_ID,
                                     onShaking: shakingHandler,
                                     onSuccess: successHandler,
                                     onError: errorHandler)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func shakingHandler(){
        self.resultLabel.text = "Loading..."
        self.resultLabel.textColor = .green
    }
    
    func successHandler(result: Array<String>){
        
        if result.count > 0 {
            self.resultLabel.text = "Last user(s) found: " + result.joined(separator:", ")
        } else {
            self.resultLabel.text = "No users found..."
        }
        
        self.resultLabel.textColor = .black
    }
    
    func errorHandler(error: ShakingCode){
        
        switch error {
            case .LOCATION_PERMISSION_ERROR:
                self.resultLabel.text = "Location permission error. Grant location permission and try again."
                break
            case .LOCATION_DISABLED:
                self.resultLabel.text = "Please enable location and try again."
                break
            case .AUTHENTICATION_ERROR:
                self.resultLabel.text = "Authentication error. Get your API key at www.diholapp.com"
                break
            case .API_KEY_EXPIRED:
                self.resultLabel.text = "API key expired. Get one at www.diholapp.com"
                break
            case .SERVER_ERROR:
                self.resultLabel.text = "Server is not available. Try again later."
                break
            case .SENSOR_ERROR:
                self.resultLabel.text = "Your device doesn't support motion tracking."
                break
        }
        
        self.resultLabel.textColor = .red
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func stopAPI(){
        self.button.setTitle("Start", for: .normal)
        self.button.setTitleColor(self.view.tintColor, for: .normal)
        if self.resultLabel.text == "Loading..." {
            self.resultLabel.text = ""
        }
        self.shakingAPI.stop()
        self.stopped = true
    }
    
    func startAPI(){
        self.resultLabel.text = "Shake your device"
        self.button.setTitle("Stop", for: .normal)
        self.button.setTitleColor(.red, for: .normal)
        self.shakingAPI.start()
        self.stopped = false
    }
    
    
    @objc func appMovedToBackground() {
        self.stopAPI()
    }

}

