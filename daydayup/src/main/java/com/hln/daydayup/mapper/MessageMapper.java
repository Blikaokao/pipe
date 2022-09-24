package com.hln.daydayup.mapper;

import com.hln.daydayup.utils.MessageUtils;
import com.hln.daydayup.utils.SendMessageSUtils;

public class MessageMapper {
    public static String sendMessage(String phoneNum){
        /*
         * 传入手机号
         * 短信验证码
         * 短信模板ID
         * */
        String Myappcode = "2f05564bfc734941a7990cd89b44bd23";
        Integer param = MessageUtils.generateValidateCode(6);
        SendMessageSUtils.sendShortMessage(Myappcode,phoneNum,param.toString(),"10");
        return param.toString();
    }
}
