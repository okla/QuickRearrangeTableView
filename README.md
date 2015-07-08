# QuickRearrangeTableView

###Overview###

Long press on a cell to catch it, then move it anywhere you want. Table view scrolls up or down when catched cell is near the top or bottom edge of the table view.

```QuickRearrangeTableView``` has two predefined catch style options: ```hover```

![](https://cloud.githubusercontent.com/assets/8558017/8571784/5d9084f4-2591-11e5-8cc1-9a4011bc41dc.gif)

and ```translucency```

![](https://cloud.githubusercontent.com/assets/8558017/8571783/5d8ff2b4-2591-11e5-8110-ae945c43cccd.gif)

###Installation###

• Add ```QuickRearrangeTableView.swift``` to your project

###Usage###

• After creating ```QuickRearrangeTableView``` object pass a data source object to its ```rearrangeDataSource``` property

• Data source object should adopt ```QuickRearrangeTableViewDataSource``` protocol

Usage example project included, tested in Xcode 6.4, iOS 8.4 (should work on iOS 7 too)
