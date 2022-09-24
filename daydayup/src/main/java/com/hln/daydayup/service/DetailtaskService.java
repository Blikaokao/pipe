package com.hln.daydayup.service;

import com.hln.daydayup.entity.Detailtask;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author lina
 * @since 2022-03-16
 */
public interface DetailtaskService extends IService<Detailtask> {
    void deleteAllById(String id);
}
