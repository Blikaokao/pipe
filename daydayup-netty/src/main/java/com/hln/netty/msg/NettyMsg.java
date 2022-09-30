package com.hln.netty.msg;

import lombok.Data;

import java.io.Serializable;

@Data
public class NettyMsg implements Serializable { //作为网络传输的对象，必须要实现序列化
    /**
     * 1.新连接
     * 2.心跳
     * 3.聊天消息
     * 4.正在输入
     * 5.结束输入
     * 6.挤下线
     * 7.好友添加
     */
    private Integer type;
    
    //客户端的设备id    微信端的用户的id
    private String did;
}