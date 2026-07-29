import SwiftUI

/// Procedural SwiftUI Canvas View rendering Jack the Orange Pumpkin with full state animations.
struct JackCanvasView: View {
    let state: GhostState
    let facingDirection: FacingDirection
    let animationTime: Double
    let eyeOffsetX: CGFloat
    let headTiltAngle: Double
    let flipAngle: Double
    let currentEmoji: String?
    let isNightMode: Bool
    
    var body: some View {
        ZStack {
            // Nighttime Warm Candle Flame Glow for Jack
            if isNightMode {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.65, blue: 0.1).opacity(0.55),
                                Color(red: 1.0, green: 0.35, blue: 0.0).opacity(0.25),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 58
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 10)
                
                PumpkinEmberParticlesView(animationTime: animationTime)
            }
            
            // Main Jack Canvas
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let center = CGPoint(x: w / 2, y: h / 2 + 5)
                
                // 1. Shadow
                var shadowPath = Path()
                shadowPath.addEllipse(in: CGRect(x: center.x - 24, y: h - 14, width: 48, height: 10))
                context.fill(shadowPath, with: .color(Color.black.opacity(state.isSleeping ? 0.25 : 0.15)))
                
                context.withCGContext { cgContext in
                    let totalRotation = (flipAngle + headTiltAngle) * .pi / 180.0
                    if totalRotation != 0.0 {
                        cgContext.translateBy(x: center.x, y: center.y)
                        cgContext.rotate(by: totalRotation)
                        cgContext.translateBy(x: -center.x, y: -center.y)
                    }
                    
                    // 2. Green Pumpkin Stem & Curly Vine
                    var stem = Path()
                    stem.move(to: CGPoint(x: center.x - 3, y: center.y - 24))
                    stem.addQuadCurve(
                        to: CGPoint(x: center.x + 6, y: center.y - 36),
                        control: CGPoint(x: center.x - 1, y: center.y - 32)
                    )
                    stem.addLine(to: CGPoint(x: center.x + 10, y: center.y - 34))
                    stem.addQuadCurve(
                        to: CGPoint(x: center.x + 4, y: center.y - 24),
                        control: CGPoint(x: center.x + 4, y: center.y - 30)
                    )
                    stem.closeSubpath()
                    context.fill(stem, with: .color(Color(red: 0.22, green: 0.65, blue: 0.28)))
                    
                    // 3. Plump Orange Pumpkin Body (Ribbed Segments)
                    let pumpkinRect = CGRect(x: center.x - 26, y: center.y - 24, width: 52, height: 44)
                    
                    // Outer Segments
                    let outerLeft = Path(ellipseIn: CGRect(x: pumpkinRect.minX, y: pumpkinRect.minY, width: 22, height: pumpkinRect.height))
                    let outerRight = Path(ellipseIn: CGRect(x: pumpkinRect.maxX - 22, y: pumpkinRect.minY, width: 22, height: pumpkinRect.height))
                    let midLeft = Path(ellipseIn: CGRect(x: center.x - 18, y: pumpkinRect.minY - 1, width: 22, height: pumpkinRect.height + 2))
                    let midRight = Path(ellipseIn: CGRect(x: center.x - 4, y: pumpkinRect.minY - 1, width: 22, height: pumpkinRect.height + 2))
                    let centerSegment = Path(ellipseIn: CGRect(x: center.x - 14, y: pumpkinRect.minY - 2, width: 28, height: pumpkinRect.height + 4))
                    
                    let darkOrange = Color(red: 0.88, green: 0.38, blue: 0.05)
                    let midOrange = Color(red: 0.98, green: 0.52, blue: 0.08)
                    let brightOrange = Color(red: 1.0, green: 0.62, blue: 0.12)
                    
                    context.fill(outerLeft, with: .color(darkOrange))
                    context.fill(outerRight, with: .color(darkOrange))
                    context.fill(midLeft, with: .color(midOrange))
                    context.fill(midRight, with: .color(midOrange))
                    context.fill(centerSegment, with: .color(brightOrange))
                    
                    context.stroke(centerSegment, with: .color(Color(red: 0.75, green: 0.3, blue: 0.0).opacity(0.3)), lineWidth: 1.2)
                    
                    // 4. Vine Waving Arm (for Waving state)
                    if state == .waving {
                        let waveAngle = sin(animationTime * 7.0) * 0.35
                        let armBase = CGPoint(x: center.x + 22, y: center.y - 2)
                        
                        cgContext.translateBy(x: armBase.x, y: armBase.y)
                        cgContext.rotate(by: waveAngle)
                        
                        var vineArm = Path()
                        vineArm.move(to: .zero)
                        vineArm.addQuadCurve(to: CGPoint(x: 14, y: -16), control: CGPoint(x: 6, y: -14))
                        context.stroke(vineArm, with: .color(Color(red: 0.25, green: 0.7, blue: 0.3)), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        
                        // Small leaf on vine
                        var leaf = Path(ellipseIn: CGRect(x: 10, y: -20, width: 8, height: 5))
                        context.fill(leaf, with: .color(Color(red: 0.3, green: 0.8, blue: 0.35)))
                        
                        cgContext.rotate(by: -waveAngle)
                        cgContext.translateBy(x: -armBase.x, y: -armBase.y)
                    }
                    
                    // 5. Carved Jack-o'-Lantern Face Expression
                    let glowYellow = Color(red: 1.0, green: 0.92, blue: 0.25)
                    let eyeY = center.y - 6
                    let currentEyeX = eyeOffsetX
                    
                    if state.isSleeping {
                        // Sleepy carved eyes (u u)
                        var leftEye = Path()
                        leftEye.addArc(center: CGPoint(x: center.x - 11, y: eyeY), radius: 4, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                        context.stroke(leftEye, with: .color(glowYellow), lineWidth: 2.5)
                        
                        var rightEye = Path()
                        rightEye.addArc(center: CGPoint(x: center.x + 11, y: eyeY), radius: 4, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                        context.stroke(rightEye, with: .color(glowYellow), lineWidth: 2.5)
                        
                        // Small curved smile
                        var smile = Path()
                        smile.addArc(center: CGPoint(x: center.x, y: center.y + 6), radius: 6, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                        context.stroke(smile, with: .color(glowYellow), lineWidth: 2.0)
                    } else if state.isStartled {
                        // Wide surprised carved eyes & open gasp mouth (O o O)
                        let leftEye = Path(ellipseIn: CGRect(x: center.x - 16, y: eyeY - 6, width: 10, height: 12))
                        let rightEye = Path(ellipseIn: CGRect(x: center.x + 6, y: eyeY - 6, width: 10, height: 12))
                        context.fill(leftEye, with: .color(glowYellow))
                        context.fill(rightEye, with: .color(glowYellow))
                        
                        // Gasp carved mouth
                        let mouth = Path(ellipseIn: CGRect(x: center.x - 5, y: center.y + 4, width: 10, height: 11))
                        context.fill(mouth, with: .color(glowYellow))
                    } else {
                        // Carved Triangle Eyes
                        var leftEye = Path()
                        leftEye.move(to: CGPoint(x: center.x - 15 + currentEyeX, y: eyeY + 2))
                        leftEye.addLine(to: CGPoint(x: center.x - 8 + currentEyeX, y: eyeY + 2))
                        leftEye.addLine(to: CGPoint(x: center.x - 11.5 + currentEyeX, y: eyeY - 7))
                        leftEye.closeSubpath()
                        
                        var rightEye = Path()
                        rightEye.move(to: CGPoint(x: center.x + 8 + currentEyeX, y: eyeY + 2))
                        rightEye.addLine(to: CGPoint(x: center.x + 15 + currentEyeX, y: eyeY + 2))
                        rightEye.addLine(to: CGPoint(x: center.x + 11.5 + currentEyeX, y: eyeY - 7))
                        rightEye.closeSubpath()
                        
                        context.fill(leftEye, with: .color(glowYellow))
                        context.fill(rightEye, with: .color(glowYellow))
                        
                        // Carved Nose Triangle
                        var nose = Path()
                        nose.move(to: CGPoint(x: center.x - 2, y: center.y + 2))
                        nose.addLine(to: CGPoint(x: center.x + 2, y: center.y + 2))
                        nose.addLine(to: CGPoint(x: center.x, y: center.y - 2))
                        nose.closeSubpath()
                        context.fill(nose, with: .color(glowYellow))
                        
                        // Carved Toothy Jack-o'-Lantern Smile
                        var mouth = Path()
                        let mouthY = center.y + 7
                        mouth.move(to: CGPoint(x: center.x - 14, y: mouthY - 2))
                        mouth.addQuadCurve(to: CGPoint(x: center.x + 14, y: mouthY - 2), control: CGPoint(x: center.x, y: mouthY + 12))
                        mouth.addLine(to: CGPoint(x: center.x + 11, y: mouthY - 1))
                        mouth.addQuadCurve(to: CGPoint(x: center.x - 11, y: mouthY - 1), control: CGPoint(x: center.x, y: mouthY + 8))
                        mouth.closeSubpath()
                        
                        context.fill(mouth, with: .color(glowYellow))
                    }
                }
            }
            .frame(width: 80, height: 85)
            .scaleEffect(x: facingDirection == .left ? -1 : 1, y: 1)
            
            if let emoji = currentEmoji {
                ThoughtBubbleView(emoji: emoji)
                    .offset(y: -52)
            }
            
            if state.isSleeping {
                SleepingZParticlesView(animationTime: animationTime)
                    .offset(y: -40)
            }
            
            if state.isFlipping {
                SparklesView(animationTime: animationTime)
            }
        }
    }
}

/// Floating warm ember particles for Jack in dark/night mode
struct PumpkinEmberParticlesView: View {
    let animationTime: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                let delay = Double(index) * 0.7
                let progress = (animationTime + delay).truncatingRemainder(dividingBy: 2.5) / 2.5
                let yOffset = -progress * 40.0
                let xOffset = sin(progress * .pi * 2.0 + Double(index)) * 18.0
                let opacity = (1.0 - progress) * 0.85
                
                Circle()
                    .fill(Color(red: 1.0, green: 0.75, blue: 0.2))
                    .frame(width: 5, height: 5)
                    .blur(radius: 1.5)
                    .shadow(color: Color.orange, radius: 4)
                    .offset(x: xOffset, y: yOffset)
                    .opacity(opacity)
            }
        }
    }
}
