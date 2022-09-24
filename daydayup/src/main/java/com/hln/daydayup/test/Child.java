package com.hln.daydayup.test;

public class Child extends Person {
    public String grade;



    protected int getPage(int page)  {



        return 10;

    }

    public static void parent(){
        System.out.println("child");
    }

    public void method(int a){
        System.out.println("method_child");

    }
}
