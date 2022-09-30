package com.hln.config;

import cn.hutool.json.JSONUtil;
import com.hln.netty.group.ChannelGroup;
import com.hln.netty.msg.AddMsg;
import com.hln.netty.msg.ChatMsg;
import com.hln.netty.msg.ShutDownMsg;
import io.netty.channel.Channel;
import io.netty.handler.codec.http.websocketx.TextWebSocketFrame;
import org.springframework.amqp.rabbit.annotation.RabbitHandler;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;


@Component
public class WsQueueListener {

   /* @RabbitHandler
    public void wsMsg(ShutDownMsg shutDownMsg){
        //查看当前设备号是否在本机
        String did = shutDownMsg.getDid();
        Channel channel = ChannelGroup.getChannel(did);
        if(channel != null){
            //转成json 放进去数据帧里面
            String jsonStr = JSONUtil.toJsonStr(shutDownMsg);
            TextWebSocketFrame resp = new TextWebSocketFrame(jsonStr);
            channel.writeAndFlush(resp);
        }
    }*/

    @RabbitHandler
    @RabbitListener(queues = "ws_queue_${netty.port}")
    public void addRequestMsg(String jsonStr){
        //查看当前接收方是否在本机  --因为分布式有这个判断  单机直接写就行
        /*
        * 这里可以理解成是否在线  当用户下线之后通道关闭 只放入数据库中
        * 针对单机来讲  分布式有重复添加的问题
        * */

        //前端根据addMsg里的status值 更新本地缓存
        /*
        * 同意还是拒绝  还是新的好友添加请求
        * 前端利用值不同  进行不同的页面显示
        * */
        AddMsg addMsg = JSONUtil.toBean(jsonStr, AddMsg.class);
        Integer tid = addMsg.getTid();
        Channel channel = ChannelGroup.getChannel(tid.toString());
        System.out.println("拿到了发送好友请求的消息"+addMsg);
        if (channel != null) {
            //转成json 放进去数据帧里面
            System.out.println("channel!=null");
            String toJsonStr = JSONUtil.toJsonStr(addMsg);
            TextWebSocketFrame resp = new TextWebSocketFrame(toJsonStr);
            //好友添加消息发送过去
            channel.writeAndFlush(resp);
        }

    }

    /*@RabbitHandler
    public void chatMsg(ChatMsg chatMsg){
        //根据监听消息的类型进行处理
        //查看设备号是否在本机
        String did = redisTemplate.opsForValue().get(chatMsg.getTid().toString());
        if(!StringUtils.isEmpty(did)){
            Channel channel = ChannelGroup.getChannel(did);
            TextWebSocketFrame textWebSocketFrame = new TextWebSocketFrame(JSONUtil.toJsonStr(chatMsg));
            channel.writeAndFlush(chatMsg);
        }

    }*/
}