//
//  OFAMeditationTableViewController.swift
//  Life_Line
//
//  Created by Syam PJ on 13/09/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import AVFoundation

class OFAMeditationTableViewController: UITableViewController {
    
    @IBOutlet var viewInstructionPopup: UIView!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    
    var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    var blurEffectView = UIVisualEffectView()
    
    var selectedIndex = Int()
    
    var audioPlayer : AVAudioPlayer?
    
    var arrayAudioFiles = ["http://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3",
                           "http://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3",
                           "http://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3",
                           "http://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3",
                           "http://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3",
                           "http://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3",
                           "http://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3",
                           "http://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3",
                           "http://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3",
                           "http://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonPlay.layer.cornerRadius = self.buttonPlay.frame.height/2
        self.buttonCancel.layer.cornerRadius = self.buttonCancel.frame.height/2
        
        self.tableView.backgroundColor = OFAUtils.getColorFromHexString(ofabeeCellBackground)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Meditate"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayAudioFiles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeditationCell", for: indexPath) as! OFAMeditationTableViewCell

        cell.viewBG.layer.cornerRadius = 10
        cell.viewBG.dropShadow()
        cell.customizeCellWithDetails(heading: "Meditation \(indexPath.row + 1)", instruction: "nim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat.")

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showInstructionPopUp()
        blur()
        animateIn()
        self.selectedIndex = indexPath.row
    }
    
    // MARK: - Button Action
    
    @IBAction func playInstructionsPressed(_ sender: UIButton) {
        if self.buttonPlay.titleLabel?.text == "Stop"{
            self.audioPlayer?.stop()
            self.buttonPlay.setTitle("Play", for: .normal)
        }else{
            let url = URL(string: self.arrayAudioFiles[self.selectedIndex])
            self.downloadFileFromURL(url: url!)
            self.buttonPlay.setTitle("Stop", for: .normal)
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        removeBlur()
        animateOut()
        self.buttonPlay.setTitle("Play", for: .normal)
    }
    
    func downloadFileFromURL(url:URL){
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { [weak self](URL, response, error) -> Void in
            self?.playAudio(using: URL!)
        })
        downloadTask.resume()
    }
    
    func playAudio(using url:URL){
        do{
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()
        }catch{
            print("Couldn't load file")
        }
    }
    
    //MARK:- iPop Helpers
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        OFAUtils.lockOrientation(.portrait)
        viewInstructionPopup.setNeedsFocusUpdate()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let rootView = delegate.window?.rootViewController?.view
        
        viewInstructionPopup.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 20, height: (rootView?.frame.height)!-((rootView?.frame.height)!/5)))
        viewInstructionPopup.center = view.center
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with:event)
        if touches.first != nil{
            removeBlur()
            animateOut()
        }
    }
    
    @objc func touchesView(){//tapAction
        removeBlur()
        animateOut()
    }
    
    public func removeBlur() {
        blurEffectView.removeFromSuperview()
    }
    
    func showInstructionPopUp(){
        if !OFAUtils.isiPhone(){
            viewInstructionPopup.frame.origin.x = 0
            viewInstructionPopup.frame.origin.y = 0
        }
        else{
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let rootView = delegate.window?.rootViewController?.view
            viewInstructionPopup.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (rootView?.frame.width)! - 20, height: (rootView?.frame.height)!-((rootView?.frame.height)!/5)))
        }
        viewInstructionPopup.layer.cornerRadius = 5 //make oval view edges
    }
    
    func blur(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let rootView = delegate.window?.rootViewController?.view
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = (rootView?.bounds)!
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        rootView?.addSubview(blurEffectView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.touchesView))
        singleTap.numberOfTapsRequired = 1
        self.blurEffectView.addGestureRecognizer(singleTap)
    }
    
    func animateIn() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let rootView = delegate.window?.rootViewController?.view
        rootView?.addSubview(viewInstructionPopup)
        viewInstructionPopup.center = (rootView?.center)!
        viewInstructionPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        viewInstructionPopup.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.viewInstructionPopup.alpha = 1
            self.viewInstructionPopup.transform = CGAffineTransform.identity
        }
    }
    
    public func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewInstructionPopup.transform = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
            self.viewInstructionPopup.alpha = 0
        }) { (success:Bool) in
            self.viewInstructionPopup.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.viewInstructionPopup.removeFromSuperview()
        }
        if self.audioPlayer != nil && (self.audioPlayer?.isPlaying)!{
            self.audioPlayer?.stop()
        }
    }
}
