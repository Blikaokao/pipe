package com.hln.daydayup;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.IndexResponse;
import com.hln.daydayup.esEntity.User;
import com.hln.daydayup.service.TaskService;
import com.hln.daydayup.service.UserService;
import com.hln.daydayup.utils.SnowflakeIdWorker;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.test.context.junit4.SpringRunner;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.UUID;

@SpringBootTest
class DaydayupApplicationTests {

    @Autowired
    private ElasticsearchClient client;

    @Test
    void testDate() throws ParseException {

        System.out.println(UUID.randomUUID().toString().replace("-",""));

    }

   /* @Test
    public void createTest() throws IOException {

        //写法比RestHighLevelClient更加简洁
        CreateIndexResponse indexResponse = client.indices().create(c -> c.index("user"));
    }*/
    @Test
    public void addDocumentTest() throws IOException {

        User tmp = new User("juicy", 10);
        IndexResponse indexResponse = client.index(i -> i
                .index("user_index") //索引是user
                //设置id
                .id("1")
                //传入user对象
                .document(tmp));
    }

}
