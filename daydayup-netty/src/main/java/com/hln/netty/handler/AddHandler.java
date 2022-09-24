package com.hln.netty.handler;

import com.hln.netty.msg.AddMsg;
import com.hln.netty.msg.ChatMsg;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import org.springframework.amqp.rabbit.core.RabbitTemplate;

/*
* 好友添加请求
* */
public class AddHandler extends SimpleChannelInboundHandler<AddMsg> {

    private RabbitTemplate rabbitTemplate;

    public AddHandler(RabbitTemplate rabbitTemplate){
        this.rabbitTemplate = rabbitTemplate;
    }

    @Override
    protected void channelRead0(ChannelHandlerContext channelHandlerContext, AddMsg addMsg) throws Exception {
        System.out.println("发送好友添加消息"+addMsg.toString());
        rabbitTemplate.convertAndSend("wx_exchange","",addMsg);
    }
}
