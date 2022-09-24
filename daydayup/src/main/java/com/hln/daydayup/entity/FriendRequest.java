package com.hln.daydayup.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * <p>
 * 
 * </p>
 *
 * @author lina
 * @since 2022-09-22
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
public class FriendRequest implements Serializable {

    private static final long serialVersionUID=1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    /**
     * 发送好友请求方
     */
    private String fId;

    /**
     * 接收好友请求方
     */
    private String tId;

    /**
     * 1.接受 2.拒绝 0.待处理
     */
    private Integer status;

    /*
    * 发送好友请求的时间
    * */
    private LocalDateTime createTime;

}
