# Smoltalk

## What is Smoltalk?

Smoltalk is two things:

- a language, based on Smalltalk syntax but heavily-simplified
- a standard library for the Smoltalk language based on Swift

The Smoltalk language and library were developed for use with ZapBot, a Discord chat bot for use on the author's personal servers. Where most Discord bots accept simple commands, it was always intended that ZapBot could instead evaluate expressions in a bespoke scripting language in order to add a bit of flexibility to the command system. Thus, Smoltalk was born.

# Smoltalk: the language

## Basic expressions

Expressions are composed of two parts (or three, if using complex messages):

- the receiver: the object to which you are sending a message
- a selector: the name fo the message
- arguments, if the selector is for a complex message

Smoltalk, like Smalltalk, works by passing messages to objects. Messages come in two types:

### Simple messages

A simple message is a selector, a single string (potentially made up of multiple words concatenated in camelCase). In Smalltalk parlance, this is a unary message.

```
myArray count
```

In the above example, the "count" message was sent to an object called myArray.

### Complex messages

A complex message consists of two parts: firstly, a selector ending with a colon ; secondly, followed by an argument. In Smalltalk parlance, this is a keyword message, with the major difference that complex messages only accept one argument

```
myArray componentsJoinedByString: "hello" 
```

In the above example, the "componentsJoinedByString:" message, accepting a string as an argument, was sent to an object called myArray.

### Selectors

Selectors are alphanumeric strings. Stylistically, the built-in selectors followed Objective-C conventions:

- functions that don't return anything usually contain the name of the action: for example, a selector for a function to read a string aloud might be called "speak"
- functions that return a value usually contain the name of the returned value somewhere: for example, a selector for a function that reverses the characters in a string might be called "reversed**String**"
- functions that return a value by modifying it usually ending in "ing": for example, a selector that for a function that multiplies one number by another might be called "multiply**ing**:"

Your selectors should follow this pattern.

If you send the simple message "selectors" to any object, you will receive a string containing a list of selectors to which the object responds, including type information for arguments and the returned value (if any).

### Inner expressions

It is possible to use the result of an expression as an argument to a complex message.

*But*, I hear you cry, *how can we use the result of expressions if we can't declare variables?* (see the section below, *"Missing" features*)

Well, this is very simple. You can use an inner expression; this is Smoltalk parlance for an inline function call whose return value is used as an argument to another function.

Inner expressions contain full expressions hugged by square brackets: [ and ] — you will be familiar with these if you have used Objective-C, although it isn't necessary to nest square brackets for every single message you would send as it is in Objective-C.

```
myArray componentsJoinedByString: [Date day characters objectAtIndex: 1]
```

In the above example, the inner expression is evaluated first: the "day" message is sent to the Date object, returning a string with the current day; the "characters" message is sent to the resultant string, returning an array of strings representing each character; the complex message "objectAtIndex:" is then sent to the array of characters, returning the character at the index of 1. Imagining the day is Tuesday, this would be "u".

Moving outwards, the complex message "componentsJoinedByString:" is sent to an object called myArray, and that "u", the result of the inner expression, is used as the argument.

You can nest inner expressions as many as you like, although a single error within any of the inner expressions will cause the entire expression to fail.

# Smoltalk: the library

The Smoltalk library is written in Swift and, as such, can be used in Swift projects. The library has two major uses:

- running Smoltalk expressions, bringing a specialised and specific message-passing system to your library or app
- extending your classes to become compatible with Smoltalk

## SMObject

The only types that Smoltalk supports are Swift classes/structs that implement the SMObject protocol.

In turn, SMObject-implementing classes/structs must contain a dictionary constant called "messages". The keys are strings, representing the selectors (not forgetting the colons at the ends of selectors for complex messages); the values are instances of SMSelector.

```
var messages: [String: SMSelector] {
    get {
        return [
            "multipliedByPi": SMSelector(argumentType: SMNull.self, returnType: Double.self) { _, _ in
                return Double(self) * 3.14
            },
            "stringByAppendingString:": SMSelector(argumentType: String.self, returnType: String.self) { arg, _ in
                guard let string = arg else { return nil }
                return "\(self)\(string)"
            }
        ]
    }
}
```

SMObjects are typically used/instantiated in the context of evaluating a Smoltalk expression. However, you can also send messages manually using the sendMessage(selectorString:argument:userInfo:) function.

### SMSelector

SMSelector consists of three values:

- argumentType: Type
- returnType: Type
- function: SMFunction

#### SMFunction

SMFunction is a typealias for a function with the following signature:

(SMObject?, SMObject?) -> SMObject?

The first argument value represents the argument supplied for by calls to complex messages.

The second argument value represents a user info object; this object is passed to **every** SMObject involved in a given expression, provided the messages are passed via SMRuntime (see below).

## SMRuntime

The main way to evaluate full expressions is to use SMRuntime, specifically its static method processExpression(_:customObjectDictionary:userInfo:).

- expression: String
- customObjectDictionary: [String: SMObject]?
- userInfo: SMObject?

The first argument is self-evident. The next two arguments are optional.

Firstly, the customObjectDictionary maps a string representing the name you wish your object to be known by to the runtime to an instance of an object. The reason for specifying your own string rather than using reflection to get the name automatically was born out of making sure that the name *you* want users to type in expressions is used; for example, my submodules in ZapBot all end with "Module", like "TimeModule", but I wanted users to be able to simply type "Time" as the receiver of a message.

You could equally specify multiple strings that map to the same instance. This is probably easiest using shared objects or singletons as the instance. For instance:

```
let customObjectDictionary: [String: SMObject] = [
    "Time": TimeModule.shared,
    "t": TimeModule.shared
]
SMRuntime.processExpression("t selectors", customObjectDictionary, nil)
```

Note that you cannot override the base objects provided by Smoltalk's built-in dictionary of object mappings.

The last argument is a custom object that implements the SMObject protocol. When passed into SMRuntime.processExpression(_:customObjectDictionary:userInfo:), that object is passed to **every object that receives a message** as the expression is evaluated.

In ZapBot, a custom struct implementing SMObject, containing information about the Discord message that triggered ZapBot to start processing the expression, is used. That way, all the SMFunctions have access to information about the message and to the Discord client (by the way, I'm using nuclearace's excellent [SwiftDiscord framework](https://github.com/nuclearace/SwiftDiscord)).

# Dependencies

Smoltalk doesn't depend on anything other than the Swift runtime. The current version uses Swift 4.2.

# Roadmap

- Future versions should make more robust use of Swift's generics system, if possible
- Implementing the "missing" features below

## "Missing" features

Since Smoltalk is currently intended for simple bot commands, there are a number of general programming language features not present in Smoltalk:

- variables
- loops of any kind
- declaring your own classes *in* Smoltalk (currently only possible in Swift)

These may be added at a later date. I would like to add them as Smoltalk might be useful as an education language, either for using or deconstructing how it works.
