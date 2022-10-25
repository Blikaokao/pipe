package com.hln.daydayup.utils;

import com.hln.daydayup.dto.InputMedia;

import java.io.File;
import java.io.FileInputStream;
import java.util.Base64;

public class EncodeFile {

    public static InputMedia encodeBase64File(String path) throws Exception {
        File file = new File(path);
        FileInputStream inputFile = new FileInputStream(file);
        byte[] buffer = new byte[(int) file.length()];
        inputFile.read(buffer);
        inputFile.close();

        InputMedia inputMedia = new InputMedia();
        inputMedia.setSpeech(Base64.getEncoder().encodeToString(buffer));
        inputMedia.setLen((int) file.length());
        return inputMedia;
    }


}
