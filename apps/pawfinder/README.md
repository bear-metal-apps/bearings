# PawFinder
This is 2046 Bear Metal's fully custom scouting app. This year we moved towards flutter so that scouting wouldn't have to be done via android. This in-addition to being multiplatform also allowed us to bring together a overall better design of our app, as well as gave us the opportunity to add further complexities and make our app adaptable year by year.

## If you haven't checked out our..
- [Scouting Server](https://github.com/bear-metal-apps/honeycomb)
- [Viewer App](https://github.com/bear-metal-apps/beariscope)
- [Custom Library](https://github.com/bear-metal-apps/libkoala)

## Using Our App
Currently we have it set up so that you only have to change one file in order to customize the UI.
In resources/ui_creator.json you can see our current file. Essentially how our app works is it takes the size of the screen splits it into cells and then takes the height, and width of each cell and then positions each widget according to the cells. There are multiple types of data types for our app refering towards what widget in specific to use:

2026 Specific Widgets:
- "big_int_button"
- "probably something else"

General Widgets Include:
- "int_button"
- "bool_button"
- "dropdown"
- "int_textbox"
- "tristate"
- "slider"
- "segmented_button"
 
and more have yet to be created

## Getting Started With Flutter

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
