package com.hln.daydayup.transferDate.util;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import javax.servlet.http.HttpServletRequest;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class GetJson {
    public static JsonObject getJsonFromReq(HttpServletRequest req) throws IOException {
        BufferedReader streamReader = new BufferedReader(new InputStreamReader(req.getInputStream(), "UTF-8"));
        StringBuilder responseStrBuilder = new StringBuilder();
        String inputStr;
        while ((inputStr = streamReader.readLine()) != null)
            responseStrBuilder.append(inputStr);
        JsonObject jsonObject = new JsonParser().parse(responseStrBuilder.toString()).getAsJsonObject();
        return jsonObject;

    }
}
