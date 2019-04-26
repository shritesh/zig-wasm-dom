# zig-wasm-dom

An example demonstrating Zig interacting with the DOM via JS. 

The WebAssembly memory allocator used here was added after Zig 0.4.0.
On MacOS with Homebrew, `brew install zig --HEAD` can be used to install Zig's master branch.

Compile with `zig build-exe -target wasm32-freestanding --release-small zigdom.zig`