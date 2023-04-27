/**
 * @name SQl注入一
 * @kind path-problem
 * 
 */
 import java
 import semmle.code.java.dataflow.FlowSources
 import semmle.code.java.security.QueryInjection
 import DataFlow::PathGraph
 import semmle.code.java.dataflow.ExternalFlow
 /**
  * A taint-tracking configuration for unvalidated user input that is used in SQL queries.
  */

  class SqlInjectionSink extends QueryInjectionSink {
    SqlInjectionSink() { 
        sinkNode(this, "sql") or
        exists(MethodAccess ma | 
        (
            ma.getMethod().getDeclaringType().getAnAncestor().hasQualifiedName("io.vertx.ext.jdbc", "JDBCClient") or
            ma.getMethod().getDeclaringType().getAnAncestor().hasQualifiedName("io.vertx.ext.sql", "SQLConnection")
        ) and 
            this.asExpr() = ma
        )

    
    }
}

 from DataFlow::PathNode source, DataFlow::PathNode sink
 where  sink.getNode() instanceof SqlInjectionSink
 select sink.getNode(), source, sink,"拼接导致的SQL注入"
