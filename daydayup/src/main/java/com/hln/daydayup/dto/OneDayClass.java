package com.hln.daydayup.dto;

import java.util.ArrayList;
import java.util.List;


class OneDayClass {
    private List<String> lesson;

    OneDayClass() {
        lesson = new ArrayList<>();
        for (int i = 0; i < 10; i++) {
            lesson.add("");
        }
    }

    void setLesson(int index, String detail) {
        this.lesson.set(index, detail);
    }

    void outPutLesson(int index) {
        System.out.print(lesson.get(index));
    }

    public List<String> getLesson() {
        return lesson;
    }
}