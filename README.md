# QuickRearrangeTableView

###Overview###

Long press on a cell to catch it, then move it anywhere you want. Table view scrolls up or down when catched cell is near the top or bottom edge of the table view.

```QuickRearrangeTableView``` has two predefined catch style options: ```hover```

![](https://raw.githubusercontent.com/okla/QuickRearrangeTableView/master/GIFs/Untitled.gif)

and ```translucency```

![](https://raw.githubusercontent.com/okla/QuickRearrangeTableView/master/GIFs/Untitled2-3.gif)

###Installation###

• Add ```QuickRearrangeTableView.swift``` to your project

###Usage###

• After creating ```QuickRearrangeTableView``` object pass a data source object to its ```rearrangeDataSource``` property

• Data source object should adopt ```QuickRearrangeTableViewDataSource``` protocol

Usage example project included, tested in Xcode 6.4, iOS 8.4 (should work on iOS 7 too)
