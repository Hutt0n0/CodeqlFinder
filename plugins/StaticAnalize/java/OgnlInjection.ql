import java
import semmle.code.java.security.OgnlInjectionQuery
import DataFlow::PathGraph

from  DataFlow::PathNode sink
where sink.getNode() instanceof OgnlInjectionSink
select 
      sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "OGNL Expression Language statement depends on a "