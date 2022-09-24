package com.hln.daydayup.mapper;

import com.hln.daydayup.entity.Task;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

/**
 * <p>
 *  Mapper 接口
 * </p>
 *
 * @author lina
 * @since 2022-03-16
 */
public interface TaskMapper extends BaseMapper<Task> {

    /*
    * 提醒事件判断 是否已经做过了
    * 如果任务截止时间还是未做 将其状态置为2--未做
    * */
    @Update("update task set task_status = 2 where id in (select t.id from (select * from task where SUBSTRING(dead_line, 1, 10)= #{newDay} and alert is not null and task_status = 0)t);")
    public boolean outTimeDate(String newDay);
    @Update("update task set task_status = 1 where id in (select t.id from (select * from task where SUBSTRING(dead_line, 1, 10)= #{newDay} and alert is null and task_status = 0)t);")
    public boolean doneDate(String newDay);
}
