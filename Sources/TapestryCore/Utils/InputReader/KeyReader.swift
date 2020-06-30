import Foundation

/// Key events that the KeyReader delivers.
///
/// - up: Delivered when the K or the Up key is pressed.
/// - down: Delivered when the J or the Down key is pressed.
/// - exit: Delivered when combination of keys Control+C is pressed.
/// - select: Delivered when the Enter key is pressed.
enum KeyEvent {
    case up
    case down
    case exit
    case select
}

/// Protocol that defines the interface for subscribing
/// to key events
protocol KeyReading {
    /// Subscribes to key events. It blocks the thread until an exit or enter event is delivered.
    ///
    /// - Parameter subscriber: Function to notify new key events through.
    func subscribe(subscriber: @escaping (KeyEvent) -> Void)
}

class KeyReader: KeyReading {
    /// Subscribes to key events. It blocks the thread until an exit or enter event is delivered.
    ///
    /// - Parameter subscriber: Function to notify new key events through.
    func subscribe(subscriber: @escaping (KeyEvent) -> Void) {
        let fileHandle = FileHandle.standardInput
        let originalTerm = enableRawMode(fileHandle: fileHandle)
        defer {
            restoreRawMode(fileHandle: fileHandle, originalTerm: originalTerm)
        }
        var char: UInt8 = 0

        while read(fileHandle.fileDescriptor, &char, 1) == 1 {
            if char == 0x6A || char == 0x42 { // up
                subscriber(.down)
            } else if char == 0x6B || char == 0x41 { // down
                subscriber(.up)
            } else if char == 0x0A { // enter
                subscriber(.select)
                break
            } else if char == 0x04 { // detect EOF (Ctrl+D)
                subscriber(.exit)
                break
            }
        }
    }

    // MARK: - Fileprivate

    // https://stackoverflow.com/questions/49748507/listening-to-stdin-in-swift
    // https://stackoverflow.com/questions/24146488/swift-pass-uninitialized-c-structure-to-imported-c-function/24335355#24335355
    fileprivate func initStruct<S>() -> S {
        let struct_pointer = UnsafeMutablePointer<S>.allocate(capacity: 1)
        let struct_memory = struct_pointer.pointee
        struct_pointer.deallocate()
        return struct_memory
    }

    fileprivate func enableRawMode(fileHandle: FileHandle) -> termios {
        var raw: termios = initStruct()
        tcgetattr(fileHandle.fileDescriptor, &raw)

        let original = raw

        raw.c_lflag &= ~(UInt(ECHO | ICANON))
        tcsetattr(fileHandle.fileDescriptor, TCSAFLUSH, &raw)

        return original
    }

    fileprivate func restoreRawMode(fileHandle: FileHandle, originalTerm: termios) {
        var term = originalTerm
        tcsetattr(fileHandle.fileDescriptor, TCSAFLUSH, &term)
    }
}
