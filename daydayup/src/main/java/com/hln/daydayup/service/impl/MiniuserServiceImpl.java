package com.hln.daydayup.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hln.daydayup.dto.RelationDto;
import com.hln.daydayup.dto.TaskView;
import com.hln.daydayup.entity.*;
import com.hln.daydayup.exception.DateInputException;
import com.hln.daydayup.mapper.DetailtaskMapper;
import com.hln.daydayup.mapper.MiniuserMapper;
import com.hln.daydayup.mapper.RelationMapper;
import com.hln.daydayup.mapper.TaskMapper;
import com.hln.daydayup.service.MiniuserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

/**
 * <p>
 *  服务实现类
 * </p>
 *
 * @author lina
 * @since 2022-07-18
 */
@Service
@Slf4j
public class MiniuserServiceImpl extends ServiceImpl<MiniuserMapper, Miniuser> implements MiniuserService {

    @Autowired
    private TaskMapper taskMapper;
    @Autowired
    private MiniuserMapper miniuserMapper;
    @Autowired
    private DetailtaskMapper detailTaskMapper;
    @Autowired
    private RelationMapper relationMapper;

    @Override
    public Miniuser getOneByOpenId(String openId) {
        QueryWrapper miniWrapper = new QueryWrapper<>().eq("openid",openId);
        return miniuserMapper.selectOne(miniWrapper);
    }

    //展示得到插入的日程
    @Transactional(rollbackFor = DateInputException.class)
    @Override
    public boolean setTasks(List<TaskView> taskViews, String userId) throws DateInputException {
        for (TaskView taskView : taskViews) {
            log.info(taskView.toString());
            if(!addTask(userId, taskView)){
                throw new DateInputException("date error!");
            }
        }
        return true;
    }

    //得到所有的用户  子用户等等
    @Override
    public List<RelationDto> getAllUsers(Miniuser miniuser) {
        List<RelationDto> users = new ArrayList<>();
        /*
         *
         * step 找到创建的用户   父账号为该用户  但是不具备密码等信息
         * */
        QueryWrapper miniUserWrapper = new QueryWrapper<>();
        miniUserWrapper.eq("parent_id",miniuser.getId());

        List<Miniuser> usersChildren = miniuserMapper.selectList(miniUserWrapper);

        if(usersChildren != null || usersChildren.size()!=0)
            for (Miniuser usersChild : usersChildren) {
                users.add(usersChild.convertToRelationDto(1));
            }



        /*
         *
         * step 找到关联的账户
         *
         * */
        //将数据库数据查询返回所有关联账户
        QueryWrapper<Relation> relationQueryWrapper = new QueryWrapper<>();
        relationQueryWrapper.eq("user_id",miniuser.getId());
        List<Relation> relations = relationMapper.selectList(relationQueryWrapper);
        log.info(relations.toString());
        /*
         * 存储的方式改变
         * 数据库中存储的是
         *主账户id 关联账户id 账户名字
         *
         * */
        if(relations != null || relations.size()!=0)
            for (Relation relation : relations) {
                RelationDto relationDto = new RelationDto(relation.getFriends(),relation.getName(),2);
                users.add(relationDto);
            }

        /*
         *
         * 把自己也加进去
         * */
        users.add(miniuser.convertToRelationDto(0));
        return users;

    }

    private boolean addTask(String userId, TaskView taskView) {

        if((taskView.getStartDate()==null||taskView.getStartDate().equals("")) &&(taskView.getDeadLine()==null||taskView.getDeadLine().equals(""))){
            return false;
        }

        Task task = new Task();

        BeanUtils.copyProperties(taskView, task);

        QueryWrapper miniWrapper = new QueryWrapper<>();
        miniWrapper.eq("openid", userId);
        Miniuser user = miniuserMapper.selectOne(miniWrapper);
        if(user == null)
            return false;
        task.setUniqueid(userId);
        task.setAccount(user.getNickName());


        Integer detailNum = 0;
        List<Detailtask> detailtaskList = taskView.getDetailtaskList();

        if (detailtaskList == null || detailtaskList.size() == 0) {
            task.setTaskDetailNum(detailNum);
            taskMapper.insert(task);
            return true;
        }
        //当有子日程时
        detailNum = detailtaskList.size();
        task.setTaskDetailNum(detailNum);
        taskMapper.insert(task);
        Integer parentId = task.getId();
        for (Detailtask detailtask : detailtaskList) {
            detailtask.setParentId(parentId);
            detailTaskMapper.insert(detailtask);
            log.info(detailtaskList.toString());
        }
        return true;
    }


}
