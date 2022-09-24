package com.hln.daydayup;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.ServletComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@MapperScan("com.hln.daydayup.mapper")
@EnableScheduling
public class DaydayupApplication {

    public static void main(String[] args) {
        SpringApplication.run(DaydayupApplication.class, args);
    }

}
