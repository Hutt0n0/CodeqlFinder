import java
import semmle.code.java.security.JndiInjectionQuery
import semmle.code.java.security.XsltInjectionQuery
import DataFlow::PathGraph

from  DataFlow::PathNode sink
where sink.getNode() instanceof JndiInjectionSink or
      sink.getNode() instanceof XsltInjectionSink
select 
sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(),
  "Maybe JNDI injection"