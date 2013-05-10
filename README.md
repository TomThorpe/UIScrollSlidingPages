UIScrollSlidingPages
=========================

An example of an app using this control as it's main UI is the Tom Thorpe Photography app, available on the [App Store](https://itunes.apple.com/us/app/tom-thorpe-photography/id614901245?mt=8)

Example Screenshots
---

![Screenshot](Screenshots/uiscrollslidingpages.gif)

This is a **WORK IN PROGRESS** control that will eventually allow you to add multiple view controllers and have them scroll horizontally, each with a smaller header view that scrolls in proportion as the content scrolls. Similar in style to the Groupon app.

You should not use this control yet unless you accept the fact that it may change dramatically.


![Screenshot](Screenshots/1.png)  ![Screenshot](Screenshots/2.png)  ![Screenshot](Screenshots/3.png)



Installation
---
* Include the files in the  `Source` directory somewhere in your project using the Add Files option of XCode, Submodules, or however you normally include files from external repositories.
* Add `#import "TTUIScrollViewSlidingPages.h"` in your source wherever you plan to use this control.
                                                                                                                                                                                                                                                        
Usage
---
###What is UIScrollSlidingPages?
UIScrollSlidingPages is the project name for the `TTScrollSlidingPagesController` UIViewController. The control is a horizontal paged scroller complete with a header area, the standard "page dots" showing the current page, and an UI effect as you scroll between pages.

![image](Screenshots/diagram.png)

As mentioned above, the control contains two main "areas" - the content area and the header area - and is made up of "pages". The content area takes up the full width of the control and is paged, meaning the user sees one page at a time, whereas the pages in the header area do not take up the full width, allowing the user to see the next and previous page headers. The user may scroll horizontally between the pages by dragging left to right anywhere on the control, or tapping one of the pages in the header area. The two areas will stay in-sync to mean that the header of the current page is always in the middle of the header area.



### Instantiating the View Controller.

To use the control, create an instance of `TTScrollSlidingPagesController`. This is just a subclass of UIViewController, once you have instantiated it you can use the view property to add to your view like you would with any other UIViewController (normally by adding the `view` property of your instance as a subview to your current view, navigation controller, tab bar etc.). 

There is one main distinction, once you have instantiated `TTScrollSlidingPagesController` you should set the `dataSource` property, in a very similar way you would with a `UITableViewController`. The datasource should be set to an object that conforms to the `TTSlidingPagesDataSource` protocol. See the section below for details on implementing `TTSlidingPagesDataSource`.


For example, to instantiate `TTScrollSlidingPagesController` and add it to the current view from another view controller, do the following:

```  objc
    TTScrollSlidingPagesController slider = [[TTScrollSlidingPagesController alloc] init];
    slider.dataSource = self; /*the current view controller (self) conforms to the TTSlidingPagesDataSource protocol)*/
    slider.view.frame = self.view.frame; //I'm setting up the view to be fullscreen in the current view
    [scrollPagerView addSubview:slider.view];
    [self addChildViewController:slider]; //this makes sure the instance isn't released from memory :-)
```

###Implementing TSlidingPagesDataSource

* `-pageForSlidingPagesViewController:atIndex:` This returns a `TTSlidingPage` instance containing the view or viewController for the view you want to be in the content area for the page. See the diagram below.
* `titleForSlidingPagesViewController:(TTScrollSlidingPagesController*)source atIndex:(int)index;` This returns a `TTSlidingPageTitle` instance that contains the title text or image of the header for the page. See the diagram below.

**WORK IN PROGRESS, README TBC**

Options
---
**WORK IN PROGRESS, README TBC**
 
Example Code
--- 
**WORK IN PROGRESS, README TBC**
 
Demo
---
The included source is an XCode project which you can open to see a demo.

All the work is done in `TTViewController.m`. The `viewDidLoad` method contains some of the options properties that have been commented out to mean the demo is using the defaults. Try uncommenting them and playing around.

You can refer to these demos for reference of how to use the library if anything is unclear :-)

Limitation
---
Currently, despite using the same sort of `dataSource` delegate as UITableViewControllers do, the control still loads **ALL** the views as soon as it appears. This means if you have lots of pages it will still load them **all** into memory rather than being smarter and only loading the current (and possible next/previous) page. 
This has two main ramifications:
 
 * The control is best suited for only a few pages (probably less than 10 or so), otherwise you might start to see it slow down. 
 
 * The `viewDidAppear` method will get called for all the pages instantly, even those that aren't actually visible yet.
 
Some day in the future I might make it only load pages as they are needed, but I can't promise anything. I created this control for my own app, and it wasn't necessary for me as I only use a few pages. Sorry!


