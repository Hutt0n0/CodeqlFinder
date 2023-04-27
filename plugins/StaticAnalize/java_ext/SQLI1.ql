import java
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.ExternalFlow
import DataFlow::PathGraph

class SQLISink extends DataFlow::Node {
    SQLISink(){
        exists(MethodAccess ma,Class c |
            (ma.getMethod().getName().substring(0, 5) = "query" or 
            ma.getMethod().getName() = "update" or
            ma.getMethod().getName() = "batchUpdate" or
            ma.getMethod().getName() = "execute" 
            ) and
            ma.getQualifier().getType() = c and
            c.hasQualifiedName("org.springframework.jdbc.core", "JdbcTemplate") and
            ma.getArgument(0) = this.asExpr()
        )
    }
}


from  DataFlow::PathNode sink
where
  sink.getNode() instanceof SQLISink
select sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "Potential SQLI Vulnerability"