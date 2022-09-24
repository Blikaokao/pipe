package com.hln.daydayup.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import java.time.LocalDateTime;
import com.baomidou.mybatisplus.annotation.TableField;
import java.io.Serializable;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;

/**
 * <p>
 * 
 * </p>
 *
 * @author lina
 * @since 2022-03-16
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
public class Task implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    /**
     * username
     */
    private String account;

    private String taskName;

    private Integer taskStatus;

    private Integer taskDetailNum;

    @TableField("uniqueId")
    private String uniqueid;

    private String overallProgress;

    private String changeTimes;

    private LocalDateTime createDate;

    private LocalDateTime finishDate;

    private String startDate;

    private String deadLine;

    /*
    * 提醒时间 默认单位为分钟
    * */
    private Integer alert;

    private String taskType;

    private Integer eventId;

    /*
    * 标签
    * */
    private Integer label;

    /*
    * 周期
    * */
    private Integer period;

    /*
    * 周期性事件标识
    * */
    private Integer eventType;
}
