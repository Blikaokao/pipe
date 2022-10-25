package com.hln.daydayup.controller;


import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.hln.daydayup.base.Response;
import com.hln.daydayup.constant.LabelStatus;
import com.hln.daydayup.dto.*;
import com.hln.daydayup.entity.Detailtask;
import com.hln.daydayup.entity.Miniuser;
import com.hln.daydayup.entity.Task;
import com.hln.daydayup.entity.User;
import com.hln.daydayup.exception.DateInputException;
import com.hln.daydayup.service.DetailtaskService;
import com.hln.daydayup.service.MiniuserService;
import com.hln.daydayup.service.impl.TaskServiceImpl;
import com.hln.daydayup.service.impl.UserServiceImpl;
import com.hln.daydayup.transferDate.input.*;
import com.hln.daydayup.transferDate.util.Base64Util;
import com.hln.daydayup.utils.EncodeFile;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.ParseException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * <p>
 *  前端控制器
 * </p>
 *
 * @author lina
 * @since 2022-03-16
 */
@Slf4j
@RestController
@RequestMapping("/oneDayTask")
public class TaskController {
    @Autowired
    TaskServiceImpl taskService;
    @Autowired
    DetailtaskService detailtaskService;
    @Autowired
    UserServiceImpl userService;
    @Autowired
    MiniuserService miniuserService;
    @PostMapping("/getDetailTask/{taskId}")
    public Response getDetailTask(@PathVariable Integer taskId){
        Task task = taskService.getById(taskId);
        TaskView taskView = new TaskView();
        BeanUtils.copyProperties(task,taskView);
        taskView.setDetailtaskList(taskService.getDetailTask(taskId));
        return Response.success(taskView);
    }
    /*
    * 三种方法调用
    * */
    @PostMapping("/byPhoto")
    public Response byPhoto(@RequestBody InputMedia img){
        List<DateEventDto> dateEventDtos;
        System.out.println(img.getImg());

        System.out.println(img);
        try {
            dateEventDtos = PhotoInput.getPhotoEvent(img.getImg());
        } catch (Exception e) {
            return Response.success("fail");
        }
        /*
        * 开始时间结束时间 事件内容
        *
        * */
        if (dateEventDtos==null || dateEventDtos.size()==0)
            return Response.fail("noEvents");
        log.info("传入对象为："+img+"字节码："+img.getImg());
        System.out.println("date:"+dateEventDtos);
        return Response.success(dateEventDtos);
    }

    @PostMapping("/byPhotoWeb")
    public Response byPhotoWeb(@RequestBody MultipartFile img) throws Exception {
        System.out.println("byPhotoWeb");
        byte[] bytes = img.getBytes();
        System.out.println("bytes="+bytes);
        String encode = Base64Util.encode(bytes);

        List<DateEventDto> dateEventDtos;
        try {
            dateEventDtos = PhotoInput.getPhotoEvent(encode);
        } catch (Exception e) {
           e.printStackTrace();
            return Response.success("fail");
        }
        /*
         * 开始时间结束时间 事件内容
         *
         * */
        System.out.println("传入对象为："+img+"字节码："+bytes.toString());
        System.out.println("date:"+dateEventDtos);
        /*String taskName = dateEventDto.getTaskName();
        System.out.println(taskName);
        byte[] gbks = taskName.getBytes("GBK");
        taskName = new String(gbks, "UTF-8");
        System.out.println(taskName);
        dateEventDto.setTaskName(taskName);*/
        return Response.success(dateEventDtos);
    }

    @PostMapping("/byClassTask")
    public Response byClassTask(@RequestBody InputMedia img){
        try {
            ClassTable classTable = TableInput.getClassTable(img.getImg());
            System.out.println("weeklessiondto:" + classTable.getWeekLession());
            return Response.success(classTable.getWeekLession());
        } catch (Exception e) {
            return Response.fail("error!");
        }
    }

    @PostMapping("/byClassTaskWeb")
    public Response byClassTask(@RequestBody MultipartFile img) throws IOException {

        byte[] bytes = img.getBytes();
        System.out.println("bytes=" + bytes);
        String encode = Base64Util.encode(bytes);
        try {
            ClassTable classTable = TableInput.getClassTable(encode);
            classTable.outPutAllClass();

            System.out.println("weeklessiondto:" + classTable.getWeekLession());
            return Response.success(classTable.getWeekLession());
        } catch (Exception e) {
            return Response.fail("error!");
        }
    }

    @PostMapping("/byVoice")
    public Response byVoice(@RequestBody InputMedia voice) {

        log.info("voice{}",voice);
        List<DateEventDto> dateEventDtos;
        dateEventDtos = VoiceInput.getVoiceEvent(voice.getLen(),voice.getSpeech());

        if (dateEventDtos==null || dateEventDtos.size()==0)
            return Response.fail("noEvents");
        System.out.println("传入对象为："+voice+"长度："+voice.getLen()+"字节码："+voice.getSpeech());

        System.out.println("date:"+dateEventDtos);
        return Response.success(dateEventDtos);
    }

    @PostMapping("/byVoiceMini")
    public Response byVoiceMini(@RequestBody MultipartFile voiceFile) throws Exception {

        System.out.println(voiceFile);
        InputMedia voice = new InputMedia();
        voice.setSpeech(Base64Util.encode(voiceFile.getBytes()));
        voice.setLen(voiceFile.getBytes().length);
        log.info("voice{}",voice);
        List<DateEventDto> dateEventDtos;
        dateEventDtos = VoiceInput.getVoiceEvent(voice.getLen(),voice.getSpeech());
        if (dateEventDtos==null || dateEventDtos.size()==0)
            return Response.fail("noEvents");
        System.out.println("传入对象为："+voice+"长度："+voice.getLen()+"字节码："+voice.getSpeech());

        System.out.println("date:"+dateEventDtos);
        return Response.success(dateEventDtos);
    }

    @PostMapping("/byText")
    public Response byText(@RequestBody InputMedia schedule){
        System.out.println("===========byText===========");
        List<DateEventDto> dateEventDtos;
        dateEventDtos = DateEvent.timeExtr(schedule.getText());

        if (dateEventDtos==null || dateEventDtos.size()==0)
            return Response.fail("noEvents");

        System.out.println("date:"+dateEventDtos);

        return  Response.success(dateEventDtos);
    }



    @PostMapping("/byTextWeb")
    public Response byTextWeb(@RequestBody InputMedia schedule){
        System.out.println("===========byTextWeb===========");
        List<DateEventDto> dateEventDtos;
        dateEventDtos = DateEvent.timeExtr(schedule.getText());
        /*String taskName = dateEventDto.getTaskName();
        System.out.println(taskName);

        dateEventDto.setTaskName(taskName);*/

        if (dateEventDtos==null || dateEventDtos.size()==0)
            return Response.fail("noEvents");

        System.out.println("date:"+dateEventDtos);

        return  Response.success(dateEventDtos);
    }
    /*
    * 增加字段
    * tasktype当做用户的输入方式
    * alert当做用户设置的提醒时间 提前 minutes
    * */

    /////TODO 改  添加为微信用户的信息   openid 作为userId
    @PostMapping("/createTask/{userId}")
    public Response createTask(@RequestBody List<TaskView> taskViews,@PathVariable("userId") String userId){


        //多任务添加

        /*
        * 设置账号名称等信息 然后将手机号给存储--能够知道是谁的日程
        * */
        /*
        * 对于子任务数的设置 应该是前端去统计（一次性添加多个 没有请求无法判断 或者拿list的大小）
        * */
        if(taskViews == null || taskViews.size()==0)
            return Response.fail("no tasks");

        log.info(taskViews.toString());

        //微信用户 查询
        Miniuser miniUser = miniuserService.getOneByOpenId(userId);
        //移动端用户 查询
        User user = userService.getById(userId);
        if(user == null && miniUser==null)
            return Response.fail("请先登录！！");

        try {
            if(user != null) {
                userService.setTasks(taskViews, userId);
                return Response.success();
            }else if(miniUser !=null){
                miniuserService.setTasks(taskViews, userId);
                return Response.success();
            }
        } catch (DateInputException e) {
            System.err.println("date error!");
        }
        return Response.fail("DateError");
    }

    /*
     * 得到账号用户以及对应的子用户信息
     * 用的是电话和密码登录 一旦登录成功将用户id返回
     *
     *
     * 需要把uniqueid做视图改成用户id
     * */
    ////////TODO 改   得到用户信息
    @PostMapping("/getAllTasks/{userId}")
    public Response getAll(@PathVariable String userId,@RequestParam(required = false)Integer counts,@RequestParam(required = false)String nickName)throws Exception {
        User user = userService.getById(userId);
        Miniuser miniuser = miniuserService.getOneByOpenId(userId);
        if (user == null && miniuser == null)
            return Response.fail("no user");
        /*else if(miniuser ==  null && nickName != null){
            miniuserService.save(new Miniuser(userId,nickName));
            return Response.success("wx register");
        }*/

        List<RelationDto> allUsers = new ArrayList<>();
        if(user != null)
            allUsers = userService.getAllUsers(user);
        else if(miniuser != null)
            allUsers =  miniuserService.getAllUsers(miniuser);
        if(counts == null)
            counts = 2;

        //根据用户得到所有的任务
        List<TaskView> taskViews = taskService.allTasks(allUsers, counts);
        System.out.println(counts);
        return Response.success(taskViews);
    }

    ////////TODO 3 改  用户信息  得到用户的日程
    @PostMapping("/getTasks/{userId}")
    public Response getOne(@PathVariable String userId,@RequestParam(required = false)Integer counts,@RequestParam(required = false)String nickName) {
        log.info(userId);
        log.info(nickName);
        if(counts == null)
            counts = 10;
        User user = userService.getById(userId);
        Miniuser miniuser = miniuserService.getOneByOpenId(userId);

        if (user == null && nickName == null)
            return Response.fail("no user");
        else if(miniuser ==  null && nickName != null){
            miniuserService.save(new Miniuser(userId,nickName));
            return Response.success();
        }else if(miniuser != null){
            if(! miniuser.getNickName().equals(nickName)){
                log.info("用户为角色用户");
                userId = userId+"_"+nickName;
                log.info(userId);
            }
        }
        List<TaskView> task = taskService.getTask(userId, counts);
        Map<String,Object> map = new HashMap<>();
        map.put("task",task);
        map.put("role",userId);
        return Response.success(map);
    }

    //日程表系列
    @PostMapping("/getAllClass/{userId}")
    public Response getAllClass(@PathVariable String userId) {
        List<TaskView> task = taskService.getTask(userId, 1);
        List<TaskView> taskClass = new ArrayList<>();
        for (TaskView taskView : task) {
            if (taskView.getEventType() == 1)
                taskClass.add(taskView);
        }
        if (taskClass != null && taskClass.size()>0)
            return Response.success(taskClass);
        return Response.fail("noClass");
    }

    //修改日程   拿的是 日程的id去改
    @PostMapping("/updateTask")
    public Response updateTask(@RequestBody TaskView taskView, HttpServletResponse response, HttpServletRequest request){


        /*
        * 修改的是任务或者子任务  遍历一遍好了
        *
        * 如果已经同步了之后进行修改？？
        * 在数据同步的时候需要考虑到数据库中原有的数据??
        *
        *
        * 改taskname
        * 改detailname
        * */
        //taskname
        Task task = new Task();
        BeanUtils.copyProperties(taskView,task);
        System.out.println(taskView);
        System.out.println(task.getTaskName());
        System.out.println("==================================");
        taskService.updateById(task);
        QueryWrapper<Detailtask> detailWrapper = new QueryWrapper<>();
        detailWrapper.eq("parent_id",task.getId());
        //将从表数据全部删除之后重新赋值
        detailtaskService.remove(detailWrapper);

        List<Detailtask> detailtaskList = taskView.getDetailtaskList();
        if(detailtaskList == null || detailtaskList.size()==0 )
            return Response.success("无子日程");
        for (Detailtask detailtask : detailtaskList) {
            detailtask.setParentId(task.getId());
            detailtaskService.save(detailtask);
        }
        return Response.success("有子日程");
    }

    @PostMapping("/deleteTask/{id}")
    public Response deleteTask(@PathVariable Integer id){
        //先删除从表数据
        QueryWrapper<Detailtask> wrapper = new QueryWrapper<>();
        wrapper.eq("parent_id",id);
        detailtaskService.remove(wrapper);
        //删除主表
        taskService.removeById(id);
        return Response.success();
    }
    /*
    * 效率
    * */
    //得到每个用户的日程数目  父级任务
    @PostMapping("/getTasksCount")
    public Response getTasksCount(@RequestBody List<String> ids){
        List<Integer> counts = new ArrayList<>();
        for (String id : ids) {
            List<TaskView> task = taskService.getTask(id,1);
            int i = task == null ? 0 : task.size();
            counts.add(i);
        }     
        return Response.success(counts);
    }

    //子任务数目
    @PostMapping("/getDetailCount")
    public Response getDetailCount(@RequestBody List<String> ids){
        List<Integer> counts = new ArrayList<>();
        for (String id : ids) {
            List<TaskView> task = taskService.getTask(id,1);
            int detailCount = 0;
            if (task != null && task.size() != 0) {
                for (TaskView taskView : task) {
                    detailCount += taskView.getDetailtaskList().size();
                }
            }
            counts.add(detailCount);
        }
        return Response.success(counts);
    }

    /*
    * 统计所有类型
    * */
    @PostMapping("/getAllType/{id}")
    public Response getAllType(@PathVariable Integer id)throws Exception{
        List<RelationDto> allUsers = userService.getAllUsers(userService.getById(id));

        List<TaskView> taskViews = taskService.allTasks(allUsers,1);

        Map<String,Integer> map = new HashMap<>();
        int text = 0;
        int photo = 0;
        int voice = 0;
        for (TaskView taskView : taskViews) {
            String taskType = taskView.getTaskType();
            if(taskType.equals("1"))
                text++;
            else if(taskType.equals("2"))
                photo++;
            else voice++;
        }
        map.put("text",text);
        map.put("photo",photo);
        map.put("voice",voice);
        System.out.println(map);
        return Response.success(map);
    }

    //得到用户所有任务的状态(包含子用户任务状态）
    /*
    * 需要修改过于复杂
    * */
    @PostMapping("/allStatus/{id}")
    public Response getAllStatus(@PathVariable Integer id)throws Exception{
        Map<String,Integer> map = new HashMap<>();
        int todo = 0;
        int done = 0;
        int outTime = 0;

        List<RelationDto> users = userService.getAllUsers(userService.getById(id));

        List<TaskView> taskViews = taskService.allTasks(users,1);
        for (TaskView taskView : taskViews) {
            int status=taskView.getTaskStatus();
            System.out.println(taskView);
            if(status==0)
                todo++;
            else if(status == 1)
                done++;
            else
                outTime++;
        }
        map.put("todo",todo);
        map.put("done",done);
        map.put("outTime",outTime);
        return Response.success(map);
    }

    /*TODO 搜索任务   关键词搜索 ES
     */
}

