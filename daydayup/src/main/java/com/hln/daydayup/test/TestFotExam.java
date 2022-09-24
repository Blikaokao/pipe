package com.hln.daydayup.test;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class TestFotExam {
    public static void main(String[] args) {
        Child child = new Child();
        Child a = new Child();
        a.method(1);
        Person person = (Person)child;
        Child test1 = (Child) person;
        child.method();
        Child.parent();
        person.method();
        Person.parent();

        //int [][]a = {{1,2,3},{1,2,3,4}};
        String str = "123";
        char[] ch =new char[3];
        System.out.println(Math.round(3.3)+"&"+Math.round(3.5));

        List list = new ArrayList();
        //list.stream().collect(Collectors.toCollection());
        Set set =  new HashSet();
        byte b = (byte) 257;
        class Foo{
            public int i=3;
        }
        Object o=(Object)new Foo();
        Foo foo=(Foo)o;
        System.out.println(foo.i);

        int index=1;

        String[] test=new String[3];

        String fo=test[index];
        System.out.println(fo);

        int anar[]=new int[]{1,2,3};

        System.out.println(anar[1]);
    }
}
