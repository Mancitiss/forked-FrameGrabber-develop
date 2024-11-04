<p align="center">
    <a href="https://web.archive.org/web/20230525192529/https://apps.apple.com/app/frame-grabber/id1434703541">
        <img src="design/banner.png" alt="App Store banner">
    </a>
</p>

[Frame Grabber](https://framegrabberapp.com) is an app for iOS & iPadOS to extract full-resolution video frames as images — [framegrabberapp.com](https://framegrabberapp.com)


> **Note**  
> As of June 2023, Frame Grabber has been acquired and is published by its new owner. This repo remains open-source as it has since day one. It contains the code up to the latest version I published myself, 1.4.1.

## Reviews

4.8 stars worldwide. Loved by users for its ease-of-use and intuitiveness.

<p align="center">
    <a href="https://apps.apple.com/app/frame-grabber/id1434703541">
        <img src="design/banner-reviews.png" alt="App Store reviews">
    </a>
</p>

## About

[Read more](./docs/about.md) about why I made the app and some technical challenges along the way.

> **Note**  
> This was my very first app without prior experience. The code is not the newest. Please keep that in mind when checking out the code 😉 


## How to Build

- Open Xcode
- Change development team and bundle identifier
- Build

## Project Setup


As I wanted to learn the fundamentals with this project, I followed Apple's basic documentation. Which meant MVC with storyboards at the time.

Overview of main components:
- [`Application`](Frame%20Grabber/Application): Entry point into the app
- [`Scenes`](Frame%20Grabber/Scenes):The app's main screens
- [`Packages`](Frame%20Grabber/Packages): Modules extracted so far


## License

See [`LICENSE`](LICENSE).

Please [don't publish a clone](https://github.com/arthurhammer/FrameGrabber/issues/5) to the App Store. It's very confusing for users.
Instead, play around with the code, learn from it, and create something new! Make your ideas happen 🤗
