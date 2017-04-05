//
//  DeviceSetupViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/26/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

// TODO: Handle different pi models. Currently supports Pi 3
class DeviceSetupViewController: UIViewController,
UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverPresentationControllerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var devicePicker: UIPickerView!
    @IBOutlet weak var scrollView: UIScrollView!

    // Local Variables
    var currentImageView: UIImageView!
    var currentPinSetup: [Pin]!
    var popoverView: UIViewController!

    let pickerOptions = [
        DeviceTypes.rPi3
    ].self

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Check if we should load from layout
        currentPinSetup = [Pin]()
        for i in 1...40 {
            currentPinSetup.append(Pin(id: i))
        }

        // MARK: Additional navigation setup

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DeviceSetupViewController.onLeave))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DeviceSetupViewController.onSetDeviceSettings))

        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.title = "Device Setup"

        // MARK: Additional view setup

        currentImageView = initImageView()

        devicePicker.dataSource = self
        devicePicker.delegate = self

        let paddedWidth = currentImageView.bounds.width + 256
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(DeviceSetupViewController.onTouchTap))

        scrollView.addGestureRecognizer(singleTap)
        scrollView.addSubview(currentImageView)
        scrollView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        scrollView.backgroundColor = UIColor(red: 0xff, green: 0x00, blue: 0x00, alpha: 1.0)
        scrollView.contentSize = CGSize(width: paddedWidth, height: currentImageView.bounds.height)
        scrollView.contentOffset = CGPoint(x: 512, y: 68)
        scrollView.delegate = self

        // MARK: Add event listeners for notifications from popovers

        NotificationCenter.default.addObserver(self, selector: #selector(self.handleApplyLayout), name: NotificationNames.apply, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleClearLayout), name: NotificationNames.clear, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleSaveLayout), name: NotificationNames.save, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleSetWebLogin), name: NotificationNames.login, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleValidLogin), name: NotificationNames.loginSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleUpdatePin), name: NotificationNames.updatePin, object: nil)
    }

    override func viewDidLayoutSubviews() {
        scrollView!.maximumZoomScale = 2.0
        scrollView!.minimumZoomScale = 0.5
        scrollView!.setZoomScale(1.0, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        var contentSize: CGSize!
        var sourceRect: CGRect!

        switch segue.identifier! {
        case SegueTypes.idToPopoverApply:
            contentSize = CGSize(width: 360, height: 400)
        case SegueTypes.idToPopoverSave:
            contentSize = CGSize(width: 360, height: 200)
        case SegueTypes.idToPopoverClear:
            contentSize = CGSize(width: 360, height: 200)
        case SegueTypes.idToPopoverDiagram:
            contentSize = CGSize(width: 360, height: 700)
        case SegueTypes.idToPopoverLogin:
            contentSize = CGSize(width: 320, height: 320)
        case SegueTypes.idToPinSettings:
            contentSize = CGSize(width: 150, height: 250)
            sourceRect = CGRect(origin: CGPoint(x: 0, y: 0), size: destination.view.bounds.size)
            (destination as! PinSettingsViewController).pin = sender as! Pin
        default: break
        }

        _ = PopoverViewController.buildPopover(
                source: self, content: destination, contentSize: contentSize, sourceRect: sourceRect)
    }

    // MARK: UIPickerViewDataSource Functions

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }

    // MARK: UIPickerViewDelegate Functions

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // TODO: Implement. Updates pi diagram based on selection
    }
    
    // MARK: UIScrollViewDelegate Functions

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentImageView
    }

    // MARK: Local Functions

    func handleApplyLayout() {
        print("APPLY")
    }

    func handleClearLayout() {
        print("CLEAR")
    }

    func handleSaveLayout(_ notification: Notification) {
        let fileName = notification.userInfo?["text"] as! String
        let filePath = documentsDirectory().appending("/\(fileName)")
        let layout = PinLayout(name: fileName, defaultSetup: currentPinSetup)
        NSKeyedArchiver.archiveRootObject(layout, toFile: filePath)
        // TODO: Show success
        print("SAVE")
    }

    func handleSetWebLogin() {
        print("WEBIOPI")
    }

    func handleUpdatePin(notification: Notification) {
        let userInfo = notification.userInfo as! [String:String]
        let id = Int(userInfo["id"]!)
        let name = userInfo["name"]
        let type = userInfo["type"]

        currentPinSetup[id!].name = name!

        switch type! {
        case "control":
            currentPinSetup[id!].type = .control
        case "ignore":
            currentPinSetup[id!].type = .ignore
        case "monitor":
            currentPinSetup[id!].type = .monitor
        default: break
        }

        refreshImageView()
    }

    func handleValidLogin() {
        print("LOGIN IS VALID")
    }

    func initImageView() -> UIImageView {
        let btnWidth = 28
        let btnHeight = 25
        let imgWidth = 1335.0
        let imgHeight = 2000.0
        let scale = 0.67

        let imgVw = UIImageView(image: UIImage(named: "RaspberryPi_3B.png"))
        imgVw.frame = CGRect(x: 0, y: 0, width: scale * imgWidth, height: scale * imgHeight)

        // Position buttons with respect to image
        var isEven: Bool
        var x, y: Int

        for i in 1...40 {
            isEven = i % 2 == 0
            x = isEven ? 710 + btnWidth + 4 : 710
            y = (btnHeight + 8) * ((i - 1) / 2) + 208

            let pinButton = UIButton(type: UIButtonType.roundedRect) as UIButton
            pinButton.frame = CGRect(x: x, y: y, width: 28, height: 25)
            pinButton.setTitle("\(i)", for: UIControlState.normal)
            pinButton.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            pinButton.backgroundColor = UIColor.purple

            imgVw.addSubview(pinButton)
        }

        return imgVw
    }

    func refreshImageView() {
        for child in currentImageView.subviews {
            guard child is UIButton else { break }

            let pinButton = child as! UIButton
            let pinId = Int(pinButton.currentTitle!)

            switch currentPinSetup[pinId! - 1].type {
            case .ignore:
                pinButton.backgroundColor = UIColor.gray
            case .monitor:
                pinButton.backgroundColor = UIColor.blue
            case .control:
                pinButton.backgroundColor = UIColor.orange
            }
        }
        print(currentImageView.subviews.count)
    }

    func onLeave(sender: UIButton!) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func onSetDeviceSettings(sender: UIButton!) {
        // TODO: Implement saving the layout
        onLeave(sender: sender!)
    }

    func onTouchTap(gesture: UITapGestureRecognizer) {
        // Identify first button being touched
        let touch = gesture.location(in: scrollView) as CGPoint
        let selection = self.currentImageView.subviews.first(where: {child in
            guard (child is UIButton) else { return false }
            return child.frame.contains(touch)
        });

        if selection != nil {
            let pinId = Int(((selection as! UIButton).titleLabel?.text)!)
            let isEven = pinId! % 2 == 0
            let offset = CGSize(width: isEven ? -64 : -300, height: -64)

            // Open popover with selected pin data
            self.performSegue(withIdentifier: SegueTypes.idToPinSettings, sender: currentPinSetup[pinId!])

            // Scroll over to pin
            goToPoint(point: CGPoint(x: touch.x + offset.width, y: touch.y + offset.height))
        }
    }
    
    // Prevents popover from changing style based on the iOS device
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    // TODO: Tweak for a smoother movement
    func goToPoint(point: CGPoint) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.scrollView.contentOffset = point
            }, completion: nil)
        }
    }

    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0] as String
        return documentDirectory
    }
}
