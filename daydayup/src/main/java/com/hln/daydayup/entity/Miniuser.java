package com.hln.daydayup.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.hln.daydayup.dto.RelationDto;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.io.Serializable;

/**
 * <p>
 * 
 * </p>
 *
 * @author lina
 * @since 2022-07-18
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@AllArgsConstructor
@NoArgsConstructor
public class Miniuser implements Serializable {

    private static final long serialVersionUID=1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    private String openid;

    private String nickName;

    private Integer parentId;

    public Miniuser(String openid,String nickName){
        this.openid = openid;
        this.nickName = nickName;
    }

    public RelationDto convertToRelationDto(Integer type,Integer id){
        return new RelationDto(this.openid, this.nickName,type,id);
    }
}
