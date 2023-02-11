# Simple Code Obfuscator - MacOS bash

![macOS](https://svgshare.com/i/ZjP.svg)
[![GitHub license](https://badgen.net/github/license/Naereen/Strapdown.js)](https://github.com/yongxin-tech/Bash-Simple-Code-Obfuscator/blob/main/LICENSE)


This tool help you to obfuscate codes simply, especially in situation that no useful obfuscator of programming language, like swift, flutter.

The script read symbols from <code>func.list</code> file, replace symbols with random string, then store mapping into sqlite.


# Environment

The script is only tested on following environment,
* OS: MacOS 12+
* ISE: Terminal

# Usage

* Recommend: The script will overwrite the file directly, better use it on a separate branch

* Preparation: 
  1. Access privileges
  
  ```bash
  chmod 400 func.list
  chmod 700 obfuscate.sh
  ```
  
  2. Create a <code>func.list</code> file, put it into script folder

  <code>func-example.list</code>
  ```
  #__Infra.MethodChannelDispatcher
  MethodChannelDispatcher
  bind
  invokeFlutterMethod
  #release
  #__Infra.Logger
  info
  debug
  warn
  ```

* Command: 
  ```bash
  ./obfuscate.sh -d <code folder> -f "<filter pattern>" -s <name of sqlite db file> -l <file of symbol list> 
  ```

* Example: On Terminal
  ```bash
  ./obfuscate.sh -d ./Runner -f "*.swift" -s symbols-ios.db -l func-example.list 
  ```


# License

Copyright (c) 2023-present [Yong-Xin Technology Ltd.](https://yong-xin.tech/)

This project is licensed under the MIT License - see the [LICENSE](https://github.com/yongxin-tech/Bash-Simple-Code-Obfuscator/blob/main/LICENSE) file for details.


