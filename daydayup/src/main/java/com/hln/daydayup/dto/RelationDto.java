package com.hln.daydayup.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RelationDto {
    //关联账号的id
    private String userId;

    //关联账号的名字（在主账户标记的名字） 相当于备注
    private String names;

    /*
    * 1  创建的用户
    * 2  关联的用户
    * 0  自己
    * */
    private Integer type;

    /*
    * 电话号码
    * */
    private String phone;

    private Integer id;

    public RelationDto(String id,String name,Integer type){
        this.names = name;
        this.userId = id;
        this.type = type;
    }

    public RelationDto(String id,String name,Integer type,String phone){
        this.names = name;
        this.userId = id;
        this.type = type;
        this.phone = phone;
    }

    public RelationDto(String userId,String name,Integer type,Integer id){
        this.names = name;
        this.userId = userId;
        this.type = type;
        this.id = id;
    }
}
