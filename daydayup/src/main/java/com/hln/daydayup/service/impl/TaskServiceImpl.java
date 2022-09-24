package com.hln.daydayup.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.hln.daydayup.constant.EventType;
import com.hln.daydayup.dto.RelationDto;
import com.hln.daydayup.dto.TaskView;
import com.hln.daydayup.entity.Detailtask;
import com.hln.daydayup.entity.Task;
import com.hln.daydayup.entity.User;
import com.hln.daydayup.mapper.DetailtaskMapper;
import com.hln.daydayup.mapper.TaskMapper;
import com.hln.daydayup.mapper.UserMapper;
import com.hln.daydayup.service.TaskService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

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
public class TaskServiceImpl extends ServiceImpl<TaskMapper, Task> implements TaskService {

    @Autowired
    UserMapper userMapper;
    @Autowired
    DetailtaskMapper detailtaskMapper;
    @Autowired
    TaskMapper taskMapper;

    @Override
    public List<TaskView> allTasks(List<RelationDto> users,Integer counts) throws ParseException {

        List<TaskView> taskViews = new ArrayList<>();
        /*
        * RelationDto：
        * getNames:账户名字
        * getUserId：账户id
        * */
        for (RelationDto user : users) {

            QueryWrapper<Task> wrapper = new QueryWrapper<>();
            /*这个用户的各个账户的名称  对于每个名称 进行确定 搜索到
            * 对应的task 拿到id到detail里面去找  插入
            * 每次找到的就是一个用户子用户的所有日程信息
            * account 是phone
            * uniqueId 是 id
             */
            wrapper.eq("uniqueId", user.getUserId());
            List<Task> tasks = taskMapper.selectList(wrapper);
            System.out.println(tasks);
            for (Task task : tasks) {
                TaskView taskView = new TaskView();

                BeanUtils.copyProperties(task,taskView);

                //如果是周期性的  往后加三个月的日程
                if(task.getPeriod()!=0){
                    List<TaskView> taskPeriods = addPriodTasks(taskView, 3,counts);
                    taskViews.addAll(taskPeriods);
                }else {
                    taskView.setDetailtaskList(getDetailTask(task.getId()));
                    System.out.println(taskView.getDetailtaskList().size());
                    taskViews.add(taskView);
                }
            }
            System.out.println("======================================");
        }
        log.info("alltaskViews:",taskViews);
        return taskViews;
    }

    @Override
    public boolean outTimeDate(String newDay) {
        boolean tasks = taskMapper.outTimeDate(newDay);
        return tasks;
    }

    @Override
    public boolean doneDate(String newDay) {
        boolean tasks = taskMapper.doneDate(newDay);
        return tasks;
    }

    @Override
    public List<TaskView> getTask(String userId,Integer counts) {
        QueryWrapper<Task> wrapper = new QueryWrapper<>();
        wrapper.eq("uniqueId",userId);
        List<Task> tasks = taskMapper.selectList(wrapper);
        if(tasks == null ||tasks.size()==0)
            return null;
        List<TaskView> taskViews = new ArrayList<>();
        for (Task task : tasks) {
            TaskView taskView = new TaskView();
            BeanUtils.copyProperties(task,taskView);
            if(task.getPeriod()!=0){
                List<TaskView> taskPeriods = addPriodTasks(taskView, 3,counts);
                taskViews.addAll(taskPeriods);
            }else {
                taskView.setDetailtaskList(getDetailTask(task.getId()));
                taskViews.add(taskView);
            }
        }

        return taskViews;
    }

    public List<Detailtask> getDetailTask(Integer parentId){
        QueryWrapper<Detailtask> detailWrapper = new QueryWrapper<>();
        detailWrapper.eq("parent_id",parentId);
        return detailtaskMapper.selectList(detailWrapper);
    }

    private List<TaskView> addPriodTasks(TaskView taskView,Integer Month,Integer counts){

        SimpleDateFormat srtFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date date = null;
        Date deadDate;
        int period = taskView.getPeriod();
        String startDate = taskView.getStartDate();
        String deadLine = taskView.getDeadLine();

        List<TaskView> taskviews = new ArrayList<>();

        try {
            //c1是时间的最终日期
            date = srtFormat.parse(startDate);

            //解析事件的截止时间
            deadDate = srtFormat.parse(deadLine);

            //当前时间
            Calendar c1 = Calendar.getInstance();

            Calendar c2 = Calendar.getInstance();
            c2.setTime(date);

            Calendar c3 = Calendar.getInstance();
            c3.setTime(deadDate);

            String formatStart;
            String formatEnd;
            //3 个月后的时间
            int eventNum = 0;

            while(c2.before(c1)){
                c2.add(Calendar.DATE, period);
                c3.add(Calendar.DATE, period);
                System.out.println(c2.getTime()+"循环到当前时间");
            }

            date = c2.getTime();
            deadDate = c3.getTime();
            //返回十条数据
            for(;eventNum<counts;eventNum++) {

                //周期新的添加返回的数据   用于添加数据
                TaskView tmp = new TaskView();

                BeanUtils.copyProperties(taskView, tmp);

                formatStart = srtFormat.format(date);
                formatEnd = srtFormat.format(deadDate);
                /*
                 * 开始时间截止时间都需要变换
                 * */
                tmp.setStartDate(formatStart);
                tmp.setDeadLine(formatEnd);

                tmp.setDetailtaskList(getDetailTask(taskView.getId()));
                //添加进去
                taskviews.add(tmp);

                c2.setTime(date);
                c2.add(Calendar.DATE, period);
                date = c2.getTime();

                c3.setTime(deadDate);
                c3.add(Calendar.DATE, period);
                deadDate = c3.getTime();

                System.out.println(tmp.getDetailtaskList().size());
                System.out.println(tmp);
                System.out.println(formatStart);
            }
        } catch (ParseException e) {
            e.printStackTrace();
        }
        System.out.println(taskviews);
        return taskviews;
    }
}
