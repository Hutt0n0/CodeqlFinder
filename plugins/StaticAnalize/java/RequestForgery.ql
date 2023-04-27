import java
import semmle.code.java.security.RequestForgeryConfig
import DataFlow::PathGraph


import semmle.code.java.security.RequestForgery


from DataFlow::Node sink
where
     //SSRF漏洞
    sink instanceof RequestForgerySink
   
select "漏洞类型:","SSRF漏洞","漏洞表达式：",sink.asExpr(),"漏洞文件位置",sink.getLocation()


