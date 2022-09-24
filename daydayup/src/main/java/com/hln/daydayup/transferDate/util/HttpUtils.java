package com.hln.daydayup.transferDate.util;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.methods.StringRequestEntity;


public class HttpUtils {

    public static String sendPostWithJson(String url, String jsonStr) {
        // 用于接收返回的结果
        String jsonResult = "";
        try {
            HttpClient client = new HttpClient();
            client.getHttpConnectionManager().getParams().setConnectionTimeout(3000); // //设置连接超时
            client.getHttpConnectionManager().getParams().setSoTimeout(180000); // //设置读取数据超时
            client.getParams().setContentCharset("UTF-8");
            PostMethod postMethod = new PostMethod(url);
            postMethod.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
            // 非空
            if (null != jsonStr && !"".equals(jsonStr)) {
                StringRequestEntity requestEntity = new StringRequestEntity(jsonStr, "application/json", "UTF-8");
                postMethod.setRequestEntity(requestEntity);
            }
            int status = client.executeMethod(postMethod);
            if (status == HttpStatus.SC_OK) {
                jsonResult = postMethod.getResponseBodyAsString();
            } else {
                throw new RuntimeException("接口连接失败！");
            }
        } catch (Exception e) {
            throw new RuntimeException("接口连接失败！");
        }
        return jsonResult;
    }

}
