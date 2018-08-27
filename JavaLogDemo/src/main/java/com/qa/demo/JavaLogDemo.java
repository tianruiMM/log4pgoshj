package com.qa.demo;

/**
 * Created by tianrui1 on 2018/7/9.
 */
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class JavaLogDemo {
    private static Logger info = LoggerFactory.getLogger("info");
    private static Logger warn = LoggerFactory.getLogger("warn");
    private static Logger error = LoggerFactory.getLogger("error");
    @Test
    public void testLog(){
        info.info("hello");
        error.error("world");
        warn.warn("www");
    }
}
