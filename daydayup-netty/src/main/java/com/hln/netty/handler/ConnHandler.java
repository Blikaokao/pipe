package com.hln.netty.handler;

import cn.hutool.json.JSONUtil;
import com.hln.netty.group.ChannelGroup;
import com.hln.netty.msg.ConnMsg;
import com.hln.netty.msg.ShutDownMsg;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.handler.codec.http.websocketx.TextWebSocketFrame;
import org.springframework.data.redis.core.StringRedisTemplate;

public class ConnHandler extends SimpleChannelInboundHandler<ConnMsg> {
    private StringRedisTemplate redisTemplate;

    //利用构造器注入  因为这个类不是spring自己的bean  是我们自己new出来的 所以需要从外面来传一个
    public ConnHandler(StringRedisTemplate redisTemplate){
        this.redisTemplate = redisTemplate;
    }

    @Override
    protected void channelRead0(ChannelHandlerContext channelHandlerContext, ConnMsg connMsg) throws Exception {
        System.out.println("发送链接消息"+connMsg.toString());
        ChannelGroup.addChannel(connMsg.getDid(),channelHandlerContext.channel());


        TextWebSocketFrame resp = new TextWebSocketFrame(JSONUtil.toJsonStr(connMsg));
        channelHandlerContext.writeAndFlush(resp);
    }
}
