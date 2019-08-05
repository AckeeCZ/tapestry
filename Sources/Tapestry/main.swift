import Foundation
import SwiftCLI
import TapestryGen

let generatorCLI = CLI(singleCommand: GenerateCommand())

generatorCLI.goAndExit()
