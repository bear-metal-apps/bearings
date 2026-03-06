<p align="center">
  <img src="docs/assets/banner.png" alt="Beariscope" />
</p><p align="center">
  <b>The ultimate FRC scouting app</b>
</p>

<p align="center">
  <a href="https://github.com/betterbearmetalcode/pawfinder/releases">
    <img src="https://img.shields.io/github/v/release/betterbearmetalcode/pawfinder?label=Latest%20Release" alt="Release"/>
  </a>
  <a href="https://github.com/betterbearmetalcode/beariscope/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/betterbearmetalcode/pawfinder?color=blue" alt="License"/>
  </a>
  <a href="https://flutter.dev/">
    <img src="https://img.shields.io/badge/Built%20with-Flutter-02569B?logo=flutter" alt="Flutter"/>
  </a>
</p>

> [!NOTE]
> Beariscope is under active development. We're running it internally this season and plan to open it up to other teams next year.
---

# PawFinder
PawFinder is a fully custom FRC scouting app by Team 2046, Bear Metal.

## Features
PawFinder is built using flutter. This enables scouting without the need to do so via android. PawFinder is also multiplatform, allowing Bear Metal to create a more intuitive, aesthetic design, as well as created the opportunity to add further complexities, making PawFinder adaptable year by year.

## Customizing Our App
Currently we have it set up so that you only have to change one file in order to customize the UI.
- **UI File** - In resources/ui_creator.json you can see our current file. This file manages all of the scouting UI.
- **Organization** - Pawfinder uses the size of the screen and splits it into multiple cells, where UI elements can be located in resources/ui_creator.json
- **Widget Customization** - Each cell is used by the widgets to adjust its height, width, and position.
- **Widget Catalogue** - Multiple types of data in PawFinder can be tracked by referring to a specific widget to use:

2026 Specific Widgets:
- "big_int_button"

General Widgets Include:
- "int_button"
- "bool_button"
- "dropdown"
- "int_textbox"
- "tristate"
- "slider"
- "segmented_button"
 
and more have yet to be created

## If you haven't checked out our..
- [Viewer App](https://github.com/bear-metal-apps/beariscope)
- [Custom Library](https://github.com/bear-metal-apps/libkoala)
