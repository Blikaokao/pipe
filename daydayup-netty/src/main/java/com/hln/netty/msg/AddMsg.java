package com.hln.netty.msg;

import lombok.Data;

/**
*根据手机号去添加微信号
*@author lina
*date:2022-09-22
*/
@Data
public class AddMsg extends NettyMsg {

    //发送方
    private String fid;

    //接收方   接收方的tid
    private String tid;

    //请求状态
    /*  需要做下处理
    * 1:待同意 fid  ---  待处理 tid
    * 2：拒绝
    * 3：过期
    * */
    private Integer status;

}
