package com.hln.daydayup.config;

import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;

import javax.servlet.*;
import java.io.IOException;
import java.util.UUID;

@Slf4j
public class HttpLogFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
      log.info("log filter init...");
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        String requestId = UUID.randomUUID().toString().replaceAll("-", "");
        MDC.put("requestId",requestId);
        filterChain.doFilter(servletRequest,servletResponse);
    }

    @Override
    public void destroy() {

    }
}
