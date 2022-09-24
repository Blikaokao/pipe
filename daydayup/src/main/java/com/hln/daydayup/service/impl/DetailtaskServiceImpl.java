package com.hln.daydayup.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.hln.daydayup.entity.Detailtask;
import com.hln.daydayup.entity.Task;
import com.hln.daydayup.mapper.DetailtaskMapper;
import com.hln.daydayup.mapper.TaskMapper;
import com.hln.daydayup.service.DetailtaskService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hln.daydayup.service.TaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * <p>
 *  服务实现类
 * </p>
 *
 * @author lina
 * @since 2022-03-16
 */
@Service
public class DetailtaskServiceImpl extends ServiceImpl<DetailtaskMapper, Detailtask> implements DetailtaskService {

    @Autowired
    TaskMapper taskMapper;
    @Autowired
    DetailtaskMapper detailtaskMapper;
    @Override
    public void deleteAllById(String id) {
        QueryWrapper<Task> wrapper = new QueryWrapper<>();
        wrapper.eq("uniqueId",id);
        List<Task> tasks = taskMapper.selectList(wrapper);
        for (Task task : tasks) {
            //找出所有的删除掉
            QueryWrapper<Detailtask> detailWrapper = new QueryWrapper<>();
            detailWrapper.eq("parent_id",task.getId());
            detailtaskMapper.delete(detailWrapper);
            //再把自己删除掉
            taskMapper.deleteById(task.getId());
        }

    }
}
