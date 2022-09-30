package com.hln.daydayup.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hln.daydayup.entity.FriendRequest;
import com.hln.daydayup.mapper.FriendRequestMapper;
import com.hln.daydayup.service.FriendRequestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * <p>
 *  服务实现类
 * </p>
 *
 * @author lina
 * @since 2022-09-22
 */
@Service
public class FriendRequestServiceImpl extends ServiceImpl<FriendRequestMapper, FriendRequest> implements FriendRequestService {

    @Autowired
    FriendRequestMapper friendRequestMapper;
    /**
     *
     * 将来自于一个用户的请求进行处理
     * @param friendRequest
     */
    @Override
    public void updateByFATid(FriendRequest friendRequest) {
        Integer status = friendRequest.getStatus();
        //同意
        if(status == 3){
             /*
            * 把所有符合条件的都更新
            * */
            update().setSql("status = 3").eq("f_id",friendRequest.getFId())
                    .eq("t_id",friendRequest.getTId())
                    .or()
                    .eq("t_id",friendRequest.getFId())
                    .eq("f_id",friendRequest.getTId())
                    .update();
        }else if (status == 2){
            //拒绝
            friendRequestMapper.updateById(friendRequest);
        }
    }
}
