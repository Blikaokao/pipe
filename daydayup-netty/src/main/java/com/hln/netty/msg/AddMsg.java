package com.hln.netty.msg;

import lombok.Data;


/**
*根据手机号去添加微信号
*@author lina
*date:2022-09-22
*/
@Data
public class AddMsg extends NettyMsg {

    {
        setType(7);
    }
    //发送方
    private Integer fid;

    //接收方   接收方的tid
    private String tName;

    private Integer tid;

    //请求状态
    /*  需要做下处理
    * 1:待处理 fid  ---  待处理 tid
    * 2：拒绝
    * 3：同意
    * 4：过期
    * */
    private Integer status;

}
