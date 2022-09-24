package com.hln.daydayup.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Accessors(chain = true)
public class DateEventDto {
    private String startDate; //开始时间
    private String deadLine; //结束时间
    private String taskName; //事件
}
