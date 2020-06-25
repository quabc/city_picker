import 'package:city_picker/city_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: CityPicker(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CityPicker extends StatefulWidget {
  @override
  _CityPickerState createState() => _CityPickerState();
}

class _CityPickerState extends State<CityPicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('籍贯'), centerTitle: true),
      body: Center(
        child: FlatButton(
          onPressed: () => showHomeTownPickerDialog(),
          child: Text('籍贯'),
        ),
      ),
    );
  }

  showHomeTownPickerDialog() => showModalBottomSheet(
        context: context,
        builder: (context) => PickerDialog(),
      );
}

class PickerDialog extends StatefulWidget {
  @override
  _PickerDialogState createState() => _PickerDialogState();
}

class _PickerDialogState extends State<PickerDialog> {
  /*
  * 思路：
  * 创建三个数组，分别为省级数组，市级数组，区县级数组。
  * 省级数组为数据的第一个下标，所以可以直接获取。
  * 市级数组和区县级数组在数据的第二个下标里面，所以先创建一个数组替身，用来获取数据第一个下标，这第一个下标里储存着每个省级数组的下级城市。
  * 使用这个替身，市级数组先获取到第一个省级城市的市级城市，在省级城市选择器拖动时，再动态获取每个省级城市的市级城市。
  * 市级数组下标有区县级城市，所以区县级数组先获取第一个市级城市的区县级城市，因为市级城市选择器会随着省级城市选择器拖动而切换，
  * 所以需要在省级城市选择器那里创建一个动态事件，区县级城市数组会随着市级城市数组的动态变换而跟着变换。
  */
  //省级数组
  List province = [];
  //city的替身
  List cityWrong = [];
  //市级数组
  List city = [];
  //区县级数组
  List area = [];
  //这个int类型是用来定义area的定位的，当city不滑动的时候，默认为0，滑动的时候跟着city更新。
  int areaIndex = 0;
  FixedExtentScrollController cityC = new FixedExtentScrollController();
  FixedExtentScrollController areaC = new FixedExtentScrollController();

  start() {
    //省级数组赋值
    for (int i = 0; i < dataCity.length; i++) {
      province.insert(province.length, dataCity[i]['name']);
    }
    //获取到每个省的所有下级城市和区县
    for (int i = 0; i < province.length; i++) {
      cityWrong.insert(cityWrong.length, dataCity[i]['city']);
    }
    print(cityWrong);
    //市级数组临时赋值，默认北京
    city = cityWrong[0];
    //市级数组临时赋值，默认北京的区县级城市
    area = city[0]['area'];
  }

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Container(
          height: 200,
          child: new Row(
            children: <Widget>[
              ///省级province
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 60,
                  onSelectedItemChanged: (value) => setState(() {
                    //市级城市随着省级的拖动而变换城市
                    city = cityWrong[value];
                    //归0
                    cityC.jumpTo(0);
                    //归0
                    areaC.jumpTo(0);
                  }),
                  children: List.generate(province.length, (index) {
                    //areaIndex默认为0，即每个省级城市的首个市级城市的所有区县城市,city变动时才变化
                    setState(() => area = city[areaIndex]['area']);
                    return Center(
                        child: TextWidget(title: '${province[index]}'));
                  }),
                ),
              ),

              ///市级city
              Expanded(
                child: CupertinoPicker(
                  scrollController: cityC,
                  itemExtent: 60,
                  onSelectedItemChanged: (value) => setState(() {
                    //区县级城市随着市级城市拖动而变换
                    area = city[value]['area'];
                    //areaIndex跟着city滑动变化
                    areaIndex = value;
                    //归0
                    areaC.jumpTo(0);
                  }),
                  //city的长度是实时变化的
                  children: List.generate(city.length, (index) {
                    return Center(
                        child: TextWidget(title: '${city[index]['name']}'));
                  }),
                ),
              ),

              ///区县级area
              Expanded(
                child: CupertinoPicker(
                  scrollController: areaC,
                  itemExtent: 60,
                  onSelectedItemChanged: (value) {},
                  //area的长度是实时变化的
                  children: List.generate(area.length, (index) {
                    return Center(child: TextWidget(title: '${area[index]}'));
                  }),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class TextWidget extends StatelessWidget {
  final String title;
  TextWidget({this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(fontSize: 16, color: Color(0xFF262626)));
  }
}
