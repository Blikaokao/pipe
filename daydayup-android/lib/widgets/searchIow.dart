import 'package:flutter/material.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/all_model.dart';

List<TaskBean> searchList = [];
List<TaskBean> result = [];

//搜索建议
var recentSuggest = [];
const searchLength = 5;

class searchBarDelegate extends SearchDelegate<TaskBean> {
  int searchCount = 0;
  /*
  * 清空
  * */
  final MainPageModel model;
  searchBarDelegate(this.model) {
    searchList = model.tasks;
  }

  List<TaskBean> searchResult(String query) {
    List<TaskBean> results = [];
    for (int i = 0; i < searchList.length; i++) {
      if (searchList[i].taskName.contains(query)) results.add(searchList[i]);
    }
    return results;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = "", //搜索值为空
      )
    ];
  }

  /*
  * 关闭搜索框
  * */
  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () => close(context, null) //点击时关闭整个搜索页面
        );
  }

  /*
  * 搜索结果
  * */
  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    print("==========" + searchCount.toString());
    if (query != null && query != "") {
      bool flag = true;
      for (int i = 0; i < recentSuggest.length; i++) {
        if (recentSuggest[i] == query) flag = false;
      }
      if (flag) {
        if (recentSuggest.length < searchLength)
          recentSuggest.add(query);
        else
          recentSuggest[searchCount % searchLength] = query;
        searchCount = searchCount + 1;
      }
    }

    result = searchResult(query);
    int cardLength;
    if (result == null || result.length == 0) {
      cardLength = 0;
      return Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
        child: Center(
            //heightFactor: MediaQuery.of(context).size.height / 2,
            child: Column(children: [
          Image(
            image: AssetImage("images/synchronization.png"),
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.contain,
          ),
          //Expanded(child: Container(height: 5)),
          Text(
            "未找到日程",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
          )
        ])),
      );
    } else
      cardLength = result.length;
    return ListView.builder(
      itemCount: cardLength,
      itemBuilder: (BuildContext ctxt, int index) => buildBody(ctxt, index),
    );
  }

  //自定义主题颜色
  //返回一个主题，也就是可以自定义搜索界面的主题样式
  /*@override
  ThemeData appBarTheme(BuildContext context) {
    // TODO: implement appBarTheme
    return appBarTheme(context);
  }*/

  // 从 itemBuilder 调用的独立函数
  Widget buildBody(BuildContext ctxt, int index) {
    return Container(
      height: 100,
      child: Card(
        color: Colors.lightBlue,
        shape: RoundedRectangleBorder(
            //全部设置
            borderRadius: BorderRadius.all(Radius.circular(10))
            //单独设置四个角
//          borderRadius: BorderRadius.only(
//            topLeft: Radius.circular(15),
//            topRight: Radius.zero,
//            bottomLeft: Radius.circular(15),
//            bottomRight: Radius.zero
//          )
            ),
        shadowColor: Colors.red,
        elevation: 5,
        clipBehavior: Clip.none,
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            /*AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                "https://www.itying.com/images/flutter/1.png",
                fit: BoxFit.cover,
              ),
            ),*/
            ListTile(
              onTap: () {
                Navigator.of(ctxt).push(MaterialPageRoute(builder: (context) {
                  return ProviderConfig.getInstance()
                      .getTaskDetailPage(result[index].id, result[index]);
                }));
              },
              leading: ClipOval(
                  child: Image(
                image: AssetImage("images/calendar_search_logo.png"),
                fit: BoxFit.cover,
                height: 60,
                width: 60,
              )),
              title: Text(result[index].taskName),
              subtitle: Text(
                result[index].startDate + "-" + result[index].deadLine,
                style: TextStyle(fontSize: 10),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget suggestion(BuildContext ctxt, int index) {
    return Container(
        height: MediaQuery.of(ctxt).size.height / 15,
        child: Column(children: [
          Expanded(
              child: Container(
            height: MediaQuery.of(ctxt).size.height / 45,
          )),
          GestureDetector(
            onTap: () {
              query = recentSuggest[index];
              buildResults(ctxt);
            },
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 10),
                  child: Icon(
                    Icons.search,
                    color: Colors.black12,
                    size: 20,
                  ),
                ),
                Text(
                  recentSuggest[index],
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          /*ListTile(
            onTap: () {
              query = recentSuggest[index];
              buildResults(ctxt);
            },
            leading: Icon(
              Icons.search,
              color: Colors.black12,
              size: 20,
            ),
            title: Text(
              recentSuggest[index],
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontSize: 15,
              ),
            ),
          ),*/
          Divider(),
        ]));
  }

  /*
  * 底部的搜索建议
  * */
  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    final suggestionsList = recentSuggest;

    return ListView.builder(
      itemCount: suggestionsList.length,
      itemBuilder: (BuildContext ctxt, int index) => suggestion(ctxt, index),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    assert(theme != null);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        brightness: colorScheme.brightness,
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.blue),
      ),
      inputDecorationTheme: searchFieldDecorationTheme ??
          InputDecorationTheme(
            fillColor: Colors.white,
            hintStyle: searchFieldStyle ?? theme.inputDecorationTheme.hintStyle,
            border: InputBorder.none,
          ),
    );
  }
}
