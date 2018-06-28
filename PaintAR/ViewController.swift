//
//  ViewController.swift
//  PaintAR
//
//  Created by Muhammad Abdul Subhan on 09/01/2018.
//  Copyright © 2018 Subhan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var pickerButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var widthSlider: UISlider!
    
    var previousPoint: SCNVector3?
    var lineColor: UIColor = UIColor(red: 0.7, green: 0.1, blue: 0.7, alpha: 1)
    var colorPicker:ChromaColorPicker!
    var lineWidth:CGFloat = 10
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    @IBAction func didTapResetButton(_ sender: Any) {
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        sceneView.session.run(ARWorldTrackingConfiguration(), options: [.resetTracking, .removeExistingAnchors])
    }
    
    @IBAction func didTapPickerButton(_ sender: Any) {
        if pickerButton.isSelected {
            colorPicker.removeFromSuperview()
            pickerButton.isSelected = false
        }
        else {
            view.addSubview(colorPicker)
            pickerButton.isSelected = true
        }
    }
    @IBAction func didTapSaveButton(_ sender: Any) {
        let image = sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    @IBAction func didChangeLineWidthValue(_ sender: Any) {
        lineWidth = CGFloat(widthSlider.value)
    }
}

extension ViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func configureUI() {
        colorPicker = ChromaColorPicker(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height/2 - 100, width: 200.0, height: 200.0))
        colorPicker.delegate = self
        colorPicker.padding = 5.0
        colorPicker.stroke = 3.0
        colorPicker.hexLabel.isHidden = true
        colorPicker.layout()
        
        saveButton.layer.cornerRadius = 5
        saveButton.layer.masksToBounds = true
        
        button.layer.borderWidth = 3.5
        button.layer.cornerRadius = button.frame.size.width/2
        button.layer.masksToBounds = true
        button.layer.borderColor = lineColor.cgColor
        
        saveButton.backgroundColor = lineColor
    }
}


extension ViewController: ARSCNViewDelegate {
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        guard let pointOfView = sceneView.pointOfView else { return }
        guard let button = button else { return }
        
        let mat = pointOfView.transform
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        let currentPosition = pointOfView.position + (dir * 0.1)
        
        // move to main thread
        if button.isHighlighted {
            if let previousPoint = previousPoint {
                let twoPointsNode = SCNNode()
                _ = twoPointsNode.buildLineInTwoPointsWithRotation(
                    from: previousPoint,
                    to: currentPosition,
                    radius: lineWidth/10000,
                    color: lineColor)
                
                sceneView.scene.rootNode.addChildNode(twoPointsNode)
            }
        }
        previousPoint = currentPosition
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("error launching ARSession: \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        print("session was interrupted ended")
    }
}

extension ViewController: ChromaColorPickerDelegate {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        print(color)
        lineColor = color
        button.layer.borderColor = lineColor.cgColor
        saveButton.backgroundColor = lineColor
    }
}
