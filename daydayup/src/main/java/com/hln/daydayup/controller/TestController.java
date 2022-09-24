package com.hln.daydayup.controller;

import com.hln.daydayup.base.Response;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {
    @GetMapping("/test")
    public String test(){
       return "success!";
    }
}
