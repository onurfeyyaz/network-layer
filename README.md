# NetworkLayer

NetworkLayer is a lightweight, efficient, and easy-to-use networking package for Swift applications. It provides a robust foundation for making HTTP requests, handling responses, and managing errors in a clean and modular way.

![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features
- 🚀 Simple and intuitive API for making network requests
- 🛠 Customizable endpoints with support for various HTTP methods
- 🔒 Built-in error handling and type-safe response decoding
- 🧩 Easily extensible for custom requirements
- 📦 Designed as a Swift Package for easy integration
- 🧪 Testable architecture with protocol-based dependencies

## Installation
To integrate `NetworkLayer` into your Xcode project using Swift Package Manager, follow these steps:

1. Open your project in Xcode.
2. Go to **File > Add Package Dependencies**.
3. Enter the following URL for the repository: https://github.com/onurfeyyaz/network-layer.git

Alternatively, you can add the following to your `Package.swift` file:

```swift
dependencies: [
 .package(url: "https://github.com/onurfeyyaz/network-layer.git", from: "1.0.0")
]
```


## Usage

### Creating an Endpoint
```swift

// Do not forget to import NetworkLayer.
import NetworkLayer

// Create a struct that conforms to the Endpoint protocol from the NetworkLayer.
struct MovieEndpoint: Endpoint {
    var baseURL: URL {
        URL(string: "https://api.example.org")!
    }
    
    var path: String {
        "/discover"
    }
    
    var method: NetworkLayer.HTTPMethod {
        .GET
    }
    
    var headers: [String : String]? {
        [
            "accept": "application/json",
            "Authorization": "Bearer token"
        ]
    }
    
    var queryParameters: [String : CustomStringConvertible]? {
        return [
            "page": 1
        ]
    }
    
    var body: Data? {
        nil
    }
}
```

### Making a Request
```swift
import NetworkLayer

// Use dependency injection in init for better testability and flexibility
final class MovieService {
    private let networkManager: NetworkManagerProtocol
    
    // Dependency Injection through initializer
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    /*
     * Rest of the code
     */ 
 
    func fetchMovies() async -> T? {
        do {
            let response = try await networkManager.request(MovieEndpoint(),
                                                            responseType: T.self)
            return response
        } catch let error as NetworkError {
        
            // Handles and prints a detailed network error description if available
            print("Failed to fetch data: \(error.errorDescription ?? "no error description")")
        } catch {
            print("An unexpected error occurred: \(error.localizedDescription)")
        }
        return nil
    }
}

```
## Error Handling 
The NetworkLayer provides a comprehensive NetworkError enum for handling various network-related errors. Each error case includes relevant information, such as status codes and response data, when applicable.

### `NetworkError` Cases
- **`invalidURL`**: 
  - The provided URL is invalid.
  
- **`noData`**: 
  - No data was returned from the server.
  
- **`decodingError`**: 
  - Failed to decode the response data into the expected model.
  
- **`informational`**: 
  - Status codes in the 100–199 range, indicating an informational response.
  
- **`redirection`**: 
  - Status codes in the 300–399 range, indicating redirection.
  
- **`clientError`**: 
  - Status codes in the 400–499 range, indicating a client-side error.
  
- **`serverError`**: 
  - Status codes in the 500–599 range, indicating a server-side error.
  
- **`unexpectedStatusCode`**: 
  - An unexpected status code that doesn't fall into the above categories.
  
- **`unknown`**: 
  - An unknown error occurred.

Each error is designed to handle various network-related issues, helping you diagnose and debug problems efficiently within your application.

## Customization 
NetworkLayer is designed to be easily customizable. You can:
- Extend the Endpoint protocol to suit your API structure.
- Add new HTTP methods if necessary.
- Modify the NetworkManager for custom request/response handling.

## Contributing
Contributions to NetworkLayer are welcome! Here's how you can contribute:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please make sure to update tests as appropriate and adhere to the existing coding style.

## License
NetworkLayer is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Support
If you have any questions or need help integrating NetworkLayer into your project, please open an issue on the GitHub repository.

---

We hope NetworkLayer helps you build robust and efficient networking code in your Swift applications. Happy coding!
