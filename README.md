The original Python version of this SIM module library, which interfaces with cellular devices via serial communication, was written without knowledge of composition, singletons, streams, or state management, resulting in a less modular and harder-to-maintain codebase. 
This Dart rewrite addresses these limitations to provide a robust, user-friendly library.

Composition enables modular use of features, such as isolating GPS or SMS functionality for specific use cases.
<br>
Singletons ensure thread-safe access to the serial port, preventing race conditions during read/write operations.
<br>
Streams simplify asynchronous handling of serial data, such as incoming messages or connection status updates. 
<br>
State management ensures predictable tracking of the SIM module’s state (e.g., connected, idle, or error). 
<br>
Inheritance is used sparingly, primarily for dependency injection to enhance testability and configuration. 
<br>

Dart was chosen for its type safety, cross-platform compatibility, and runtime performance, leveraging its FFI to interface efficiently with the C-based libserialport library, abstracting low-level serial communication for seamless operation across platforms.
