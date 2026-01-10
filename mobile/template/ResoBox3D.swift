//
//  ResoBox3D.swift
//  mobile
//
//  3D box visualization using SceneKit
//

import SwiftUI
import SceneKit

struct ResoBox3D: View {
    let slice: BoxSlice
    let pair: String?
    let signal: Signal?
    
    var body: some View {
        SceneKitView(slice: slice, pair: pair, signal: signal)
            .aspectRatio(1, contentMode: .fit)
    }
}

struct SceneKitView: UIViewRepresentable {
    let slice: BoxSlice
    let pair: String?
    let signal: Signal?
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = createScene()
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        
        // Camera setup
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 25, y: -2, z: 25)
        cameraNode.look(at: SCNVector3Zero)
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = createScene()
    }
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        
        let sortedBoxes = sortBoxesByMagnitude(slice.boxes)
        let baseSize: Float = 12.0
        
        for (index, box) in sortedBoxes.enumerated() {
            let scale = pow(1.0 / sqrt(1.5), Float(index))
            let size = baseSize * scale
            
            let boxGeometry = SCNBox(width: CGFloat(size), height: CGFloat(size), length: CGFloat(size), chamferRadius: 0)
            
            let color = box.value > 0 
                ? UIColor(hex: "7EB8DA") 
                : UIColor(hex: "9B8DC4")
            
            boxGeometry.firstMaterial?.diffuse.contents = color
            boxGeometry.firstMaterial?.metalness.contents = 0.3
            
            let boxNode = SCNNode(geometry: boxGeometry)
            
            // Calculate position
            if index == 0 {
                boxNode.position = SCNVector3Zero
            } else {
                let prevBox = sortedBoxes[index - 1]
                let prevScale = pow(1.0 / sqrt(1.5), Float(index - 1))
                let prevSize = baseSize * prevScale
                
                let parentHalfSize = prevSize / 2
                let currentHalfSize = size / 2
                
                let offsetX = parentHalfSize - currentHalfSize
                let offsetZ = parentHalfSize - currentHalfSize
                let offsetY = (box.value > 0) ? (parentHalfSize - currentHalfSize) : -(parentHalfSize - currentHalfSize)
                
                boxNode.position = SCNVector3(
                    x: offsetX,
                    y: offsetY,
                    z: offsetZ
                )
            }
            
            scene.rootNode.addChildNode(boxNode)
        }
        
        // Lighting
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 1000
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 2000
        let directionalNode = SCNNode()
        directionalNode.light = directionalLight
        directionalNode.position = SCNVector3(x: 10, y: 10, z: 40)
        scene.rootNode.addChildNode(directionalNode)
        
        return scene
    }
    
    private func sortBoxesByMagnitude(_ boxes: [Box]) -> [Box] {
        return boxes.sorted { abs($0.value) > abs($1.value) }
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
