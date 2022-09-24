package com.hln.daydayup.test;

public class Person {
    private String name="Person";
    int age=0;
    protected int getPage(){
        return 30;
    }
    public static void parent(){
        System.out.println("parent");
    }

    public void method(){
        System.out.println("method_parent");
    }
}
