package com.hln.daydayup.transferDate.input;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.hln.daydayup.dto.DateEventDto;
import com.hln.daydayup.transferDate.util.HttpUtils;

import java.util.List;


public class VoiceInput{

    public static List<DateEventDto> getVoiceEvent(int len, String speech){

        JsonObject newReq = new JsonObject();
        newReq.addProperty( "format","pcm");
        newReq.addProperty( "rate",16000);
        newReq.addProperty(  "channel",1);
        newReq.addProperty(  "token","24.6d6fd6423a1ab3b308981cedca9881a2.2592000.1666059434.282335-27518975");
        newReq.addProperty( "len",len);
        newReq.addProperty( "cuid", "B0-68-E6-99-57-05");
        newReq.addProperty( "speech",speech);
        String url = "http://vop.baidu.com/server_api";

        String jsonRes = HttpUtils.sendPostWithJson(url,newReq.toString());
        JsonParser jp = new JsonParser();
        //将json字符串转化成json对象
        JsonObject jo = jp.parse(jsonRes).getAsJsonObject();
        //获取message对应的值
        String speechRes = jo.get("result").getAsString();

        speechRes.replaceAll("，","。");

        return DateEvent.timeExtr(speechRes);

    }

}
