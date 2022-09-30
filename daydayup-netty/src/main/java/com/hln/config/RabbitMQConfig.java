package com.hln.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.rabbitmq.client.ConnectionFactory;
import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.FanoutExchange;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.rabbit.listener.RabbitListenerContainerFactory;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig{
    
    @Value("${netty.port}")
    private Integer port; 
    //创建队列  注意集群之后如果单单字符串作为队列的名字 那么所有的websocket的队列都是一样的  所以
    //利用端口号去辨别
    @Bean
    public Queue queue(){
        return new Queue("ws_queue_"+port);
    }
    
    //创建交换机（广播类型交换机）
    @Bean
    public FanoutExchange fanoutExchange(){
        return new FanoutExchange("ws_exchange");
    }
    
    //把队列绑定到交换机
    @Bean
    public Binding queueToExchange(){
        return BindingBuilder.bind(queue()).to(fanoutExchange());
    }


}