//
//  ResoBox3D.swift
//  mobile
//
//  3D box visualization using SceneKit - matches web Three.js version
//

import SwiftUI
import SceneKit
import UIKit

struct ResoBox3D: View {
    let slice: BoxSlice
    let pair: String?
    let signal: Signal?
    
    var body: some View {
        GeometryReader { geometry in
            SceneKitView(slice: slice, pair: pair, signal: signal)
                .frame(width: geometry.size.width, height: geometry.size.width)
        }
        .aspectRatio(1, contentMode: .fit)
        .background(Color.black)
    }
}

struct SceneKitView: UIViewRepresentable {
    let slice: BoxSlice
    let pair: String?
    let signal: Signal?
    
    // Colors matching web version
    private let positiveColor = UIColor(hex: "24FF66")
    private let negativeColor = UIColor(hex: "303238")
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = createScene()
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling4X
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = createScene()
    }
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.black
        
        let sortedBoxes = sortBoxesByMagnitude(slice.boxes)
        let baseSize: Float = 12.0
        
        var positions: [(position: SCNVector3, dimensions: BoxDimensions)] = []
        
        for (index, box) in sortedBoxes.enumerated() {
            let dimensions = calculateBoxDimensions(index: index, baseSize: baseSize)
            var calculatedPosition = SCNVector3Zero
            
            if index == 0 {
                calculatedPosition = SCNVector3Zero
            } else {
                let prevBox = sortedBoxes[index - 1]
                let prevData = positions[index - 1]
                let parentPosition = prevData.position
                let parentDimensions = prevData.dimensions
                
                let currentSignPositive = box.value > 0
                let prevSignPositive = prevBox.value > 0
                
                let positionSignPositive = currentSignPositive == prevSignPositive
                    ? currentSignPositive
                    : prevSignPositive
                
                let offset = calculateCornerPosition(
                    currentDimensions: dimensions,
                    parentDimensions: parentDimensions,
                    isUp: positionSignPositive
                )
                
                let epsilon: Float = 0.005
                let offsetMagnitude = sqrt(offset.x * offset.x + offset.y * offset.y + offset.z * offset.z)
                
                if offsetMagnitude > 0 {
                    let normalizedOffset = SCNVector3(
                        x: (offset.x / offsetMagnitude) * epsilon,
                        y: (offset.y / offsetMagnitude) * epsilon,
                        z: (offset.z / offsetMagnitude) * epsilon
                    )
                    calculatedPosition = SCNVector3(
                        x: parentPosition.x + offset.x + normalizedOffset.x,
                        y: parentPosition.y + offset.y + normalizedOffset.y,
                        z: parentPosition.z + offset.z + normalizedOffset.z
                    )
                } else {
                    calculatedPosition = SCNVector3(
                        x: parentPosition.x + offset.x,
                        y: parentPosition.y + offset.y,
                        z: parentPosition.z + offset.z
                    )
                }
            }
            
            positions.append((position: calculatedPosition, dimensions: dimensions))
            
            let boxGeometry = SCNBox(
                width: CGFloat(dimensions.size),
                height: CGFloat(dimensions.size),
                length: CGFloat(dimensions.size),
                chamferRadius: 0
            )
            
            // Simple Blinn-Phong material with good depth
            let material = SCNMaterial()
            material.diffuse.contents = box.value > 0 ? positiveColor : negativeColor
            material.specular.contents = UIColor.white
            material.shininess = 0.3
            material.lightingModel = .blinn
            boxGeometry.materials = [material]
            
            let boxNode = SCNNode(geometry: boxGeometry)
            boxNode.position = calculatedPosition
            
            // Dark edges for definition
            addEdges(to: boxNode, size: dimensions.size, color: UIColor.black.withAlphaComponent(0.6))
            
            scene.rootNode.addChildNode(boxNode)
        }
        
        // Camera
        let camera = SCNCamera()
        camera.fieldOfView = 30
        camera.zNear = 0.1
        camera.zFar = 1000
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 25, y: -2, z: 25)
        cameraNode.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(cameraNode)
        
        // Ambient - low intensity for dark areas
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 300
        ambientLight.color = UIColor.white
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        // Main directional light - creates depth through shadows on faces
        let mainLight = SCNLight()
        mainLight.type = .directional
        mainLight.intensity = 800
        mainLight.color = UIColor.white
        let mainLightNode = SCNNode()
        mainLightNode.light = mainLight
        mainLightNode.position = SCNVector3(x: 15, y: 20, z: 25)
        mainLightNode.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(mainLightNode)
        
        // Secondary light from other side - softer fill
        let fillLight = SCNLight()
        fillLight.type = .directional
        fillLight.intensity = 300
        fillLight.color = UIColor.white
        let fillLightNode = SCNNode()
        fillLightNode.light = fillLight
        fillLightNode.position = SCNVector3(x: -10, y: 5, z: -15)
        fillLightNode.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(fillLightNode)
        
        return scene
    }
    
    private func addEdges(to node: SCNNode, size: Float, color: UIColor) {
        let halfSize = size / 2 * 1.002
        let edgeRadius: Float = 0.02 // Fixed thin edge size for all boxes
        
        let vertices: [SCNVector3] = [
            SCNVector3(-halfSize, -halfSize, -halfSize), // 0
            SCNVector3(halfSize, -halfSize, -halfSize),  // 1
            SCNVector3(halfSize, -halfSize, halfSize),   // 2
            SCNVector3(-halfSize, -halfSize, halfSize),  // 3
            SCNVector3(-halfSize, halfSize, -halfSize),  // 4
            SCNVector3(halfSize, halfSize, -halfSize),   // 5
            SCNVector3(halfSize, halfSize, halfSize),    // 6
            SCNVector3(-halfSize, halfSize, halfSize),   // 7
        ]
        
        let edges: [(Int, Int)] = [
            (0, 1), (1, 2), (2, 3), (3, 0), // Bottom
            (4, 5), (5, 6), (6, 7), (7, 4), // Top
            (0, 4), (1, 5), (2, 6), (3, 7)  // Verticals
        ]
        
        for edge in edges {
            let cylinder = createCylinder(from: vertices[edge.0], to: vertices[edge.1], radius: edgeRadius, color: color)
            node.addChildNode(cylinder)
        }
    }
    
    private func createCylinder(from start: SCNVector3, to end: SCNVector3, radius: Float, color: UIColor) -> SCNNode {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let dz = end.z - start.z
        let length = sqrt(dx*dx + dy*dy + dz*dz)
        
        let cylinder = SCNCylinder(radius: CGFloat(radius), height: CGFloat(length))
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.lightingModel = .constant
        cylinder.materials = [material]
        
        let node = SCNNode(geometry: cylinder)
        
        // Position at midpoint
        node.position = SCNVector3(
            x: (start.x + end.x) / 2,
            y: (start.y + end.y) / 2,
            z: (start.z + end.z) / 2
        )
        
        // Rotate to align with edge
        let direction = SCNVector3(x: dx, y: dy, z: dz)
        let up = SCNVector3(x: 0, y: 1, z: 0)
        
        // Calculate rotation
        let dot = up.y * direction.y / length
        if abs(dot) < 0.999 {
            let cross = SCNVector3(
                x: up.y * direction.z - up.z * direction.y,
                y: up.z * direction.x - up.x * direction.z,
                z: up.x * direction.y - up.y * direction.x
            )
            let crossLength = sqrt(cross.x*cross.x + cross.y*cross.y + cross.z*cross.z)
            let angle = acos(dot)
            node.rotation = SCNVector4(
                x: cross.x / crossLength,
                y: cross.y / crossLength,
                z: cross.z / crossLength,
                w: angle
            )
        } else if dot < 0 {
            node.rotation = SCNVector4(x: 1, y: 0, z: 0, w: .pi)
        }
        
        return node
    }
    
    private func sortBoxesByMagnitude(_ boxes: [Box]) -> [Box] {
        return boxes.sorted { abs($0.value) > abs($1.value) }
    }
    
    private struct BoxDimensions {
        let size: Float
        let scale: Float
    }
    
    private func calculateBoxDimensions(index: Int, baseSize: Float) -> BoxDimensions {
        let scale = pow(1.0 / sqrt(1.5), Float(index))
        return BoxDimensions(size: baseSize * scale, scale: scale)
    }
    
    private func calculateCornerPosition(
        currentDimensions: BoxDimensions,
        parentDimensions: BoxDimensions,
        isUp: Bool
    ) -> SCNVector3 {
        let parentHalfSize = parentDimensions.size / 2
        let currentHalfSize = currentDimensions.size / 2
        
        let xOffset = parentHalfSize - currentHalfSize
        let zOffset = parentHalfSize - currentHalfSize
        let yOffset = isUp
            ? (parentHalfSize - currentHalfSize)
            : -(parentHalfSize - currentHalfSize)
        
        return SCNVector3(x: xOffset, y: yOffset, z: zOffset)
    }
}

// UIColor hex extension
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
