package com.hln.daydayup.config;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.servlet.Filter;

@Configuration
public class WebFilterConfig {

    @Bean
    public FilterRegistrationBean getFilterBean(){
        FilterRegistrationBean<Filter> filter = new FilterRegistrationBean<>();
        filter.setFilter(new HttpLogFilter());
        filter.addUrlPatterns("/*");
        return filter;
    }
}
