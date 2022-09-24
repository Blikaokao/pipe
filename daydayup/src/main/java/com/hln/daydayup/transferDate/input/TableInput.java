package com.hln.daydayup.transferDate.input;

import com.hln.daydayup.dto.ClassTable;
import com.tencentcloudapi.common.Credential;
import com.tencentcloudapi.common.profile.ClientProfile;
import com.tencentcloudapi.common.profile.HttpProfile;
import com.tencentcloudapi.common.exception.TencentCloudSDKException;
import com.tencentcloudapi.ocr.v20181119.OcrClient;
import com.tencentcloudapi.ocr.v20181119.models.*;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class TableInput {

    public static ClassTable getClassTable(String photoUrl){
        int rowBeg=-1;
        int colBeg = -1;
        List<String> week = new ArrayList<String>();
        Collections.addAll(week,"一","二","三","四","五");
        ClassTable classTable = new ClassTable();

        try{

            // 实例化一个认证对象，入参需要传入腾讯云账户secretId，secretKey,此处还需注意密钥对的保密
            // 密钥可前往https://console.cloud.tencent.com/cam/capi网站进行获取
            Credential cred = new Credential("AKIDUnrgGbgW7SYOzKPHuJUQ7YjfLmxsYy82", "h9LJ1VklW1HH1VkjSwA9tOddNr67tPgh");
            // 实例化一个http选项，可选的，没有特殊需求可以跳过
            HttpProfile httpProfile = new HttpProfile();
            httpProfile.setEndpoint("ocr.tencentcloudapi.com");
            // 实例化一个client选项，可选的，没有特殊需求可以跳过
            ClientProfile clientProfile = new ClientProfile();
            clientProfile.setHttpProfile(httpProfile);
            // 实例化要请求产品的client对象,clientProfile是可选的
            OcrClient client = new OcrClient(cred, "ap-guangzhou", clientProfile);
            // 实例化一个请求对象,每个接口都会对应一个request对象
            RecognizeTableOCRRequest req = new RecognizeTableOCRRequest();
            req.setImageBase64(photoUrl);
            // 返回的resp是一个RecognizeTableOCRResponse的实例，与请求对象对应
            RecognizeTableOCRResponse resp = client.RecognizeTableOCR(req);
            // 输出json格式的字符串回包
            TableDetectInfo[] tableDetectInfos = resp.getTableDetections();

            TableCell[] tableCells = tableDetectInfos[0].getCells();

            System.out.println("tabelcell:"+tableCells);

            if(tableCells!=null) {
                for (int j = 0; j < tableCells.length; j++) {

                    String text = tableCells[j].getText();
                    int crow = Math.toIntExact(tableCells[j].getRowTl());
                    int ccol = Math.toIntExact(tableCells[j].getColTl());
                    //确定周一所在的行和列
                    if(rowBeg==-1&&text.length()>0){

                        for (int k=0;k<week.size();k++){
                            String[] strings = text.split(" ");
                            for(int m=0;m<strings.length;m++){
                                if(strings[m].contains(week.get(k))){
                                    rowBeg = crow+1;
                                    colBeg = ccol-k+m;
                                    break;
                                }
                            }
                            if(rowBeg!=-1){
                                break;
                            }

                        }

                    }else {
                        if(rowBeg<=-1){
                            continue;
                        }else{//确定起点后
                            int day = ccol-colBeg;
                            int index = crow-rowBeg;
                            if(index>=0&&day>=0&&index<10&&day<7){
                                classTable.setWeekLesson(day,index,text);
                                System.out.println("success:"+classTable.toString());
                            }

                        }

                    }

                }
            }else System.out.println("无");

        } catch (TencentCloudSDKException e) {
            System.out.println(e.toString());
        }
        return classTable;
    }
}