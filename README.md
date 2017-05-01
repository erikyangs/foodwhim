# FoodWhim
**Originally made for [UC Berkeley's iOS Decal](http://iosdecal.com/ "iOS Decal Homepage")**

## Overview
For indecisive people. Tells you **exactly** what to eat.

<img src=https://github.com/erikyangs/foodwhim/blob/master/homescreen.jpg width="33%"><img src=https://github.com/erikyangs/foodwhim/blob/master/resultscreen.jpg width="33%"><img src=https://github.com/erikyangs/foodwhim/blob/master/settingscreen.jpg width="33%">

## Setup
Make sure you have CocoaPods installed. For reference: [Walkthrough From StackOverflow](http://stackoverflow.com/questions/20755044/how-to-install-cocoa-pods)
~~~~
sudo gem install cocoapods
pod setup --verbose
~~~~
Then navigate to the XCode project root directory (where .xcodeproj file resides), and setup CocoaPods.
~~~~
pod install
~~~~
Open the **.xcworkspace** file in XCode and run.

## Features
* Displays food around current GPS location
* Provides basic business info and reviews
* Search radius setting
* Search term setting

## Libraries, APIs, and more
* Yelp Fusion API (CocoaPod)

## Troubleshooting (mostly for us developers to keep track of links)
When adding/removing pods, you need to do the following. For reference: [Walkthrough from StackOverflow](http://stackoverflow.com/questions/13751147/remove-or-uninstall-library-previously-added-cocoapods)
~~~~
sudo gem install cocoapods-deintegrate
sudo gem install cocoapods-clean
pod deintegrate
pod clean
pod install
~~~~
