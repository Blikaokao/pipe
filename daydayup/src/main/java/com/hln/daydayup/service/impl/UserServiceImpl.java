package com.hln.daydayup.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.conditions.query.QueryChainWrapper;
import com.hln.daydayup.constant.RedisCode;
import com.hln.daydayup.dto.RelationDto;
import com.hln.daydayup.dto.TaskView;
import com.hln.daydayup.entity.Detailtask;
import com.hln.daydayup.entity.Relation;
import com.hln.daydayup.entity.Task;
import com.hln.daydayup.entity.User;
import com.hln.daydayup.exception.DateInputException;
import com.hln.daydayup.mapper.*;
import com.hln.daydayup.service.UserService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * <p>
 *  服务实现类
 * </p>
 *
 * @author lina
 * @since 2022-03-16
 */
@Slf4j
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {



    @Autowired
    private StringRedisTemplate stringRedisTemplate;


    @Autowired
    private UserMapper userMapper;

    @Autowired
    private RelationMapper relationMapper;

    @Autowired
    private TaskMapper taskMapper;

    @Autowired
    private DetailtaskMapper detailTaskMapper;
    @Override
    public List<RelationDto> findUsers(User user) {


        QueryWrapper<User> userWrapper = new QueryWrapper<>();

        userWrapper.eq("phone",user.getPhone())
                .eq("passwd",user.getPasswd());


        //肯定只有一个
        User one = userMapper.selectOne(userWrapper);


        //通过验证
        if(one != null){
            return getAllUsers(one);
        }

        //未通过验证
        return null;
    }


    public List<RelationDto> getAllUsers(User one){
        List<RelationDto> users = new ArrayList<>();
        /*
         *
         * step 找到创建的用户   父账号为该用户  但是不具备密码等信息
         * */
        QueryWrapper<User> userWrapper = new QueryWrapper<>();
        userWrapper.eq("parent_id",one.getId());

        List<User> usersChildren = userMapper.selectList(userWrapper);
        if(usersChildren != null || usersChildren.size()!=0)
            for (User usersChild : usersChildren) {
                users.add(usersChild.convertToRelationDto(1));
            }



        /*
         *
         * step 找到关联的账户
         *
         * */
        //将数据库数据查询返回所有关联账户
        QueryWrapper<Relation> relationQueryWrapper = new QueryWrapper<>();
        relationQueryWrapper.eq("user_id",one.getId());
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
                RelationDto relationDto = new RelationDto(relation.getFriends(),relation.getName(),2,relation.getPhone());
                users.add(relationDto);
            }

        /*
         *
         * 把自己也加进去
         * */
        users.add(one.convertToRelationDto(0));
        return users;
    }



    @Override
    public boolean saveCode(String phone) {
        //发送验证码
        /*
        * ****************腾讯过期 更换
        * */
        String s = stringRedisTemplate.opsForValue().get(RedisCode.code + phone);
        if(s==null) {
            String code = MessageMapper.sendMessage(phone);

            System.out.println("验证码" + code);
            log.info(code);
            //验证码5分钟过期
            stringRedisTemplate.opsForValue().set(RedisCode.code + phone, code, 5L, TimeUnit.MINUTES);
            return true;
        }else return false;
    }

    @Override
    public String identifyCode(String code,String phone) {
        //验证码验证
        Object o = stringRedisTemplate.opsForValue().get(RedisCode.code+phone);
        if(o==null)
            return "outTime";
        else if (o.equals(code))
            return "true";
        return "false";
    }

    @Override
    public List<User> findByfather(Integer id) {

        ArrayList<User> arrayList = new ArrayList<>();

        User user = userMapper.selectById(id);
        List<User> users ;
        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("parent_id",id);
        users = userMapper.selectList(wrapper);
        users.add(user);
        return users;
    }

    @Transactional(rollbackFor = DateInputException.class)
    @Override
    public boolean setTasks(List<TaskView> taskViews,String userId) throws DateInputException {

        for (TaskView taskView : taskViews) {
            log.info(taskView.toString());
            System.out.println("之前"+taskView.getStartDate());
            System.out.println("之前"+taskView.getDeadLine());
            if(!addTask(userId, taskView)){
                throw new DateInputException("date error!");
            }
        }
        return true;
    }

    @Override
    public boolean addTask(String userId, TaskView taskView) {

        if((taskView.getStartDate()==null||taskView.getStartDate().equals("")) &&(taskView.getDeadLine()==null||taskView.getDeadLine().equals(""))){
            System.out.println(taskView.getStartDate());
            System.out.println(taskView.getDeadLine());
            return false;
        }

        Task task = new Task();

        BeanUtils.copyProperties(taskView, task);

        User user = userMapper.selectById(userId);
        if(user == null)
            return false;
        task.setUniqueid(userId);
        task.setAccount(user.getName());


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

    @Override
    public boolean findByPhone(String phone) {
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("phone",phone)
                    .eq("parent_id",0);
        User user = userMapper.selectOne(queryWrapper);
        if(user!=null)
            return false;
        return true;
    }


}
