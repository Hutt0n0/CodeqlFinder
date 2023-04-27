import java
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.ExternalFlow
import DataFlow::PathGraph

class SQLISink extends DataFlow::Node {
    SQLISink(){
        exists( AddExpr ae |
            (
                ae.getRightOperand().toString().toLowerCase().regexpMatch(".*?select.+?from.+?where.*?|.*?update.+?set.+?where.*?|.*?insert.+?into.+?values.*?|.*?delete.+?from.+?where.*?") 
            ) and
            this.asExpr() = ae
        )
    }
}

class SQLIConfig extends TaintTracking::Configuration {
    SQLIConfig() { this = "SQLI Vulnerability" }

  override predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  override predicate isSink(DataFlow::Node sink) { sink instanceof SQLISink }

}

from  DataFlow::PathNode sink
where
sink.getNode() instanceof SQLISink
select 
      sink,sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "Potential SQLI Vulnerability"
