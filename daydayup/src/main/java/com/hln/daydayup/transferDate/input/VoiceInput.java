package com.hln.daydayup.transferDate.input;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.hln.daydayup.dto.DateEventDto;
import com.hln.daydayup.transferDate.util.HttpUtils;
import lombok.extern.slf4j.Slf4j;

import java.util.List;

@Slf4j
public class VoiceInput{

    public static List<DateEventDto> getVoiceEvent(int len, String speech){

        log.info("开始转换");
        JsonObject newReq = new JsonObject();
        newReq.addProperty( "format","pcm");
        newReq.addProperty( "rate",16000);
        newReq.addProperty(  "channel",1);
        newReq.addProperty(  "token","24.3ad6c77e79dc699d71830fdf58de5771.2592000.1667309846.282335-27729452");
        newReq.addProperty( "len",len);
        newReq.addProperty( "cuid", "AA-39-26-12-67-87");
        newReq.addProperty( "speech",speech);
        String url = "http://vop.baidu.com/server_api";

        log.info("newReq{}",newReq);
        String jsonRes = HttpUtils.sendPostWithJson(url,newReq.toString());
        log.info(jsonRes);
        JsonParser jp = new JsonParser();
        //将json字符串转化成json对象
        JsonObject jo = jp.parse(jsonRes).getAsJsonObject();
        //获取message对应的值
        String speechRes = jo.get("result").getAsString();

        speechRes.replaceAll("，","。");

        return DateEvent.timeExtr(speechRes);

    }

}
