
import PlaygroundSupport
import SwiftUI

struct framePreferenceKey: PreferenceKey {
    static var defaultValue = CGRect()
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension CGSize{
    func length() -> CGFloat{
        sqrt(width * width + height * height)
    }
    
    mutating func rotate(_ a: CGFloat) {
        
        let x = width * cos(a) - height * sin(a)
        let y = width * sin(a) + height * cos(a)
        
        self = CGSize(width: x, height: y)
        
    }
    
    mutating func randomizeAngle(_ rnd: CGFloat) {
        
        let a = CGFloat.random(in: -rnd...rnd)
        
        self.rotate(a)
        
    }
    
    static func +=(lhs: inout CGSize, rhs: CGSize) {
        lhs = CGSize(
            width: lhs.width + rhs.width,
            height: lhs.height + rhs.height
        )
    }
    
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize{
        CGSize(
            width: lhs.width + rhs.width,
            height: lhs.height + rhs.height
        )
    }
    
    static func -(lhs: CGSize, rhs: CGSize) -> CGSize{
        CGSize(
            width: lhs.width - rhs.width,
            height: lhs.height - rhs.height
        )
    }
    
    static func  *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs,
               height: lhs.height * rhs)
    }
    
    static func  +(lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width + rhs,
               height: lhs.height + rhs)
    }
    
}

struct JoystickView: View {
    
    init(offset: Binding<CGSize>, isTapped: Binding<Bool>, maxRadius: CGFloat){
        
        self._offset = offset
        self._isTapped = isTapped
        self.maxRadius = maxRadius
        
    }
    
    let maxRadius : CGFloat
    
    @Binding var offset: CGSize
    @Binding var isTapped: Bool
    
    @State var gestureLocation = CGSize(width: 0, height: 0)
    @State var startLocation = CGSize(width: 0, height: 0)
    @State var joystickFrame = CGRect()
    
    var body: some View{
        ZStack{
            if isTapped{
                ZStack{ 
                    Circle()
                        .fill(RadialGradient(gradient: Gradient(colors: [.clear, .white]), center: .center, startRadius: 0, endRadius: maxRadius * 1.5))
                        .frame(width: maxRadius * 3, height: maxRadius * 3)
                        .opacity(0.5)
                        .offset(startLocation)
                    Circle()
                        .fill(RadialGradient(gradient: Gradient(colors: [.white, .gray]), center: .center, startRadius: 0, endRadius: maxRadius/2))
                        .frame(width: maxRadius, height: maxRadius)
                        .shadow(radius: 5)
                        .offset(gestureLocation)
                }
            }
            Color.clear
                .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance:0, coordinateSpace:.global)
                    .onChanged { gesture in
                        
                        if !isTapped { 
                            isTapped = true
                            
                            let startWidth = gesture.startLocation.x - joystickFrame.minX - joystickFrame.width/2
                            let startHeight = gesture.startLocation.y - joystickFrame.minY - joystickFrame.height/2
                            startLocation = CGSize(width: startWidth,
                                                   height: startHeight)
                        }
                        
                        var x = gesture.translation.width 
                        var y = gesture.translation.height 
                        
                        var r = gesture.translation.length()
                        
                        if r > maxRadius{
                            let q = maxRadius / r
                            x *= q
                            y *= q
                        }
                        
                        let gestLocX = gesture.startLocation.x + x - joystickFrame.minX - joystickFrame.width/2
                        let gestLocY = gesture.startLocation.y + y - joystickFrame.minY - joystickFrame.height/2
                        
                        offset = CGSize(width: x, height: y)
                        gestureLocation = CGSize(width: gestLocX, height: gestLocY)
 
                    }
                    .onEnded { _ in
                        
                        offset = .zero
                        isTapped = false
                        
                    }
            )
                .overlay(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: framePreferenceKey.self, value: geo.frame(in:.global))
                    }.onPreferenceChange(framePreferenceKey.self){self.joystickFrame = $0}
                )
            }.clipShape(Rectangle())
        }
    }
//======================================================================
//Game!

struct GameView: View {
    
    struct Position {
        var coords : CGSize = .zero
        var angle : Double = 0
        var speed = CGSize()
        var time : Double = 1
    }
    
    func newEnemy() {
        
        var speed = CGSize(width: enemySpeed, height: 0)
        speed.randomizeAngle(2 * CGFloat.pi)
        
        let enemy = Position(coords: newPosition(maxOffset),
                             speed: speed,
                             time: 1)
        enemies.append(enemy)
    }
    
    func newPosition(_ maxOffset: CGSize) -> CGSize {
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        while (CGSize(width: x, height: y) - coords).length() < gameObjRadius*5 {
            x = CGFloat.random(in: -maxOffset.width...maxOffset.width)
            y = CGFloat.random(in: -maxOffset.height...maxOffset.height)
        }
        
        return CGSize(width: x, height: y)
    }
    
    func getReady(){
        enemies = []
        for i in 0..<enemyCount{ newEnemy() }
        
        tail = [Position](repeating: Position(coords: coords, angle: angle, time: 0), count: tailSize)
        
        let time = CFAbsoluteTimeGetCurrent()
        
        coordsFood = newPosition(maxOffset)
        foodTimer = time
        foodAngleSpeed = foodAngleSpeedDefault * 10
        newFood = true
    }
    
    var timer = Timer.publish(every: 0.005, tolerance: 0, on: .current, in: .common).autoconnect()
    
    let tailCount = 5
    let tailSize = 20
    let tailFadeSpeed = 0.05
    let tailFluctuation : CGFloat = 10
    let tailTransparency : Double = 0.5
    
    let joystickRadius : CGFloat = 100
    
    let speed : CGFloat = 0.05
    let jetPower : CGFloat = 0.02
    
    let enemySpeed : CGFloat = 1.5
    let enemySpeedRND : CGFloat = 0.5
    let enemyCount = 3
    
    let foodTime : CFAbsoluteTime = 3
    let foodAngleSpeedDefault = 0.01
    
    let gameObjRadius : CGFloat = 30
    
    @State var explosion : CGFloat = -1
    
    @State var deathEnemy = -1
    @State var gameOver = false
    @State var score = 0
    
    @State var foodTimer = CFAbsoluteTimeGetCurrent()
    @State var enemyTimer = CFAbsoluteTimeGetCurrent()
    
    @State var enemies : [Position] = []
    
    @State var maxOffset = CGSize()
    @State var tailIndex = 0
    @State var counter = 0
    @State var tail : [Position] = []
    @State var offset : CGSize = .zero
    @State var angle : Double = 0
    @State var isTapped = false
    @State var gameFrame = CGRect()
    
    @State var coords : CGSize = .zero
    
    @State var coordsFood : CGSize = .zero
    @State var angleFood : Double = 0
    @State var foodAngleSpeed : Double = 0
    @State var newFood = false
    @State var foodSize = CGFloat()
    
    var body: some View{
        if !gameOver{ 
            VStack{
                VStack{
                    HStack{
                        Text("SCORE: \(score)").font(.headline)
                        Spacer()
                    }
                    
                }
                ZStack{ 
                    //======================================================================
                    //Background
                    ZStack{ 
                    AngularGradient(gradient: 
                                        Gradient(colors: [.green, .clear, .green, .clear, .green, .clear, .green, .clear, .green, .clear]), center: .center)
                        .scaleEffect(6)
                        .rotationEffect(Angle(degrees: Double(coords.width/gameFrame.width)*2))
                        .offset(CGSize(width: gameFrame.width/3, height: -gameFrame.width/3))
                    AngularGradient(gradient: 
                                        Gradient(colors: [.green, .clear, .green, .clear, .green, .clear, .green, .clear, .green, .clear, .green]), center: .center)
                        .scaleEffect(5)
                        .rotationEffect(Angle(degrees: Double(coords.width/gameFrame.width)*5))
                        .offset(CGSize(width: -gameFrame.width/3, height: gameFrame.width/3))
                        .opacity(1)
                        .blendMode(.difference)
                    }.blur(radius: 10)
                    Rectangle()
                        .fill(Color(red: 0, green: 0, blue: 0.7))
                    //.opacity(0.5)
                        .blendMode(.colorBurn)
                    //======================================================================
                    //Food
                    ZStack{ 
                        Circle()
                            .fill(RadialGradient(gradient:
                                                    Gradient(colors: [.black, .blue, .black]),
                                                 center: .center, 
                                                 startRadius: 0,
                                                 endRadius: gameObjRadius*1.5))
                            .frame(width: foodSize*2.5, height: foodSize*2.5)
                        Ellipse()
                            .fill(RadialGradient(gradient:
                                                    Gradient(colors: [.white,.purple, .black]),
                                                 center: .center, 
                                                 startRadius: 0,
                                                 endRadius: gameObjRadius*1.5))
                            .frame(width: gameObjRadius*2, height: gameObjRadius*0.7)
                            .rotationEffect(Angle(radians: angleFood),
                                            anchor: .center)
                            .shadow(radius: 2)
                            //Food logic
                            .onReceive(timer){_ in
                                let time = CFAbsoluteTimeGetCurrent()
                                let timer = time - foodTimer
                                // Eat!
                                if abs(coords.width - coordsFood.width) < gameObjRadius &&
                                    abs(coords.height - coordsFood.height) < gameObjRadius {
                                    
                                    coordsFood = newPosition(maxOffset)
                                    
                                    score += Int(timer / foodTime * 100)
                                    foodTimer = time
                                    
                                    foodAngleSpeed *= 50
                                    foodSize = 0
                                    newFood = true
                                }
                                
                                // Timer is just began
                                if newFood {
                                    withAnimation{
                                        newFood.toggle()
                                        foodSize = gameObjRadius
                                    }
                                }
                                
                                // Time is almost up!
                                if timer / foodTime > 0.7{
                                    foodAngleSpeed *= 1.02
                                    foodSize *= 0.999
                                }else{
                                    if foodAngleSpeed > foodAngleSpeedDefault{
                                        foodAngleSpeed /= 1.02 
                                    }
                                }
                                
                                // Time is up!
                                if timer > foodTime{
                                    
                                    foodTimer = time
                                    coordsFood = newPosition(maxOffset)
                                    newFood = true
                                }
                                
                                angleFood += foodAngleSpeed
                                if angleFood > 2 * Double.pi{ angleFood = 0}
                            }
                    }.offset(coordsFood)
                    //======================================================================
                        //Enemies!
                    ForEach(enemies.indices, id: \.self){ id in
                        if !(id == deathEnemy){
                        ZStack{
                            ForEach(0..<10){ i in
                                Capsule()
                                    .fill(LinearGradient(gradient: Gradient(colors: [.black, .white, .black]), startPoint: .leading, endPoint: .trailing))
                                    .frame(width: gameObjRadius*2, height: gameObjRadius*2)
                                    .scaleEffect(x: 0.2,
                                                 y: 1.5,
                                                 anchor: .init(x: 0.5, y: 1))
                                    .rotationEffect(Angle(degrees: Double(36 * i)))
                            }
                            Circle()
                                .fill(RadialGradient(gradient:
                                                        Gradient(colors: [.black, .red, .black]),
                                                     center: .center, 
                                                     startRadius: 0,
                                                     endRadius: gameObjRadius*1.5))
                                .shadow(radius:20)
                            
                        }
                            .frame(width: gameObjRadius*2.5, height: gameObjRadius*2.5)
                            .offset(enemies[id].coords)
                            //Enemie logic
                            .onReceive(timer){time in
                                if deathEnemy > -1 {return }
                                var enemy = enemies[id]
                                
                                enemy.coords += enemy.speed
                                enemy.speed.rotate(0.005)
                                
                                if abs(enemy.coords.width) > maxOffset.width {
                                    enemy.speed.width *= -1
                                    if abs(enemy.speed.width/enemy.speed.height) > 0.2
                                        {enemy.speed.randomizeAngle(enemySpeedRND)
                                    }
                                }
                                if abs(enemy.coords.height) > maxOffset.height {
                                    enemy.speed.height *= -1 
                                    if abs(enemy.speed.height/enemy.speed.width) > 0.2 {enemy.speed.randomizeAngle(enemySpeedRND)
                                    }
                                }
                                
                                if (enemy.coords - coords).length() < gameObjRadius * 2{
                                    deathEnemy = id
                                }
                                
                                enemies[id] = enemy
                            }
                        }
                    }
                    //======================================================================
                    //Explosion
                    if deathEnemy > -1{
                        Circle()
                            .fill(RadialGradient(gradient: Gradient(colors: [.clear, .red, .yellow, .clear]), center: UnitPoint(x: 0.5, y: 0.5), startRadius: explosion/50, endRadius: explosion/5))
                            .scaleEffect(explosion)
                            .offset(enemies[deathEnemy].coords)
                            .onReceive(timer){_ in
                                
                                if explosion == -1{ 
                                    explosion = 0
                                }else{
                                    if explosion < maxOffset.length()/2{ 
                                        explosion += 1
                                    }else{
                                        gameOver.toggle()
                                    }
                                    }
                                var speed = CGSize()
                                for id in 0..<tail.endIndex{
                                    let a = (CGFloat(id) / CGFloat(tail.endIndex)) * CGFloat.pi * 2
                                    speed = CGSize(width: 0, height: -explosion)
                                    speed.rotate(a)
                                    tail[id] = Position(coords: 
                                                            CGSize(width: coords.width + CGFloat.random(in: -tailFluctuation...tailFluctuation)+speed.width*5,
                                                                   height: coords.height + CGFloat.random(in: -tailFluctuation...tailFluctuation)+speed.height*5),
                                                        angle: Double(a),
                                                        speed: speed,
                                                        time: 1)
                                }
                            }
                    }
                    //======================================================================
                        //Tail
                    ForEach(tail.indices, id: \.self){ id in
                            RadialGradient(gradient:
                                                    Gradient(colors: [.yellow, .clear]),
                                                 center: .center, 
                                                 startRadius: 0,
                                                 endRadius: gameObjRadius)
                            .frame(width: gameObjRadius*2, height: gameObjRadius*2)
                                .scaleEffect(x: 1,
                                             y: 1 + tail[id].speed.length()*jetPower,
                                             anchor: .init(x: 0.5, y: 0))
                                .rotationEffect(Angle(radians: tail[id].angle))
                            .offset(tail[id].coords)
                            .opacity(tail[id].time * tailTransparency)
                    }
                    //Head
                    if explosion < 0{ 
                        Circle()
                            .fill(RadialGradient(gradient: Gradient(colors: [.white, .red, .blue]), center: .center, startRadius: 0, endRadius: gameObjRadius))
                            .frame(width: gameObjRadius*2, height: gameObjRadius*2)
                            .overlay(
                                Capsule(style: RoundedCornerStyle.circular)
                                    .fill(Color.white)
                                    .frame(width: gameObjRadius / 2, height: gameObjRadius / 1.5)
                                , alignment: .top)
                            .rotationEffect(Angle(radians: angle),
                                            anchor: .center)
                            .offset(coords)
                    }
                    //Head logic
                }.onReceive(timer){time in
                    
                    if deathEnemy > -1 {return }
                    
                    let newCoords = coords + offset * speed
                                           
                    if abs(newCoords.width) < maxOffset.width {
                        coords.width = newCoords.width
                    }
                    if abs(newCoords.height) < maxOffset.height {
                        coords.height = newCoords.height
                    }
                    
                    let pi = Double.pi
                    let length = offset.length()
                    
                    if length > 0{
                        let newAngle = Double(atan2(offset.height, offset.width)) + pi / 2
                        var deltaAngle = newAngle - angle.truncatingRemainder(dividingBy: 2 * pi)
                        if deltaAngle > pi{
                            deltaAngle = deltaAngle - 2 * pi
                        }
                        if deltaAngle < -pi{
                            deltaAngle = deltaAngle + 2 * pi
                        }
                        angle += deltaAngle
                    }
                    
                    counter += 1
                    if counter>tailCount{
                        counter = 0
                        for i in tail.indices{
                            tail[i].time -= tailFadeSpeed
                        }
                        tailIndex += 1
                        if tailIndex == tail.endIndex{
                            tailIndex = 0
                        }
                        
                        if length > 0 { 
                            tail[tailIndex] = Position(coords: 
                                                            CGSize(width: coords.width + CGFloat.random(in: -tailFluctuation...tailFluctuation),
                                                                   height: coords.height + CGFloat.random(in: -tailFluctuation...tailFluctuation)),
                                                        angle: angle, speed: offset, time: 1)
                        }
                    }
                    
                }.clipShape(Rectangle())
                .overlay(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: framePreferenceKey.self, value: geo.frame(in:.global))
                    }.onPreferenceChange(framePreferenceKey.self){
                        //window size changed!
                        self.gameFrame = $0
                        coords = .zero
                        
                        let x = gameFrame.width/2 - gameObjRadius
                        let y = gameFrame.height/2 - gameObjRadius
                        maxOffset = CGSize(width: x, height: y)
                    }
                )
                
            }.overlay(
                JoystickView(offset: $offset, isTapped: $isTapped, maxRadius: joystickRadius)
                    .opacity(0.2)
                    .foregroundColor(.accentColor)
                ,alignment: .bottomTrailing)
            .drawingGroup()
            .onAppear(){
                //get ready!!
                getReady()
            }
        }else{
            ZStack{ 
                Color.clear
                VStack{
                    Text("GAME OVER").font(.largeTitle).foregroundColor(.red)
                    Text("Your Score: \(score)").font(.title).foregroundColor(.yellow)
                    Text("Tap to play once more").font(.caption2)
                
                }
            }.contentShape(Rectangle())
            .onTapGesture {
                // New Game
                gameOver.toggle()
                deathEnemy = -1
                explosion = -1
                score = 0
            }
            .transition(AnyTransition.opacity.animation(.easeIn(duration: 1)))
        }
    }
}

PlaygroundPage.current.setLiveView(GameView())
