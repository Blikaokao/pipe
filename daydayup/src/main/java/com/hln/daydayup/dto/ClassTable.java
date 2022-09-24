package com.hln.daydayup.dto;

import java.util.ArrayList;
import java.util.List;


public class ClassTable {

    private List<OneDayClass> week ;
    private List<List<String>> weekLession;

    public List<List<String>> getWeekLession() {
        weekLession = new ArrayList<>();
        for(int j=0;j<7;j++) {
            OneDayClass oneDayClass = week.get(j);
            List<String> lesson = oneDayClass.getLesson();
            if (lesson == null || lesson.size()==0)
                System.out.println("空了！");
            else
                weekLession.add(lesson);
        }
        return weekLession;
    }

    public ClassTable(){
        week = new ArrayList<OneDayClass>();
        for (int i=0;i<7;i++){
            week.add(new OneDayClass());
        }
    }

    public void setWeekLesson(int day,int index,String detail) {
        week.get(day).setLesson(index,detail);
    }

    /*public void setWeekLesson(int day,int index,String detail){
        week.get(day).setLesson(index,detail);
    }
*/
    public List<OneDayClass> getWeek() {
        return week;
    }

    public void setWeek(List<OneDayClass> week) {
        this.week = week;
    }

    public void outPutAllClass(){
        for(int i=0;i<10;i++){
            for(int j=0;j<7;j++){
                week.get(j).outPutLesson(i);
                System.out.print(" ");
            }
            System.out.println(" ");
        }
    }
}
