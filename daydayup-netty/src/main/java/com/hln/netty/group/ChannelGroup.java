package com.hln.netty.group;

import io.netty.channel.Channel;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class ChannelGroup {
    /*
    * key:设备id   这里直接用openid代替设备id  没有用户下线问题
    * channel：设备id的连接对象
    * */
    public static Map<String, Channel>  channelMap = new HashMap<>();

    /*
    * 添加channel到容器中
    * did
    * channel
    * */
    public static void addChannel(String did, Channel channel){
        channelMap.put(did,channel);
    }

    public static Channel getChannel(String did){
        return channelMap.get(did);
    }

    public static void removeChannel(String did){
        channelMap.remove(did);
    }

    public static void removeChannel(Channel channel){
        if(channelMap.containsValue(channel)){
            Set<Map.Entry<String, Channel>> entries = channelMap.entrySet();
            for(Map.Entry<String, Channel> ent :entries){
                if(ent.getValue()==channel){
                    channelMap.remove(ent.getKey());
                    break;
                }
            }
        }
    }
}
