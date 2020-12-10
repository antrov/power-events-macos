# PowerEvents for macOS

Simple demonstration of usage command line tools in order to obtain power history of mac computer. Demonstration app uses SwiftUI and Combine.

![App Screenshot](https://github.com/antrov/power-events-macos/blob/master/Zrzut%20ekranu%202020-12-9%20o%2019.18.00.png?raw=true)

Tested on macOS 10.15 BigSur and earlier versions. 

Code contains useful utils, like Shell executor with parsing of results into Swift class model and categorization of power events.

```bash
pmset -g log
last reboot shutdown
```

This project was dedicated to be used in the automatic worklogger but paradoxically I had no time finish it. 

¯\\\_(ツ)\_/¯
