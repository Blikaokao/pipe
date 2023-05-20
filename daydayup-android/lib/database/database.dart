import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/utils/shared_util.dart';

/*因为之前该软件都有未登录模式，所以以下“增删改查”函数中account参数都是可选参数，但是我们因为要多平台同步， 所以所有数据必须存在云端，account为必选参数*/
class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    var dataBasePath = await getDatabasesPath();
    String path = join(dataBasePath, "todo.db");
    return await openDatabase(
      path,
      version: 4,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        print("当前版本:$version");

        //待办清单数据表

        //建表
        await db.execute("CREATE TABLE TodoList ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "account TEXT,"
            "taskName TEXT,"
            // "taskType TEXT,"
            "taskStatus INTEGER,"
            "taskDetailNum INTEGER,"
            "taskDetailComplete INTEGER,"
            "uniqueId TEXT,"
            "needUpdateToCloud TEXT,"
            "overallProgress TEXT,"
            "changeTimes INTEGER,"
            "createDate TEXT,"
            "finishDate TEXT,"
            "startDate TEXT,"
            "deadLine TEXT,"
            "detailList TEXT,"
            "taskIconBean TEXT,"
            "textColor TEXT,"
            "backgroundUrl TEXT"
            ")");
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async{
        print("新版本:$newVersion");
        print("旧版本:$oldVersion");
        if(oldVersion < 2){
         await db.execute("ALTER TABLE TodoList ADD COLUMN changeTimes INTEGER DEFAULT 0");
        }
        if(oldVersion < 3){
          await db.execute("ALTER TABLE TodoList ADD COLUMN uniqueId TEXT");
          await db.execute("ALTER TABLE TodoList ADD COLUMN needUpdateToCloud TEXT");
        }
        if(oldVersion < 4){
          await db.execute("ALTER TABLE TodoList ADD COLUMN textColor TEXT");
          await db.execute("ALTER TABLE TodoList ADD COLUMN backgroundUrl TEXT");
        }
      },
    );
    ///注意，上面创建表的时候最后一行不能带逗号
  }

  ///创建一项任务
  Future createTask(TaskBean task) async {
    final db = await database;
    task.id = await db.insert("TodoList", task.toMap());
  }

  ///根据完成进度查询所有任务
  ///
  ///isDone为true表示查询已经完成的任务,否则表示未完成，isDone，account都是可选参数
  Future<List<TaskBean>> getTasks({bool isDone = false, String account}) async {
    final db = await database;
   
  //从前端的缓存文件中获取account字段（后端直接是从json里面读account就可）
    final theAccount =
        await SharedUtil.instance.getString(Keys.account) ?? "default";
//查询语句：满足account和overall两个条件（isDone=true即overall=1.0）
    var list = await db.query("TodoList",
        where: "account = ?" +
            (isDone ? " AND overallProgress >= ?" : " AND overallProgress < ?"),
        whereArgs: [account ?? theAccount, "1.0"]);
    List<TaskBean> beans = [];
    beans.clear();
    beans.addAll(TaskBean.fromMapList(list));
    return beans;
  }

  ///获取创建日期对应的任务
//这个没用，我测试加上去的函数
  Future<List<TaskBean>> getTasksByDate(DateTime dateTime,{String account}) async {
    final db = await database;
    String date = dateTime.toIso8601String().split("T")[0];
    final theAccount =
        await SharedUtil.instance.getString(Keys.account) ?? "default";
    var list = await db.query("TodoList",
        where: "account = ? AND createDate LIKE ?",
        whereArgs: [account ?? theAccount,  "%$date%",]);
    List<TaskBean> beans = [];
    beans.clear();
    beans.addAll(TaskBean.fromMapList(list));
    return beans;
  }


  ///查询所有任务，查询条件：用户名匹配
  Future<List<TaskBean>> getAllTasks({String account}) async {
    final db = await database;
    final theAccount =
        await SharedUtil.instance.getString(Keys.account) ?? "default";
    var list = await db.query("TodoList",
        where: "account = ?" ,
        whereArgs: [account ?? theAccount]);
    List<TaskBean> beans = [];
    beans.clear();
    beans.addAll(TaskBean.fromMapList(list));
    return beans;
  }

  ///更新任务，任务表中的主键是id，所以传入新任务，获取其Id，更新表中Id对应的任务
  Future updateTask(TaskBean taskBean) async {
    if(taskBean == null) return;
    final db = await database;
    await db.update("TodoList", taskBean.toMap(),
        where: "id = ?", whereArgs: [taskBean.id]);
    debugPrint("升级当前task:${taskBean.toMap()}");
  }

///删除对应id的任务
  Future deleteTask(int id) async {
    final db = await database;
    db.delete("TodoList", where: "id = ?", whereArgs: [id]);
  }


  ///批量更新任务，传入一个任务列表，逐一执行update
  Future updateTasks(List<TaskBean> taskBeans) async{
    final db = await database;
    final batch = db.batch();
    for (var task in taskBeans) {
      batch.update("TodoList", task.toMap(),
          where: "id = ?", whereArgs: [task.id]);
    }
    final results = await batch.commit();
    print("批量更新结果:$results");
  }

  ///批量创建任务
  Future createTasks(List<TaskBean> taskBeans) async{
    final db = await database;
    final batch = db.batch();
    for (var task in taskBeans) {
      batch.insert("TodoList", task.toMap());
    }
    final results = await batch.commit();
    print("批量插入结果:$results");
  }

  ///根据[uniqueId]查询一项任务
  Future<List<TaskBean>> getTaskByUniqueId(String uniqueId) async{
    final db = await database;
    var tasks = await db.query("TodoList",
        where: "uniqueId = ?" ,
        whereArgs: [uniqueId]);
    if(tasks.isEmpty) return null;
    return TaskBean.fromMapList(tasks);
  }


  ///批量更新账号
  ///用于用户改变acount名，这里是原来前端用户从未登录状态-》登陆状态，所以把数据库里面所有 account为default的任务都改成新的account名
  Future updateAccount(String account) async{

    final tasks = await getAllTasks(account: "default");
  //生成一个存放新任务的空列表
    List<TaskBean> newTasks = [];

    for (var task in tasks) {
      if(task.account == "default"){
        task.account = account;
        newTasks.add(task);
      }
    }
    print("更新结果:$newTasks   原来:$tasks");
    updateTasks(newTasks);
  }

  ///通过加上百分号，进行模糊查询
///查询内容：任务名/子任务/开始时间/截止时间有部分匹配的
  Future<List<TaskBean>> queryTask(String query) async {
    final db = await database;
    final account =
        await SharedUtil.instance.getString(Keys.account) ?? "default";
    var list = await db.query("TodoList",
        where: "account = ? AND (taskName LIKE ? "
            "OR detailList LIKE ? "
            "OR startDate LIKE ? "
            "OR deadLine LIKE ?)",
        whereArgs: [
          account,
          "%$query%",
          "%$query%",
          "%$query%",
          "%$query%",
        ]);
    List<TaskBean> beans = [];
    beans.clear();
    beans.addAll(TaskBean.fromMapList(list));
    return beans;
  }


}
