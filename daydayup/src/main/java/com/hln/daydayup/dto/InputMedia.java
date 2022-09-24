package com.hln.daydayup.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class InputMedia {
    private String img;
    private Integer len;
    private String speech;
    private String text;
}
