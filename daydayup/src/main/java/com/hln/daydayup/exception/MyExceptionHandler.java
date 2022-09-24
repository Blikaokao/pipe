package com.hln.daydayup.exception;

import com.hln.daydayup.base.Response;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class MyExceptionHandler {

    @ExceptionHandler(value = Exception.class)
    public Response systemEx(Exception e){
        return Response.fail(e.getMessage());
    }
}
