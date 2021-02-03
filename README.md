# SERequestManager

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
NetworkManager.startRequest { manager -> NetworkManager in
    manager.requestType(.post)
        .origialData(origialData: { (jsonString, reponseData) in
            print("origial data",jsonString as Any, reponseData)
        })
        .url("example")
        .params(["userId": 1])
        .success { data in
            
            // analyze example
            let credential: CredentialModel? = SECodable.decoder(data: data)
            print(credential as Any)
        }
}
```

## Requirements

swift_version = '5.0'

## Installation

SERequestManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SERequestManager'
```

## License

SERequestManager is available under the MIT license. See the LICENSE file for more info.
