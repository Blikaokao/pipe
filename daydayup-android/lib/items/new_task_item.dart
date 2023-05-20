import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/global_model.dart';
// import 'package:todo_list/widgets/custom_cache_provider.dart';
import 'package:todo_list/widgets/task_info_widget.dart';

///主页展示的任务条目
class TaskItem extends StatefulWidget {
  final int index;
  final TaskBean taskBean;
  final VoidCallback onDelete; //删除
  final VoidCallback onEdit; //编辑
  final Color color;

  TaskItem(this.color,this.index, this.taskBean, {this.onDelete, this.onEdit});
  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {

    final content = TaskInfoWidget(
      false,
      widget.index,
      space: 0,
      taskBean: widget.taskBean,
      onDelete: widget.onDelete,
      onEdit: widget.onEdit,
      // isCardChangeWithBg: globalModel.isCardChangeWithBg,
    );

    return Dismissible(
      key: Key(widget.taskBean.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          //删除
          await widget.onDelete();
        }
        return;
      },
      background: Container(
        //圆角+宽度
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: widget.color,
            boxShadow: [
              BoxShadow(
                  color: const Color(0xffB7B7B7),
                  offset: Offset(6.0, 0.0), //阴影x轴偏移量
                  blurRadius: 2, //阴影模糊程度
              )
            ],
          ),
        padding: EdgeInsets.only(left: 10,right: 0),
        margin: EdgeInsets.all(10),
          child: Container(
        margin: EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
          ),
          child: content,
        ),
      )),
    );
  }
}
