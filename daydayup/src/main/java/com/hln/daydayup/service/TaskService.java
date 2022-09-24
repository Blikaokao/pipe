package com.hln.daydayup.service;

import com.hln.daydayup.dto.RelationDto;
import com.hln.daydayup.dto.TaskView;
import com.hln.daydayup.entity.Task;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hln.daydayup.entity.User;

import java.text.ParseException;
import java.util.List;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author lina
 * @since 2022-03-16
 */
public interface TaskService extends IService<Task> {
     List<TaskView> allTasks(List<RelationDto> users,Integer counts) throws ParseException;
     boolean outTimeDate(String newDay);
     boolean doneDate(String newDay);
     List<TaskView> getTask(String userId,Integer counts);
}
