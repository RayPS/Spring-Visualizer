![](.readme/appicon.png)

# Spring Visualizer
### Spring(rk4) Animation Curve Options Visualizer

<a href="https://itunes.apple.com/us/app/spring-visualizer/id1139500914?ls=1&mt=8"><img src=".readme/btn-ios.png" height="60px"></a>
<a href="#"><img src=".readme/btn-macos.png" height="60px"></a>


![](.readme/4.7-inch@2x.png)


## How it Build

Using Gulp to watch `app.coffee`

After `app.cofee` changed in Framer Studio or any text editor,

the necessary files will copy to `HTML/`

Then use `WKWebview` to load `HTML/index.html`

Read `gulpfile.js` for more details.

```
> gulp
```
