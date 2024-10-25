import ARKit
import SwiftUI
import Vision

final class SessionHandler: NSObject, ObservableObject, ARSessionDelegate {
    private var thumbTipView: UIView!
    private var indexTipView: UIView!
    
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
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
}
