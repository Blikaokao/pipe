package com.hln.daydayup.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hln.daydayup.dto.RelationDto;
import com.hln.daydayup.dto.TaskView;
import com.hln.daydayup.entity.Miniuser;
import com.hln.daydayup.exception.DateInputException;

import java.util.List;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author lina
 * @since 2022-07-18
 */
public interface MiniuserService extends IService<Miniuser> {

    Miniuser getOneByOpenId(String openId);

    boolean setTasks(List<TaskView> taskViews, String userId) throws DateInputException;

    List<RelationDto> getAllUsers(Miniuser miniuser);
}
