package com.hln.netty.handler;


import cn.hutool.json.JSONUtil;
import com.hln.netty.group.ChannelGroup;
import com.hln.netty.msg.AddMsg;
import com.hln.netty.msg.ConnMsg;
import com.hln.netty.msg.HeartMsg;
import com.hln.netty.msg.NettyMsg;
import io.netty.channel.ChannelHandler;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.handler.codec.http.websocketx.TextWebSocketFrame;

@ChannelHandler.Sharable
public class WebSocketHandler extends SimpleChannelInboundHandler<TextWebSocketFrame> {
    @Override
    protected void channelRead0(ChannelHandlerContext channelHandlerContext, TextWebSocketFrame textWebSocketFrame) throws Exception {
        String text = textWebSocketFrame.text();
        NettyMsg nettyMsg = JSONUtil.toBean(text, NettyMsg.class);

        Integer type = nettyMsg.getType();
        if(type.equals(1)){
            //表示是“连接”的消息类型
            nettyMsg = JSONUtil.toBean(text, ConnMsg.class);
        }else if(type.equals(2)){
            //心跳
            //channelHandlerContext.channel().writeAndFlush(new TextWebSocketFrame("嗯！"));
            nettyMsg = JSONUtil.toBean(text, HeartMsg.class);
        }else if(type.equals(3)){
            //添加好友
            nettyMsg = JSONUtil.toBean(text, AddMsg.class);
        }
        //往下传递
        channelHandlerContext.fireChannelRead(nettyMsg);
    }

    @Override
    public void channelRegistered(ChannelHandlerContext ctx) throws Exception {
        System.out.println("新客户端连接");
        TextWebSocketFrame resp = new TextWebSocketFrame("heart");
        ctx.writeAndFlush(resp);
        System.out.println("发送心跳");
    }

    @Override
    public void channelUnregistered(ChannelHandlerContext ctx) throws Exception {
        System.out.println("客户端断开连接");
        ChannelGroup.removeChannel(ctx.channel());
    }
}
