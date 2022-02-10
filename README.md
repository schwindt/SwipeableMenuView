# SwipeableMenuView
## Swipe to delete for UIStackViews

This looks/works similar like the normal UITableView swipe to delete behavior.

In the example below is a UIStackView inside of a UIScrollView. The stackview has a bunch of SwipeableMenuViews. So its possible to scroll vertical and also to swipe the SwipeableMenuViews horizontal.

![example](https://user-images.githubusercontent.com/1539891/153432578-f4eb7968-322f-4f61-b204-e7f5a0d0e5c2.gif)

Its also possible to have two buttons instead of one. In this case the view snap to a fix position after you breakt through a defined barrier point.

![example2](https://user-images.githubusercontent.com/1539891/153443791-be83fb96-4273-4311-ad3f-fdd8e20bb7b9.gif)

**How to use:**

```swift
let deleteImage = UIImage(named: "delete")!
let rightFirstButtonConfig = SlideMenuViewButtonConfig(backgroundColor: .darkRed, instantFireBackgroundColor: .red, image: deleteImage) {
  // Do some magic here
}
let rightSlideMenuConfig = SlideMenuViewButtonWrapperConfig(buttonMode: .one(rightFirstButtonConfig))
SlideMenuView(rightMenuConfig: rightSlideMenuConfig, contentView: YOUR_CONTENT_VIEW)
```
