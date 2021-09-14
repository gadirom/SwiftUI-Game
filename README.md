# SwiftUI Game
A little arcade game that uses SwiftUI as a game engine :)
 
<p align="center">
    <img src="https://img.shields.io/badge/platforms-iOS_14_-blue.svg" alt="iPadOS" />
    <a href="https://swift.org/about/#swiftorg-and-open-source"><img src="https://img.shields.io/badge/Swift-5.3-orange.svg" alt="Swift 5.3" /></a>
    <a href="https://developer.apple.com/metal/"><img src="https://img.shields.io/badge/SwiftUI-2.0-green.svg" alt="SwiftUI 2.0" /></a>
    <a href="https://apps.apple.com/ru/app/swift-playgrounds/id908519492?l=en"><img src="https://img.shields.io/badge/SwiftPlaygrounds-3.4.1-orange.svg" alt="Swift Playgrounds 3" /></a>
   <a href="https://en.wikipedia.org/wiki/MIT_License"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT" /></a>
<p align="center">
   <img src="assets/4611A540-4621-411F-BE1B-79090B63194A.jpeg" alt="Video"/>
</p>    
</p> 

Just copy the code into the Blank playgroundbook in Swift Playgrounds app on iPad or Mac and run it!

Do not forget to turn off Enable Results in the settings of the playgroundbook, otherwise the game will not run.

For some reason the code will not run in an Xcode Playgroud. I've created an issue.

## Notes

This isn't the most beautiful Swift code. I made it just for fun and to learn a couple of things about SwiftUI.
I think a videogame is a good crash test for any UI framework :)
All the game logic (as well as almost all the animations) are done manually by changing `@State` vars in `onReceive` callbacks from the `Timer`.
Sometimes you may see glitches that are most likely caused by imperfect threading.
