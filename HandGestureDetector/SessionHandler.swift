import ARKit
import SwiftUI
import Vision

final class SessionHandler: NSObject, ObservableObject, ARSessionDelegate {
    weak var arView: ARSCNView?
    
    private var thumbTipView: UIView!
    private var indexTipView: UIView!
    
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    private let operationManager = OperationManager()
    
    func createCircleForFingers(in view: UIView) {
        thumbTipView = createFingerView(in: view)
        indexTipView = createFingerView(in: view)
        handPoseRequest.maximumHandCount = 2
    }
    
    private func createFingerView(in view: UIView) -> UIView {
        let finger = UIView(frame: .init(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 10, height: 10))
        
        finger.backgroundColor = .green
        finger.layer.cornerRadius = 10
        view.addSubview(finger)
        
        return finger
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        
        DispatchQueue.global().sync { [weak self] in
            do {
                try self?.performRequest(handler: handler)
            } catch {
                print("Error performing hand pose detection: \(error)")
            }
        }
    }
    
    private func performRequest(handler: VNImageRequestHandler) throws {
        try handler.perform([handPoseRequest])
        
        if let observation = handPoseRequest.results?.first as? VNHumanHandPoseObservation {
            let jointPoints = try observation.recognizedPoints(.all)
            DispatchQueue.main.async { [weak self] in
                self?.updateFingerTipPositions(jointPoints)
                self?.verifyIfHandIsPinching()
            }
        } else {
            thumbTipView.isHidden = true
            indexTipView.isHidden = true
        }
    }
    
    private func updateFingerTipPositions(_ jointPoints: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint]) {
        if let thumbTipPoint = jointPoints[.thumbTip] {
            obtainJointPointAndUpdatePosition(thumbTipPoint, view: thumbTipView)
        } else {
            thumbTipView.isHidden = true
        }
        if let indexTipPoint = jointPoints[.indexTip] {
            obtainJointPointAndUpdatePosition(indexTipPoint, view: indexTipView)
        } else {
            indexTipView.isHidden = true
        }
    }
    
    private func obtainJointPointAndUpdatePosition(_ jointPoint: VNRecognizedPoint, view: UIView) {
        let screenFingerTipPoint = convertPointFromVision(point: jointPoint.location, frameSize: UIScreen.main.bounds.size)
        
        view.center = screenFingerTipPoint
        view.isHidden = false
    }
    
    private func verifyIfHandIsPinching() {
        if thumbTipView.center.distance(to: indexTipView.center) > 30 {
            thumbTipView.backgroundColor = .green
            indexTipView.backgroundColor = .green
        } else {
            thumbTipView.backgroundColor = .black
            indexTipView.backgroundColor = .black
            performAttachMesh()
        }
    }
    
    private func performAttachMesh() {
        guard let arView else { return }
        
        operationManager.performOperation { [weak self] in
            self?.attachMeshToScene(in: arView)
        }
    }
    
    private func attachMeshToScene(in arView: ARSCNView) {
        let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.roughness.contents = 0.15
        material.metalness.contents = 1.0
        
        boxGeometry.materials = [material]
        
        let boxNode = SCNNode(geometry: boxGeometry)
        
        let planeAnchor = ARAnchor(name: "horizontalPlane", transform: simd_float4x4(SCNMatrix4Identity))
        
        if let position = performRaycastForHorizontalPlane(in: arView) {
            boxNode.position = position
        }
        
        arView.session.add(anchor: planeAnchor)
        
        let anchorNode = SCNNode()
        anchorNode.addChildNode(boxNode)
        
        arView.scene.rootNode.addChildNode(anchorNode)
    }
    
    private func performRaycastForHorizontalPlane(in arView: ARSCNView) -> SCNVector3? {
        let screenCenter = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        
        guard let raycastQuery = arView.raycastQuery(from: screenCenter, allowing: .estimatedPlane, alignment: .horizontal) else { return nil }
        
        let results = arView.session.raycast(raycastQuery)
        
        if let result = results.first {
            let translation = result.worldTransform.columns.3
            let position = SCNVector3(translation.x, translation.y, translation.z)
            
            return position
        }
        
        return nil
    }
}
