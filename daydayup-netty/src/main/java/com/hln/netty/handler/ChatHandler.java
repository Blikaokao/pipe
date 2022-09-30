package com.hln.netty.handler;


import com.hln.netty.msg.ChatMsg;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import org.springframework.amqp.rabbit.core.RabbitTemplate;

/*
* 有了websocket之后就直接在websocket里面进行处理就好了，就不用通过
* controller去请求之后在处理  都是消息一条龙处理掉
* 明白这个websocket的实质
* */
public class ChatHandler extends SimpleChannelInboundHandler<ChatMsg> {

    private RabbitTemplate rabbitTemplate;

    public ChatHandler(RabbitTemplate rabbitTemplate){
        this.rabbitTemplate = rabbitTemplate;
    }


    @Override
    protected void channelRead0(ChannelHandlerContext channelHandlerContext, ChatMsg chatMsg) throws Exception {
        rabbitTemplate.convertAndSend("ws_exchange","",chatMsg);
    }
}
