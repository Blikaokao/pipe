package com.hln.daydayup.controller;


import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.hln.daydayup.base.Response;
import com.hln.daydayup.dto.RelationDto;
import com.hln.daydayup.dto.TaskView;
import com.hln.daydayup.entity.FriendRequest;
import com.hln.daydayup.entity.Miniuser;
import com.hln.daydayup.entity.Relation;
import com.hln.daydayup.entity.User;
import com.hln.daydayup.mapper.UserMapper;
import com.hln.daydayup.msg.AddMsg;
import com.hln.daydayup.service.*;
import com.hln.daydayup.service.impl.UserServiceImpl;
import com.hln.daydayup.utils.SnowflakeIdWorker;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.AmqpException;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import org.springframework.stereotype.Controller;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * <p>
 *  前端控制器
 * </p>
 * 用户注册类
 * 子用户密码为空  只有一个id 和父账号id  名字
 * @author lina
 * @since 2022-03-16
 */
@Slf4j
@RestController
@RequestMapping("/fUser")
public class UserController {

    @Autowired
    private UserServiceImpl userService;
    @Autowired
    private RelationService relationService;
    @Autowired
    private DetailtaskService detailtaskService;
    @Autowired
    private MiniuserService miniuserService;
    @Autowired
    private FriendRequestService friendRequestService;
    @Autowired
    private RabbitTemplate rabbitTemplate;

    //微信小程序的注册
    @PostMapping("/registermini/{openid}/{nickName}")
    public Response registermini(@PathVariable("openid")String openid,@PathVariable("nickName")String nickName){

        try {
            miniuserService.save(new Miniuser(openid,nickName));
            return Response.success("success");
        } catch (Exception e) {
            log.info(e.getMessage());
        }
        return  Response.fail("fail");
    }

    @PostMapping("/login")
    public Response login(@RequestBody User user){
        List<RelationDto> users = userService.findUsers(user);
        //登录成功保存
        if(users!=null) return Response.success(users);
        return Response.fail("fail");
    }

    /*
    * 拿到所有的用户
    * */
    @GetMapping("/getAllUsers/{id}")
    public Response login(@PathVariable("id") String id){
        List<RelationDto> allUsers = userService.getAllUsers(userService.getById(id));
        return Response.success(allUsers);
    }


    /*
    * 传入用户id
    *
    * */
    @GetMapping("/getusers/{id}")
    public Response getUsers(@PathVariable("id")Integer id){
        User user = userService.getById(id);
        List<RelationDto> allUsers = userService.getAllUsers(user);
        log.info(allUsers.toString());
        return Response.success(allUsers);
    }

    /*
    * 得到所有的用户  微信小程序
    * */
    @GetMapping("/getMiniusers/{id}")
    public Response getMiniUsers(@PathVariable("id")String id){
        Miniuser user = miniuserService.getOneByOpenId(id);
        List<RelationDto> allUsers = miniuserService.getAllUsers(user);
        log.info(allUsers.toString());
        return Response.success(allUsers);
    }

    /*
    * 创建子用户
    * */
    @PostMapping("/createChild/{id}/{phone}/{name}")
    public Response createChild(@PathVariable("id") Integer id,@PathVariable("phone") String phone,@PathVariable("name") String name){
        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("name",name).eq("parent_id",id);
        User one = userService.getOne(wrapper);
        log.info("==="+one+"===");
        /*
        * 存在已有子用户 提示重复
        * 不存在  为用户创建子用户
        * */
        if(one==null) {
            User user = new User();
            user.setPhone(phone);
            user.setName(name);
            user.setParentId(id);
            userService.save(user);
            return Response.success(user.convertToRelationDto(1),"成功添加");
        }else return Response.success("已添加过该角色");
    }


    /*
    * TODO 目前只做创建用户  不做微信小程序用户之间的关联  问题
    *       涉及到一个消息发送的问题
    * */
    @PostMapping("/createMiniChild/{openid}/{nickName}")
    public Response createMiniChild(@PathVariable("openid") String openid,@PathVariable("nickName") String nickName){
        QueryWrapper<Miniuser> wrapper = new QueryWrapper<>();

        Miniuser oneByOpenId = miniuserService.getOneByOpenId(openid);

        wrapper.eq("nick_name",nickName).eq("parent_id",oneByOpenId.getId());
        Miniuser miniuser = miniuserService.getOne(wrapper);
        log.info("===miniuser==="+miniuser+"===");
        /*
         * 存在已有子用户 提示重复
         * 不存在  为用户创建子用户
         * */
        if(miniuser==null) {
            Miniuser user = new Miniuser();
            user.setParentId(oneByOpenId.getId());
            user.setNickName(nickName);
            user.setOpenid(openid+"_"+nickName);
            miniuserService.save(user);
            return Response.success(user.convertToRelationDto(1),"成功添加");
        }else return Response.success("已添加过该角色");
    }



    /*
    * 关联用户   需要提供手机号等信息   进行验证
    *
    * 现在默认都同意
    * */
    @PostMapping("/createrelation/{id}/{relaphone}/{userName}")
    public Response createRelation(@PathVariable("id")Integer id,@PathVariable("relaphone")String relaphone,@PathVariable("userName")String userName){

        QueryWrapper<User> userWrapper = new QueryWrapper<>();
        userWrapper.eq("phone",relaphone)
                .eq("parent_id",0);
        User user = userService.getOne(userWrapper);

        if(user == null)
            return Response.fail("用户不存在");
        if(user.getId().equals(id))
            return Response.fail("无法添加自己");
        try {

            QueryWrapper<Relation> relationWrapper = new QueryWrapper<>();
            relationWrapper.eq("user_id",id)
                    .eq("friends",user.getId());
            Relation serviceOne = relationService.getOne(relationWrapper);

            if(serviceOne == null) {

                Relation relation = new Relation();
                relation.setUserId(id)
                        .setName(userName)
                        .setFriends(user.getId())
                        .setPhone(relaphone);
                relationService.save(relation);

                /*
                 *
                 * 放到MQ里面去发送消息
                 *
                 * 发送消息到关联用户取得同意
                 *
                 *客户端拿出来放到redis里面 去处理  设置过期时间
                 * */
                return Response.success(relation.convertToDto(),"成功添加");
            }

            return Response.fail(serviceOne.convertToDto(),"已经为关联好友状态");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return Response.fail("添加失败!");

    }

    //验证码登录
    //忘记密码之后通过手机验证码验证
    @PostMapping("/identifyCodeSend/{phone}")
    public Response loginByCode(@PathVariable("phone") String phone){
        if(phone.length()==11) {
            userService.saveCode(phone);
            return Response.success("sendOver");
        }else return Response.success("error");
    }

    //验证码验证
    @GetMapping("/identifyCodeCheck/{code}/{phone}")
    public Response identifyCode(@PathVariable String code,@PathVariable("phone") String phone){
        String result = userService.identifyCode(code,phone);
        /*
        * true表示验证成功
        * false表示验证失败
        * outTime表示验证码过期
        * */
        return Response.success(result);
    }

    //手机注册
    @PostMapping("/register/{phone}")
    public Response register(@PathVariable String phone){
        if(phone.length()==11 && userService.findByPhone(phone)) {
            //发送验证码  之后进行验证码的验证
            if(userService.saveCode(phone)) {
                //****** 之后进行密码设置  *******
                return Response.success("sendOver");
            }else
                return Response.fail("操作频繁，请稍后尝试");
        }
        //手机号错误或已经注册
        return Response.success("error");
    }


    //用户注册验证后进行密码设置---web的
    @PostMapping("/setPassWeb/{passwd}/{phone}/{code}")
    public Response insertUser_Old(@PathVariable("passwd") String passwd,@PathVariable("phone") String phone,@PathVariable("code") String code){
         /*
         * 用户id 用户名 用户手机号  用户密码
         * */
        String result = userService.identifyCode(code,phone);
        if(result.equals("true")) {
            User user = new User();
            //雪花生成id
            SnowflakeIdWorker idWorker = new SnowflakeIdWorker(0, 0);
            user.setPasswd(passwd)
                    .setPhone(phone)
                    .setName(String.valueOf(idWorker.nextId()))
                    .setParentId(0);
            userService.save(user);
            //将用户返回前段保存用户
            return Response.success(user.convertToRelationDto(0),"success");
        }else if(result.equals("false"))
            return Response.success("false");
        else return Response.success("outTime");
    }

    //用户注册验证后进行密码设置
    @PostMapping("/setPass/{passwd}/{phone}")
    public Response insertUser(@PathVariable("passwd") String passwd,@PathVariable("phone") String phone) {
        /*
         * 用户id 用户名 用户手机号  用户密码
         * */
        User user = new User();
        //雪花生成id
        SnowflakeIdWorker idWorker = new SnowflakeIdWorker(0, 0);
        user.setPasswd(passwd)
                .setPhone(phone)
                .setName(String.valueOf(idWorker.nextId()))
                .setParentId(0);
        userService.save(user);
        //将用户返回前段保存用户
        return Response.success(user.convertToRelationDto(0), "success");
    }

    //用户名更新
    @PostMapping("/updateUserName/{userId}/{newName}")
    public Response updateUserName(@PathVariable("userId")String userId,@PathVariable("newName")String newName) {
        User user = userService.getById(userId);

        user.setName(newName);
        userService.updateById(user);

        return Response.success(user);
    }

    //忘记密码
    /*
     * 利用自己账号的手机号进行验证
     * 利用任何一个电话号码来验证重置密码
     * 但是账号就是手机  根据手机去重置密码
     * */
    @PostMapping("/forgetPassword/{phone}")
    public Response forgetPassword(@PathVariable String phone){
        //通过手机获取验证码之后重新设置密码
        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("phone",phone)
               .eq("parent_id",0);
        User user = userService.getOne(wrapper);
        if(user!=null) {
            userService.saveCode(phone);
            return Response.success("sendOver");
        }else
            //该账户不存在  ---跳转注册
            return Response.success("noAccount");
    }

    /*
    * 重新设置密码
    * */
    @PostMapping("/resetPassword/{newPwd}/{userId}")
    public Response resetPassword(@PathVariable("newPwd") String newPwd,@PathVariable("userId") String userId){
        User user = userService.getById(userId);
        user.setPasswd(newPwd);
        userService.updateById(user);
        return Response.success(user);
    }

    /*
    * 改名
    * type代表是关联的还是创建的还是自己
    * ****************************************
    * */
    @PostMapping("/reset")
    public Response resetUser(
            @RequestParam(required = false,value = "userId")Integer userId,
            @RequestBody RelationDto user){

        //被关联的账户 或者自己
        Integer id = user.getUserId();
        String name = user.getNames();
        if(user.getType() == 2){
            //如果是被关联的用户  需要去把主账户的id也传过来
            QueryWrapper<Relation> wrapper = new QueryWrapper<>();
            wrapper.eq("user_id",userId)
                    .eq("friends",id);

            Relation relation = relationService.getOne(wrapper);

            relation.setName(name);
            relationService.updateById(relation);

            return Response.success(relation.convertToDto());
        }
        User userNew = userService.getById(id);
        userNew.setName(name);
        userService.updateById(userNew);
        return Response.success(userNew.convertToRelationDto(user.getType()));
    }

    @DeleteMapping("/deleteUser/{userId}/{id}/{type}")
    public Response deleteUser(@PathVariable("userId")Integer userId,@PathVariable("id")Integer id,@PathVariable("type")Integer type){
        /*
        * userId : 主账户的id
        * id : 被删除账户的id
        * 1.如果是创建的用户  需要把创建的用户下的任务都删除掉
        *
        * */
        if(type == 1){
            //删除所有创建的日程 以及 子日程
            detailtaskService.deleteAllById(id.toString());
            //删除用户
            userService.removeById(id);
            return Response.success("删除成功");
        }else{
            //对于关联账号的删除
            QueryWrapper<Relation> wrapper = new QueryWrapper<>();
            wrapper.eq("user_id",userId)
                    .eq("friends",id);
            relationService.remove(wrapper);
            return Response.success("删除成功");
        }
    }


    @DeleteMapping("/deleteMiniUser/{id}")
    public Response deleteUser(@PathVariable("id")String id){
        /*
         * userId : 主账户的id
         * id : 被删除账户的id
         * 1.如果是创建的用户  需要把创建的用户下的任务都删除掉
         *
         * */

        //删除所有创建的日程 以及 子日程
        detailtaskService.deleteAllById(id);
        //删除用户
        miniuserService.removeById(id);
        return Response.success("删除成功");

    }

    @PostMapping("/add")
    public Response addUser(AddMsg addMsg){
        //保存好友添加消息到数据库 0表示待处理
        FriendRequest friendRequest = new FriendRequest();
        friendRequest.setTId(addMsg.getTid())
                .setFId(addMsg.getFid());
        try {
            //保存到数据库中
            friendRequestService.save(friendRequest);
            //发送消息  websocket去处理
            rabbitTemplate.convertAndSend("wx_exchange","",addMsg);
            return Response.success();
        } catch (AmqpException e) {
            e.printStackTrace();
        }
        return Response.fail("error");
    }

    @PostMapping("/addAck")
    public Response ackForAdd(AddMsg addMsg){
        Integer status = addMsg.getStatus();
        FriendRequest friendRequest = new FriendRequest();
        friendRequest.setTId(addMsg.getTid())
                .setFId(addMsg.getFid())
                .setStatus(addMsg.getStatus())
                .setCreateTime(addMsg.getCreate_time());
        if(status == 1) {
            //1接受  保存到数据库里面
            relationService.saveRelation(addMsg.getFid(), addMsg.getTid());
        }

        //接受拒绝都要更新状态
        friendRequestService.updateById(friendRequest);

        return Response.success();
    }

    @GetMapping("/getAllRequest")
    public Response getAllRequest(String openid){
        //寻找所有接收方是openid的未处理好友添加请求
        QueryWrapper<FriendRequest> wrapper = new QueryWrapper<>();
        wrapper.eq("t_id",openid)
                .eq("status",0);
        List<FriendRequest> friendRequests = friendRequestService.list(wrapper);
        return Response.success(friendRequests);
    }
}

