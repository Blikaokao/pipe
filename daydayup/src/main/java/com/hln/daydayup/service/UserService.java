package com.hln.daydayup.service;

import com.hln.daydayup.dto.RelationDto;
import com.hln.daydayup.dto.TaskView;
import com.hln.daydayup.entity.User;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hln.daydayup.exception.DateInputException;

import java.util.List;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author lina
 * @since 2022-03-16
 */
public interface UserService extends IService<User> {
    List<RelationDto> findUsers(User user);
    boolean saveCode(String phone);
    String identifyCode(String code,String phone);
    List<User> findByfather(Integer id);
    boolean addTask(String userId, TaskView taskView);

    boolean findByPhone(String phone);

    boolean setTasks(List<TaskView> taskViews,String userId) throws DateInputException;
}
