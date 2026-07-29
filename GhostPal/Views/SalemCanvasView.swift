import SwiftUI

/// Procedural SwiftUI Canvas View rendering Salem the Black Cat with complete state animations.
struct SalemCanvasView: View {
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
            // Nighttime / Dark Mode Emerald Aura Glow for Salem
            if isNightMode {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.2, green: 0.9, blue: 0.5).opacity(0.4),
                                Color(red: 0.5, green: 0.3, blue: 0.9).opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 55
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 10)
                
                WillOWispParticlesView(animationTime: animationTime)
            }
            
            // Main Salem Canvas
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let center = CGPoint(x: w / 2, y: h / 2 + 5)
                
                // 1. Shadow
                var shadowPath = Path()
                shadowPath.addEllipse(in: CGRect(x: center.x - 22, y: h - 14, width: 44, height: 10))
                context.fill(shadowPath, with: .color(Color.black.opacity(state.isSleeping ? 0.25 : 0.15)))
                
                context.withCGContext { cgContext in
                    let totalRotation = (flipAngle + headTiltAngle) * .pi / 180.0
                    if totalRotation != 0.0 {
                        cgContext.translateBy(x: center.x, y: center.y)
                        cgContext.rotate(by: totalRotation)
                        cgContext.translateBy(x: -center.x, y: -center.y)
                    }
                    
                    // 2. Swishing Cat Tail
                    var tailPath = Path()
                    let tailBase = CGPoint(x: center.x - 18, y: center.y + 12)
                    let tailSway = sin(animationTime * 4.0) * 12.0
                    
                    tailPath.move(to: tailBase)
                    tailPath.addQuadCurve(
                        to: CGPoint(x: tailBase.x - 16 + tailSway, y: tailBase.y - 20),
                        control: CGPoint(x: tailBase.x - 24, y: tailBase.y - 6)
                    )
                    context.stroke(
                        tailPath,
                        with: .color(Color(white: 0.12)),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    
                    // 3. Cat Body Path (Black Cat Silhouette)
                    let bodyRect = CGRect(x: center.x - 24, y: center.y - 28, width: 48, height: 52)
                    var bodyPath = Path()
                    
                    // Head dome
                    let headRadius: CGFloat = 24
                    let headCenter = CGPoint(x: center.x, y: bodyRect.minY + headRadius)
                    bodyPath.addArc(center: headCenter, radius: headRadius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                    
                    // Body sides
                    bodyPath.addLine(to: CGPoint(x: headCenter.x + headRadius, y: bodyRect.maxY - 8))
                    bodyPath.addQuadCurve(
                        to: CGPoint(x: headCenter.x - headRadius, y: bodyRect.maxY - 8),
                        control: CGPoint(x: headCenter.x, y: bodyRect.maxY + 4)
                    )
                    bodyPath.addLine(to: CGPoint(x: headCenter.x - headRadius, y: headCenter.y))
                    bodyPath.closeSubpath()
                    
                    context.fill(bodyPath, with: .color(Color(white: 0.12)))
                    
                    // 4. Pointy Cat Ears
                    var leftEar = Path()
                    leftEar.move(to: CGPoint(x: center.x - 22, y: center.y - 18))
                    leftEar.addLine(to: CGPoint(x: center.x - 14, y: center.y - 38))
                    leftEar.addLine(to: CGPoint(x: center.x - 4, y: center.y - 24))
                    leftEar.closeSubpath()
                    context.fill(leftEar, with: .color(Color(white: 0.12)))
                    
                    // Inner Left Ear (Pink)
                    var leftInnerEar = Path()
                    leftInnerEar.move(to: CGPoint(x: center.x - 19, y: center.y - 20))
                    leftInnerEar.addLine(to: CGPoint(x: center.x - 14, y: center.y - 33))
                    leftInnerEar.addLine(to: CGPoint(x: center.x - 7, y: center.y - 24))
                    leftInnerEar.closeSubpath()
                    context.fill(leftInnerEar, with: .color(Color(red: 0.95, green: 0.65, blue: 0.75)))
                    
                    var rightEar = Path()
                    rightEar.move(to: CGPoint(x: center.x + 4, y: center.y - 24))
                    rightEar.addLine(to: CGPoint(x: center.x + 14, y: center.y - 38))
                    rightEar.addLine(to: CGPoint(x: center.x + 22, y: center.y - 18))
                    rightEar.closeSubpath()
                    context.fill(rightEar, with: .color(Color(white: 0.12)))
                    
                    // Inner Right Ear (Pink)
                    var rightInnerEar = Path()
                    rightInnerEar.move(to: CGPoint(x: center.x + 7, y: center.y - 24))
                    rightInnerEar.addLine(to: CGPoint(x: center.x + 14, y: center.y - 33))
                    rightInnerEar.addLine(to: CGPoint(x: center.x + 19, y: center.y - 20))
                    rightInnerEar.closeSubpath()
                    context.fill(rightInnerEar, with: .color(Color(red: 0.95, green: 0.65, blue: 0.75)))
                    
                    // 5. Red Collar & Golden Bell
                    var collar = Path()
                    collar.addRoundedRect(
                        in: CGRect(x: center.x - 18, y: center.y + 4, width: 36, height: 5),
                        cornerSize: CGSize(width: 2.5, height: 2.5)
                    )
                    context.fill(collar, with: .color(Color(red: 0.9, green: 0.25, blue: 0.2)))
                    
                    var bell = Path(ellipseIn: CGRect(x: center.x - 3.5, y: center.y + 6.5, width: 7, height: 7))
                    context.fill(bell, with: .color(Color(red: 1.0, green: 0.84, blue: 0.1)))
                    
                    // 6. Whiskers (White/Light Gray)
                    let whiskerColor = Color(white: 0.85).opacity(0.65)
                    var whiskers = Path()
                    // Left whiskers
                    whiskers.move(to: CGPoint(x: center.x - 10, y: center.y - 4))
                    whiskers.addLine(to: CGPoint(x: center.x - 28, y: center.y - 8))
                    whiskers.move(to: CGPoint(x: center.x - 10, y: center.y - 2))
                    whiskers.addLine(to: CGPoint(x: center.x - 30, y: center.y - 2))
                    whiskers.move(to: CGPoint(x: center.x - 10, y: center.y))
                    whiskers.addLine(to: CGPoint(x: center.x - 28, y: center.y + 4))
                    
                    // Right whiskers
                    whiskers.move(to: CGPoint(x: center.x + 10, y: center.y - 4))
                    whiskers.addLine(to: CGPoint(x: center.x + 28, y: center.y - 8))
                    whiskers.move(to: CGPoint(x: center.x + 10, y: center.y - 2))
                    whiskers.addLine(to: CGPoint(x: center.x + 30, y: center.y - 2))
                    whiskers.move(to: CGPoint(x: center.x + 10, y: center.y))
                    whiskers.addLine(to: CGPoint(x: center.x + 28, y: center.y + 4))
                    
                    context.stroke(whiskers, with: .color(whiskerColor), lineWidth: 1.2)
                    
                    // 7. Waving Cat Paw (Maneki-Neko wave)
                    if state == .waving {
                        let waveAngle = sin(animationTime * 7.0) * 0.35
                        let pawBase = CGPoint(x: center.x + 18, y: center.y - 2)
                        
                        cgContext.translateBy(x: pawBase.x, y: pawBase.y)
                        cgContext.rotate(by: waveAngle)
                        
                        var raisedPaw = Path()
                        raisedPaw.addRoundedRect(
                            in: CGRect(x: 0, y: -14, width: 9, height: 16),
                            cornerSize: CGSize(width: 4.5, height: 4.5)
                        )
                        context.fill(raisedPaw, with: .color(Color(white: 0.12)))
                        
                        cgContext.rotate(by: -waveAngle)
                        cgContext.translateBy(x: -pawBase.x, y: -pawBase.y)
                    }
                    
                    // 8. Eyes & Expression
                    let eyeY = center.y - 12
                    let currentEyeX = eyeOffsetX
                    
                    if state.isSleeping {
                        // Closed sleeping cat eyes (u u)
                        var leftEye = Path()
                        leftEye.addArc(
                            center: CGPoint(x: center.x - 11, y: eyeY),
                            radius: 4,
                            startAngle: .degrees(0),
                            endAngle: .degrees(180),
                            clockwise: false
                        )
                        context.stroke(leftEye, with: .color(Color(red: 0.3, green: 0.9, blue: 0.5)), lineWidth: 2.2)
                        
                        var rightEye = Path()
                        rightEye.addArc(
                            center: CGPoint(x: center.x + 11, y: eyeY),
                            radius: 4,
                            startAngle: .degrees(0),
                            endAngle: .degrees(180),
                            clockwise: false
                        )
                        context.stroke(rightEye, with: .color(Color(red: 0.3, green: 0.9, blue: 0.5)), lineWidth: 2.2)
                    } else if state.isStartled {
                        // Startled wide glowing eyes (O o O)
                        let leftEyeRect = CGRect(x: center.x - 16, y: eyeY - 7, width: 11, height: 13)
                        let rightEyeRect = CGRect(x: center.x + 5, y: eyeY - 7, width: 11, height: 13)
                        
                        let emerald = Color(red: 0.2, green: 0.95, blue: 0.45)
                        context.fill(Path(ellipseIn: leftEyeRect), with: .color(emerald))
                        context.fill(Path(ellipseIn: rightEyeRect), with: .color(emerald))
                        
                        // Tiny pin-prick pupils
                        let leftPupil = CGRect(x: leftEyeRect.midX - 1.5, y: leftEyeRect.midY - 4, width: 3, height: 8)
                        let rightPupil = CGRect(x: rightEyeRect.midX - 1.5, y: rightEyeRect.midY - 4, width: 3, height: 8)
                        context.fill(Path(ellipseIn: leftPupil), with: .color(Color(white: 0.08)))
                        context.fill(Path(ellipseIn: rightPupil), with: .color(Color(white: 0.08)))
                        
                        // Cute cat mouth (w)
                        var mouth = Path()
                        mouth.move(to: CGPoint(x: center.x - 4, y: center.y - 2))
                        mouth.addQuadCurve(to: CGPoint(x: center.x, y: center.y), control: CGPoint(x: center.x - 2, y: center.y + 2))
                        mouth.addQuadCurve(to: CGPoint(x: center.x + 4, y: center.y - 2), control: CGPoint(x: center.x + 2, y: center.y + 2))
                        context.stroke(mouth, with: .color(Color.pink.opacity(0.8)), lineWidth: 1.5)
                    } else {
                        // Glowing Emerald Almond Cat Eyes
                        let leftEyeRect = CGRect(x: center.x - 15 + currentEyeX, y: eyeY - 6, width: 9, height: 12)
                        let rightEyeRect = CGRect(x: center.x + 6 + currentEyeX, y: eyeY - 6, width: 9, height: 12)
                        
                        let emerald = Color(red: 0.25, green: 0.95, blue: 0.45)
                        context.fill(Path(ellipseIn: leftEyeRect), with: .color(emerald))
                        context.fill(Path(ellipseIn: rightEyeRect), with: .color(emerald))
                        
                        // Vertical cat pupils
                        let leftPupil = CGRect(x: leftEyeRect.midX - 1.5, y: leftEyeRect.minY + 2, width: 3, height: 8)
                        let rightPupil = CGRect(x: rightEyeRect.midX - 1.5, y: rightEyeRect.minY + 2, width: 3, height: 8)
                        context.fill(Path(ellipseIn: leftPupil), with: .color(Color(white: 0.08)))
                        context.fill(Path(ellipseIn: rightPupil), with: .color(Color(white: 0.08)))
                        
                        // White shine highlights
                        let leftShine = CGRect(x: leftEyeRect.minX + 1.5, y: leftEyeRect.minY + 2, width: 2.5, height: 3.5)
                        let rightShine = CGRect(x: rightEyeRect.minX + 1.5, y: rightEyeRect.minY + 2, width: 2.5, height: 3.5)
                        context.fill(Path(ellipseIn: leftShine), with: .color(.white))
                        context.fill(Path(ellipseIn: rightShine), with: .color(.white))
                        
                        // Cute cat nose (pink triangle)
                        var nose = Path()
                        nose.move(to: CGPoint(x: center.x - 2.5, y: center.y - 4))
                        nose.addLine(to: CGPoint(x: center.x + 2.5, y: center.y - 4))
                        nose.addLine(to: CGPoint(x: center.x, y: center.y - 1))
                        nose.closeSubpath()
                        context.fill(nose, with: .color(Color(red: 1.0, green: 0.65, blue: 0.75)))
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
