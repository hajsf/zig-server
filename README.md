# zig-server

Cross compile the zig app
You can use the `zig build-exe` command to build an executable file for Windows while using Linux. You'll need to specify the target platform using the `-target` option. For example, to build an executable for the `x86_64` architecture on Windows, you can use the following command: 
```bach
zig build-exe server.zig -target x86_64-windows
```
 where `source.zig` is the name of your source file. This will produce an `.exe` file that can be run on Windows ¹.

Source: Conversation with Bing, 6/15/2023
(1) Chapter 3 - Build system | ziglearn.org. https://ziglearn.org/chapter-3/.
(2) Install Zig Programming Language on Linux - TREND OCEANS. https://trendoceans.com/zig-programming-language/.
