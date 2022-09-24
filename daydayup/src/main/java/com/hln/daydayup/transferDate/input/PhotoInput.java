package com.hln.daydayup.transferDate.input;




import com.hln.daydayup.dto.DateEventDto;
import com.tencentcloudapi.common.Credential;
import com.tencentcloudapi.common.exception.TencentCloudSDKException;
import com.tencentcloudapi.common.profile.ClientProfile;
import com.tencentcloudapi.common.profile.HttpProfile;
import com.tencentcloudapi.ocr.v20181119.OcrClient;
import com.tencentcloudapi.ocr.v20181119.models.GeneralAccurateOCRRequest;
import com.tencentcloudapi.ocr.v20181119.models.GeneralAccurateOCRResponse;
import com.tencentcloudapi.ocr.v20181119.models.TextDetection;

import java.net.URLEncoder;
import java.util.List;


public class PhotoInput {

    public static List<DateEventDto> getPhotoEvent(String photoUrl) throws Exception {
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
            // 实例化要请求产品的client对象,
            OcrClient client = new OcrClient(cred, "ap-guangzhou", clientProfile);// 实例化一个请求对象,每个接口都会对应一个request对象
            GeneralAccurateOCRRequest req = new GeneralAccurateOCRRequest();
            req.setImageBase64(photoUrl);
            // 返回的resp是一个GeneralAccurateOCRResponse的实例，与请求对象对应
            GeneralAccurateOCRResponse resp = client.GeneralAccurateOCR(req);
            // 输出json格式的字符串回包
            TextDetection[] textDetections = resp.getTextDetections();
            String resultString = "";
            for(int i=0;i<textDetections.length;i++){
                resultString+=textDetections[i].getDetectedText();
            }
            return DateEvent.timeExtr(resultString);
        } catch (TencentCloudSDKException e) {
                e.printStackTrace();
        }
        return null;
    }
}
