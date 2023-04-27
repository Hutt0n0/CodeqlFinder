import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.security.XPath
import DataFlow::PathGraph


from  DataFlow::PathNode sink
where sink.getNode() instanceof XPathInjectionSink
select  
      sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "XPath expression"
      