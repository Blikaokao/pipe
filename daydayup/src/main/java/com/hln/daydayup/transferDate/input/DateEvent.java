package com.hln.daydayup.transferDate.input;
import com.hln.daydayup.dto.DateEventDto;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

public class DateEvent {
    /*public void printf(){
        System.out.println(begin_time);
        System.out.println(end_time);
        System.out.println(events);
    }*/
    public static List<DateEventDto> timeExtr(String schedule){
        Process proc;
        try {
            //回去外面读
            String[] args1 = new String[] {"python","/distinguish2.0.py",schedule};
            proc = Runtime.getRuntime().exec(args1);
            BufferedReader in = new BufferedReader(new InputStreamReader(proc.getInputStream()));
            //System.out.println("in.readline"+in.readLine());
            String line = null;

            // 获取日程数量
            int num;
            String str1 = in.readLine();
            int result1 = str1.indexOf("jio.help()");
            if(result1 == -1){ // 没有出现jio.help()
            }else{ //出现了jio.help()
                in.readLine();
                str1 = in.readLine();
            }
            num = Integer.parseInt(str1.trim());

            // 建立对应数量的日程数组
            List<DateEventDto> entities = new ArrayList<>(num);

            String event = "";
            String tmp = "";
            for(int i = 0; i < num; i++){
                tmp = event.equals("")?tmp:event;
                DateEventDto dateEventDto = new DateEventDto();
                String startDate = in.readLine();
                dateEventDto.setStartDate(startDate);
                String endDate = in.readLine();
                if(endDate.equals(""))
                    dateEventDto.setDeadLine(startDate);
                else  dateEventDto.setDeadLine(endDate);
                event = in.readLine();
                System.out.println(event);
                if(event.equals("")) {
                    dateEventDto.setTaskName(tmp);
                    event = tmp;
                }else{
                    while(event.endsWith("和")|| endsWithDegit(event))
                        event = event.substring(0,event.length()-1);
                    dateEventDto.setTaskName(event);
                }

                entities.add(dateEventDto);
            }

            //这里是我测试的时候，控制台输出结果看一下对不对，不需要的话删掉就可以了
            /*for(int i=0;i<num;i++){
                entities[i].printf();
            }*/

            in.close();
            proc.waitFor();

            return entities;

        } catch (Exception e) {
            e.printStackTrace();
        } return null;
    }

    private static boolean endsWithDegit(String event) {

        String degit;
        if(event.length()>1) {
            degit = event.substring(event.length() - 1, event.length());
            System.out.println(degit);
            if(degit.equals("1")||degit.equals("2")||degit.equals("3")||degit.equals("4")||degit.equals("5")||degit.equals("6")||degit.equals("7")||degit.equals("8")||degit.equals("9"))
                return true;
            return false;
        }
        return false;
    }
}
