package com.hln.wxnetty;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

@SpringBootApplication(scanBasePackages = "com.hln",exclude = DataSourceAutoConfiguration.class)
public class WxNettyApplication {

    public static void main(String[] args) {
        SpringApplication.run(WxNettyApplication.class, args);
    }

}
