//
//  ViewController.swift
//  MagicPaper
//
//  Created by Giulio Gola on 17/06/2019.
//  Copyright © 2019 Giulio Gola. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Configuration: tracking images
        let configuration = ARImageTrackingConfiguration()
        sceneView.session.run(configuration)
        // Load the images to track
        if let imagesToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Newspaper Images", bundle: Bundle.main) {
            configuration.trackingImages = imagesToTrack
            configuration.maximumNumberOfTrackedImages = 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate: tells the delegate we have found an anchor (AR object)
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        // Check if the anchor found is of type imageAnchor (image of Harry Potter detected)
        if let imageAnchor = anchor as? ARImageAnchor {
            // Use SpriteKit (SK) to render the videos (2D content)
            let videoNode = SKVideoNode(fileNamed: "HarryPotter.mp4")
            // Video starts playing immediately
            videoNode.play()
            // NOTE: VideoNode is a SpriteKit element and needs to be attached to a SceneKit element (videoScene)
            // NOTE: width and height do NOT have to be precise, it is a guess (360p video: width = 480)
            let videoScene = SKScene(size: CGSize(width: 480.0, height: 360.0))
            // Change position of the videoNode to fit the image: the node anchoring the video to the plane must be set in the center of the videoScene
            videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
            // Rotate Node 180 degrees to flip it correctly around the y-axis
            // TRICK: use property .yScale: scaling it by -1.0 keeps the right size while flipping the image
            videoNode.yScale = -1.0
            // Add video node to videoScene
            videoScene.addChild(videoNode)
            // Define the AR plane using the anchor (image tracked) to stick the video onto
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            // Attach the video to the plane as a material
            plane.firstMaterial?.diffuse.contents = videoScene
            // Create an AR node for the plane
            let planeNode = SCNNode(geometry: plane)
            // Rotate it 90degrees anti-clockwise (default is vertical)
            planeNode.eulerAngles.x = -.pi/2
            // Attach the planeNode to the main node
            node.addChildNode(planeNode)
        }
        return node
    }
}
