# GXTK7 Project Instructions

## Project Overview
GXTK 7 is GXDE-OS's QtQuick UI library and style plugin that mimics the appearance and functionality of the Deepin `dtk2widget` library. It provides a set of modern Qt6 Quick components designed to bring the look and feel of `dtk2widget` to contemporary Qt6-based applications.

## Technologies
- **Language:** C++17
- **Framework:** Qt 6 (Core, Gui, Qml, Quick, QuickControls2)
- **Build System:** CMake 3.20+

## Building and Running

### Prerequisites
Ensure you have a C++17 compatible compiler and the following Qt6 development packages installed:
- Qt6 Core, Gui, Qml, Quick, and QuickControls2

### Build Instructions
The project uses CMake as its build system.

1. Create a build directory:
   ```bash
   mkdir build && cd build
   ```
2. Configure and build:
   ```bash
   cmake ..
   make
   ```

### Running the Example
After building, you can run the gallery example to test the components:
```bash
./examples/gallery/gxde_gallery
```

## Project Structure
- `src/style/`: Contains the C++ implementation of the style plugin and QML component definitions.
- `src/style/cpp/`: C++ source and header files for the theme and plugin logic.
- `src/style/qml/gxde/`: QML files for the component library.
- `examples/gallery/`: An example application demonstrating the GXTK7 components.

## Development Conventions
- Follow the existing C++ project structure (headers in `cpp/`, source logic split between `cpp/` and `gxde_style_plugin/`).
- Ensure all new QML components added to `src/style/qml/gxde` are properly included in the `GXDE_STYLE_QML_FILES` variable in the root `CMakeLists.txt` (or appropriate sub-module configuration).
- Maintain C++17 compliance.
- Keep the `examples/gallery` directory as the primary location for feature demonstration and manual testing.
