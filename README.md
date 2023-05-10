# README

## About

This application displays photos of dogs.  It uses the [dog.ceo API](https://dog.ceo/dog-api/).  Documentation can be found [here](https://dog.ceo/dog-api/documentation/).

The user can choose to show a random photo of a dog or a set of photos of dogs of a selected breed.

This application has not been tested in macOs nor in iOS.

## Running & Building

To run the application you can use the `flutter run` command specifying the device like so: `flutter run -d windows`.

To run and build the application in release mode you can enter a command such as this: `flutter run -d windows --release`.

To build the application in release mode you can enter a command such as this: `flutter build windows`.

I have found that when running the application in Visual Studio Code, the application will throw an exception if I select a breed that is missing one of the jpg files for that breed on the dog.ceo server.  One example of such a breed is "labradoodle".  This does not occur when I am building the application.

## Using the Application

To show a random photo of a dog, simply click on the `Get Random Image` button or tab to it and press the `<Enter>` key.

To show a set of photos of dogs, you can use the dropdown box to select a breed and the photos should appear.

You can then use the scroll wheel of your mouse or the scroll box to scroll.  Alternatively, you can use the keyboard to scroll. First tab away from the dropdown box.  Then you can use the up arrow key, down arrow key, PageUp key, PageDown key, the Home key, or the End key to scroll.
