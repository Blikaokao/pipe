package com.hln.daydayup.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hln.daydayup.entity.FriendRequest;
import com.hln.daydayup.entity.Relation;

public interface RelationService  extends IService<Relation> {
    void saveRelation(String fid, String tid);

    boolean findRelation(FriendRequest friendRequest);
}
