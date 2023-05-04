# OpenAISwiftDI

OpenAI + Swift + Dependecy Injection

OpenAISwiftDI is a Swift is a community maintained package to communicate with [OpenAI API](https://platform.openai.com/docs/introduction) this package will use Dependecy Injection to facilitate development of a client-side application while waiting for a server-side environment.

⚠️ OpenAI advises that the API key is not included in client-side applications, requests should be processed through a backend service. 

The `Package` includes a `URLSession` based `Provider` that serves as a starting point but is not intended for Production environments. It works with the API but does not abide by all the best practices set forth by OpenAI.

The package's `Request` models all have a `validate()` that is capable of doing basic checks of the models before sending them to the provider.

**Setup**

Add the dependency.

```swift
.package(url: "https://github.com/vedlai/OpenAISwiftDI", from: "1.0.0")
```
**Getting Started**

Import the package.
```swift
import OpenAIDI
```

Inject a provider as soon as possible.          

```swift
let key: String = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!

let org: String = ProcessInfo.processInfo.environment["OPENAI_ORGANIZATION"]

InjectedValues[\.openAIProvider] = URLSessionOpenAIProvider(apiKey: key, orgId: org)
```

If you don't inject a `Provider` the app will use `MockOpenAIProvider`. This provider generates sample responses. The intent behind this is to have something that behaves as if it is working but everything is hardcoded. It is ideal for `Previews` where quick (Free) responses are needed when creating the User Interface.

Then access the provider using the `@Injected` property wrapper.

```swift
@Injected(\.openAIProvider) var openAIProvider
```

or access one of the Manager's with built in checks such as verifiying properties per OpenAI's documentation and moderation checks.

```swift
@Injected(\.openAIImageMgr) var openAIImageMgr

@Injected(\.openAICompletionsMgr) var openAICompletionsMgr
```

**Available Sample Views**

**Chat Completions**

    [ChatCompletionsSampleView](https://github.com/vedlai/OpenAISwiftDI/blob/main/Sources/OpenAISwiftDI/Showcase/Images/Chat.png)
    
**Completions**

    [CompletionsSampleView](https://github.com/vedlai/OpenAISwiftDI/blob/main/Sources/OpenAISwiftDI/Showcase/Images/Completions.png)

**Images**

    [ImageCreateSampleView](https://github.com/vedlai/OpenAISwiftDI/blob/main/Sources/OpenAISwiftDI/Showcase/Images/ImageCreate.png)
    [ImageEditWithMaskSampleView](https://github.com/vedlai/OpenAISwiftDI/blob/main/Sources/OpenAISwiftDI/Showcase/Images/ImageEditWMask.png)
    [ImageVariationSampleView](https://github.com/vedlai/OpenAISwiftDI/blob/main/Sources/OpenAISwiftDI/Showcase/Images/ImageVariation.png)

**Edits**

    [EditsSampleView](https://github.com/vedlai/OpenAISwiftDI/blob/main/Sources/OpenAISwiftDI/Showcase/Images/Edits.png)

**Supported Endpoints**
```swift
public enum OpenAIEndpoints: String{
    case completions = "/v1/completions"
    case imagesGenerations = "/v1/images/generations"
    case imagesEdits = "/v1/images/edits"
    case imagesVariations = "/v1/images/variations"
    case moderations = "/v1/moderations"
    case chatCompletions = "/v1/chat/completions"
    case edits = "v1/edits"
}
```
More to come...

**Contribute**

Contributions for improvements are welcomed. Feel free to submit a pull request to help grow the library. If you have any questions, or bug reports, please send them to [Issues](https://github.com/vedlai/OpenAISwiftDI/issues).

**Known Limitations**

Image endpoints are limited to iOS and Mac Catalyst because of `UIImage`. Might adjust in the future.

When using `URLSessionOpenAIProvider`, Completions and Chat Completions streams are limited to iOS 15+ and macOS 12+.

Sample `View`s are limited to iOS 15+ and macOS 12+ because of `.task` & `.textSelection(.enabled)`, their purpose is to be quick prototypes that demostrate functionality.

**License**

MIT License

Copyright (c) 2023 Vedlai

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
