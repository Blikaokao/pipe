package com.hln.daydayup.dto;

/*
*
* 每个人每个账户对应一个任务数组
* 任务数组中包含子任务数组
*
* */

import com.baomidou.mybatisplus.annotation.TableField;
import com.hln.daydayup.entity.Detailtask;
import lombok.Data;
import lombok.experimental.Accessors;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Accessors(chain = true)
public class TaskView {
    private Integer id;

    /*
    * phone
    * */
    private String account;

    private String taskName;

    private Integer taskStatus;

    private Integer taskDetailNum;

    /*
    * id
    * */
    private String uniqueid;

    private String overallProgress;

    private String changeTimes;

    private LocalDateTime createDate;

    private LocalDateTime finishDate;

    private String startDate;

    private String deadLine;

    private Integer alert;

    private String taskType;

    private Integer eventId;

    private List<Detailtask> detailtaskList;

    private Integer label;

    private Integer period;

    private Integer eventType;
}
