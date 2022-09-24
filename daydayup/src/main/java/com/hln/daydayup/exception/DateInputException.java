package com.hln.daydayup.exception;

/**
 * 自定义异常类  处理日程日期不能同时为空的情况
 */
public class DateInputException extends Exception {
    //异常信息
    private String message;

    //构造函数
    public DateInputException(String message){
        super(message);
        this.message = message;
    }

    //获取异常信息,由于构造函数调用了super(message),不用重写此方法
    //public String getMessage(){
    //    return message;
    //}
}
