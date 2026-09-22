//
//  CommandProcessor.swift
//  Classic Assistant
//
//  A small, easy-to-extend command registry. Add a new Command to
//  `CommandProcessor.builtins` to support a new phrase — no other file
//  needs to change.
//

import Foundation

struct CommandResult {
    let text: String
    /// Set when the command should also change app state (e.g. open Settings).
    var effect: (() -> Void)? = nil
}

struct Command {
    let id: String
    let examples: [String]
    let match: (String) -> Bool
    let run: (String) -> CommandResult
}

@MainActor
final class CommandProcessor {

    static let unknownReply = "I don't know how to do that yet."

    private var lastJokeIndex = -1
    private let jokes = [
        "Why don't scientists trust atoms? Because they make up everything.",
        "Why did the scarecrow win an award? He was outstanding in his field.",
        "What do you call a fake noodle? An impasta.",
        "Why was the computer cold? It left its Windows open.",
        "What did the ocean say to the beach? Nothing, it just waved."
    ]

    var onOpenSettings: (() -> Void)?
    var onGoHome: (() -> Void)?
    var onClearConversation: (() -> Void)?
    var isSettingsOpen: () -> Bool = { false }

    private lazy var commands: [Command] = [
        Command(id: "greeting", examples: ["Hello", "Hi"],
                match: { $0.matches(#"^(hello|hi|hey|howdy)( there)?$"#) },
                run: { _ in CommandResult(text: "Hello! How can I help?") }),

        Command(id: "time", examples: ["What time is it?"],
                match: { $0.contains("what time is it") || $0.contains("current time") },
                run: { _ in
                    let f = DateFormatter(); f.timeStyle = .short
                    return CommandResult(text: "It's \(f.string(from: Date())).")
                }),

        Command(id: "date", examples: ["What's today's date?"],
                match: { $0.contains("today") && ($0.contains("date") || $0.contains("day")) },
                run: { _ in
                    let f = DateFormatter(); f.dateStyle = .full
                    return CommandResult(text: "Today is \(f.string(from: Date())).")
                }),

        Command(id: "who", examples: ["Who are you?"],
                match: { $0.contains("who are you") || $0.contains("what are you") },
                run: { _ in CommandResult(text: "I'm Classic Assistant, a voice assistant inspired by the look of assistants past. Try asking me the time, or for a joke.") }),

        Command(id: "joke", examples: ["Tell me a joke"],
                match: { $0.contains("joke") || $0.contains("something funny") },
                run: { [self] _ in
                    var i: Int
                    repeat { i = Int.random(in: 0..<jokes.count) } while jokes.count > 1 && i == lastJokeIndex
                    lastJokeIndex = i
                    return CommandResult(text: jokes[i])
                }),

        Command(id: "settings", examples: ["Open settings"],
                match: { $0.matches(#"^(open |show |go to )?(the )?settings( screen| menu)?$"#) },
                run: { [self] _ in CommandResult(text: "Opening settings.", effect: { self.onOpenSettings?() }) }),

        Command(id: "home", examples: ["Go home"],
                match: { $0.matches(#"^(go home|home|go back|back|close settings|done)$"#) },
                run: { [self] _ in
                    if isSettingsOpen() {
                        return CommandResult(text: "Going home.", effect: { self.onGoHome?() })
                    }
                    return CommandResult(text: "You're already home.")
                }),

        Command(id: "clear", examples: ["Clear conversation"],
                match: { $0.matches(#"^(clear|delete|erase|reset)( the| my)?( conversation| chat| history)$"#) },
                run: { [self] _ in CommandResult(text: "Conversation cleared.", effect: { self.onClearConversation?() }) })
    ]

    var allExamples: [String] { commands.flatMap { $0.examples } }

    func run(_ raw: String) -> CommandResult {
        let normalized = raw.normalizedForMatching
        for command in commands {
            if command.match(normalized) {
                return command.run(normalized)
            }
        }
        return CommandResult(text: Self.unknownReply)
    }
}

private extension String {
    var normalizedForMatching: String {
        self.lowercased()
            .replacingOccurrences(of: "'", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    func matches(_ pattern: String) -> Bool {
        (try? NSRegularExpression(pattern: pattern))
            .map { $0.firstMatch(in: self, range: NSRange(startIndex..., in: self)) != nil } ?? false
    }
}
