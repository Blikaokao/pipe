package com.hln.daydayup.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.hln.daydayup.dto.RelationDto;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;

import java.io.Serializable;


/**
*
 * 存储用户关系表
*@author lina
*date:2022-05-01
*/
@Data
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
public class Relation implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    private Integer userId;

    private Integer friends;

    private String name;

    private String phone;

    public RelationDto convertToDto(){
        return new RelationDto(this.friends,this.name,2,this.phone);
    }

}
