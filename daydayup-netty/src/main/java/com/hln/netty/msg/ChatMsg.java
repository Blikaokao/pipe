package com.hln.netty.msg;

import lombok.Data;

@Data
public class ChatMsg extends NettyMsg {
    //消息发送方
    private Integer fid;

    //消息的接受方
    private Integer tid;

    private String content;
}
