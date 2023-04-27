import java
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.ExternalFlow
import DataFlow::PathGraph

class URIFilterSink extends DataFlow::Node {
    URIFilterSink(){
        exists( IfStmt is |
            is.getCondition() = this.asExpr()
        )
    }
}



from  DataFlow::PathNode sink
where
  sink.getNode() instanceof URIFilterSink 
select 
      sink,sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "Unsafe getRequestURI Using in Filter"