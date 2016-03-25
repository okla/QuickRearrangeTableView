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

• Make view controller containing your table view adopt ```RearrangeDataSource``` protocol (or use any other object as data source)

• Make your table view class adopt ```Rearrangable``` protocol: add ```var rearrange: RearrangeProperties!``` to its declaration and paste its type name to ```extension _: Rearrangable```

• Call ```setRearrangeOptions(options: dataSource:)``` and pass options and data source object

Usage example included, tested in Xcode 7.3, iOS 9.3
