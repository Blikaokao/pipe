package com.hln.daydayup.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hln.daydayup.entity.Relation;
import com.hln.daydayup.entity.User;
import com.hln.daydayup.mapper.RelationMapper;
import com.hln.daydayup.mapper.UserMapper;
import com.hln.daydayup.service.RelationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class RelationServiceImpl extends ServiceImpl<RelationMapper, Relation> implements RelationService {

    @Autowired
    UserMapper userMapper;

    /*
    * 根据 openid  把好友关系保存
    * */
    @Override
    public void saveRelation(String fid, String tid) {
        QueryWrapper<User> queryWrapper = new QueryWrapper<User>();
        queryWrapper.eq("openid",fid);
        User f_user = userMapper.selectOne(queryWrapper);
        queryWrapper.eq("openid",tid);
        User t_user = userMapper.selectOne(queryWrapper);
        Relation relation = new Relation();
        //双向的好友关系
        relation.setUserId(f_user.getId())
                .setFriends(t_user.getId())
                .setName(t_user.getName());
        save(relation);
        relation.setUserId(t_user.getId())
                .setFriends(f_user.getId())
                .setName(f_user.getName());
        save(relation);
    }
}
