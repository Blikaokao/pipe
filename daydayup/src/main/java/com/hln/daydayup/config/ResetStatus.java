package com.hln.daydayup.config;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.hln.daydayup.entity.Task;
import com.hln.daydayup.service.TaskService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.Scheduled;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

@Configuration
@Slf4j
public class ResetStatus {

    @Autowired
    TaskService taskService;
    /*
    * 每天00:00 进行任务状态重置
    * 任务设置有提醒但是 状态为todo  点击取消等等
    * 设置任务状态为过期outTime 其余的任务状态为已做done
    * */
    @Scheduled(cron = "0 0 0 * * ? ")
    private void setStatus() {
        /*
         * 昨天未完成的任务设置为过期状态
         * */
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DATE, -1);
        Date d = cal.getTime();

        SimpleDateFormat sp = new SimpleDateFormat("yyyy-MM-dd");
        String newDay = sp.format(d);//获取昨天日期
        taskService.outTimeDate(newDay);//未完成定时任务判定为outTime
        taskService.doneDate(newDay);
        log.info("更新状态");
    }

}
