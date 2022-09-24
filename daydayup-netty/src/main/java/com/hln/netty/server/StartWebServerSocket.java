package com.hln.netty.server;

import com.hln.netty.handler.*;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.codec.http.HttpObjectAggregator;
import io.netty.handler.codec.http.HttpServerCodec;
import io.netty.handler.codec.http.websocketx.WebSocketServerProtocolHandler;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

@Component
public class StartWebServerSocket implements CommandLineRunner {

    @Value("${netty.port}")
    private Integer port;

    @Autowired
    private StringRedisTemplate redisTemplate;

    @Autowired
    private RabbitTemplate rabbitTemplate;
    /*
    * springboot初始化成功之后调用
    * */
    @Override
    public void run(String... args) throws Exception {
        //创建两个线程池  （线程模型使用的是主从模型）
        EventLoopGroup master = new NioEventLoopGroup();//主线程负责连接
        EventLoopGroup slave = new NioEventLoopGroup();//从线程池主要负责读写

        try {
            ServerBootstrap serverBootstrap = new ServerBootstrap();
            serverBootstrap.group(master,slave);//设置主从线程模型
            serverBootstrap.channel(NioServerSocketChannel.class);//设置服务器

            //设置处理链
            serverBootstrap.childHandler(new ChannelInitializer() {
                @Override
                protected void initChannel(Channel channel) throws Exception {
                    ChannelPipeline pipeline = channel.pipeline();

                    //http
                    pipeline.addLast(new HttpServerCodec());
                    //http
                    pipeline.addLast(new HttpObjectAggregator(1024*10));
                    //添加websocket的编解码器
                    pipeline.addLast(new WebSocketServerProtocolHandler("/"));//哪个路径使用 websocket的编解码器

                    pipeline.addLast(new WebSocketHandler());

                    pipeline.addLast(new ConnHandler(redisTemplate));

                    pipeline.addLast(new HeartHandler());

                    pipeline.addLast(new AddHandler(rabbitTemplate));

                }
            });

            ChannelFuture channelFuture = serverBootstrap.bind(port);
            channelFuture.sync();//阻塞住
            System.out.println("成功启动server");
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

    }
}
