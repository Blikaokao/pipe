package com.hln.daydayup.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hln.daydayup.entity.FriendRequest;
import com.hln.daydayup.entity.Miniuser;
import com.hln.daydayup.entity.Relation;
import com.hln.daydayup.entity.User;
import com.hln.daydayup.mapper.MiniuserMapper;
import com.hln.daydayup.mapper.RelationMapper;
import com.hln.daydayup.mapper.UserMapper;
import com.hln.daydayup.service.RelationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class RelationServiceImpl extends ServiceImpl<RelationMapper, Relation> implements RelationService {

    @Autowired
    MiniuserMapper miniuserMapper;

    /*
    * 根据 openid  把好友关系保存
    * */
    @Override
    public void saveRelation(String fid, String tid) {
        QueryWrapper<Miniuser> queryWrapper = new QueryWrapper<Miniuser>();
        queryWrapper.eq("id",fid);
        Miniuser miniFromUser = miniuserMapper.selectOne(queryWrapper);
        queryWrapper = new QueryWrapper<Miniuser>();
        queryWrapper.eq("id",tid);
        Miniuser miniToUser = miniuserMapper.selectOne(queryWrapper);
        Relation relation = new Relation();
        //双向的好友关系
        relation.setUserId(miniFromUser.getId())
                .setFriends(miniToUser.getId())
                .setName(miniToUser.getNickName())
                .setType(2);
        save(relation);
        relation.setUserId(miniToUser.getId())
                .setFriends(miniFromUser.getId())
                .setName(miniFromUser.getNickName())
                .setType(2);
        save(relation);
    }

    /*
    * 通过好友请求判断是否已经是好友关系
    * */
    @Override
    public boolean findRelation(FriendRequest friendRequest) {
        Relation one = query().eq("user_id", friendRequest.getFId())
                .eq("friends", friendRequest.getTId()).one();
        return one != null;
    }
}
