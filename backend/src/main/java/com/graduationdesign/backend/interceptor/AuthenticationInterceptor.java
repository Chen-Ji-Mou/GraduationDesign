package com.graduationdesign.backend.interceptor;

import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.User;
import com.graduationdesign.backend.service.IUserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@Slf4j
public class AuthenticationInterceptor implements HandlerInterceptor {

    @Autowired
    IUserService service;

    /**
     * 在请求处理之前进行调用(Controller方法调用之前)
     */
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String token = request.getHeader("token");
        if (token == null) {
            // 如果返回false，被请求时，拦截器将会拦截请求不再执行进入Controller
            log.info("[AuthenticationInterceptor] token不存在");
            return false;
        }
        String userId = Utils.getUserIdFromToken(token);
        if (userId == null) {
            log.info("[AuthenticationInterceptor] token验证失败 (token已过期)");
            return false;
        }
        boolean result = service.verifyUserById(userId);
        if (result) {
            log.info("[AuthenticationInterceptor] token验证成功 "+userId);
        } else {
            log.info("[AuthenticationInterceptor] token验证失败 userId不存在 "+userId);
        }
        return result;
    }

    /**
     * 请求处理之后进行调用，但是在视图被渲染之前（Controller方法调用之后）
     */
    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) {
    }

    /**
     * 整个请求结束之后被调用，也就是在DispatchServlet渲染了对应的视图之后执行（主要用于进行资源清理工作）
     */
    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
    }
}
