# *Veles*

![Header2](https://user-images.githubusercontent.com/93743301/208818025-ea7057f9-6eee-4576-a83e-84885c7822bc.png)

Veles is a free and open source music player and tag/metadata editor for music files.
It is entirely built using the Godot Game Engine and by LyffLyff.
Wether you want to use this software to easily edit metadata including covers, lyrics or other tags,
or use it to play and organize your digital music collection, Veles has got you covered.

This is and will be free , forever!

Download for free here:
https://lyfflyff.itch.io/veles


# Installation Guide:

- Clone this repository: https://github.com/samsface/godot-native-example to your local machine
- Download the Veles Native Project
- Replace the CMakeLists.txt and src/Godot.cpp from the godot_native_example with the same files from the Veles Native Project
- Run the debug.bat file -> should create a work folder with a "Veles.sln" file
- Now clone the "Veles" project into the "app" directory of the Project so the structure looks like this /app/src/....
- Now the Godot Project should be able to run
- To see build and install the changes made to the GDNative part of this application, right click "Build" or "Install" and press "Build"
- The "Install" should now produce a new library in the app/addons/GDNative/ directory, which is used by the Godo Project