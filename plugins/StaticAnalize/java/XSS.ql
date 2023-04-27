import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.security.XSS
import DataFlow::PathGraph


from DataFlow::PathNode source, DataFlow::PathNode sink
where sink.getNode() instanceof XssSink
select 
      sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "Cross-site scripting vulnerability"